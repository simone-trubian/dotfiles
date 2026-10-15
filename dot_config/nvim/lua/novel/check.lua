-- Pre-merge checks. Errors (E) block a merge; warnings (W) do not.
local novel = require("novel")
local ts = require("novel.typeset")
local M = {}

local SPEECH = {
  "said", "asked", "replied", "answered", "exclaimed", "whispered", "shouted", "muttered", "mumbled", "cried",
  "called", "yelled", "snapped", "insisted", "retorted", "murmured", "declared", "explained", "repeated",
  "suggested", "protested", "admitted", "agreed", "demanded", "responded", "observed", "remarked", "commented",
  "enquired", "inquired", "grumbled", "barked", "hissed", "joked", "warned", "pleaded", "begged", "conceded",
  "objected", "interrupted", "interjected", "concluded", "confirmed", "corrected", "reassured", "continued",
  "added", "started", "began", "proposed", "stammered", "stuttered", "blurted", "boomed", "growled", "lied",
}
local IS_SPEECH = {}
for _, v in ipairs(SPEECH) do
  IS_SPEECH[v] = true
end

-- -ize words that are also correct in -ise spelling (size, prize, seize …)
local IZE_OK = {
  size = true, sizes = true, sized = true, sizing = true, prize = true, prizes = true, prized = true,
  seize = true, seizes = true, seized = true, seizing = true, capsize = true, capsized = true, maize = true,
  baize = true, assize = true, assizes = true, downsize = true, downsized = true, resize = true, resized = true,
  oversize = true, oversized = true, outsize = true, outsized = true, supersize = true,
}

local IZE_SUFFIX = { "ize", "izes", "ized", "izing", "ization", "izations", "izer", "izers" }

local function is_letter(ch)
  if not ch then
    return false
  end
  if #ch == 1 then
    return ch:match("^%a$") ~= nil
  end
  local b = ch:byte(1)
  return b >= 195 and b <= 223 -- Latin-1 accents, Greek, Cyrillic (two-byte letters)
end

local function read(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end

local function lines_of(path)
  local buf = vim.fn.bufnr(path)
  if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end
  local s = read(path)
  return s and vim.split(s, "\n", { plain = true }) or nil
end
M.lines_of = lines_of

--- Chapter numbers of all `# N` headings in a file.
function M.headings(lines)
  local t = {}
  for i, l in ipairs(lines) do
    local n = l:match("^#%s+(%d+)%s*$")
    if n then
      t[#t + 1] = { lnum = i, n = tonumber(n) }
    end
  end
  return t
end

function M.last_chapter(root)
  local h = M.headings(lines_of(root .. "/" .. novel.files.master) or {})
  return h[#h] and h[#h].n or 0
end

-- Names: capitalised words in the novel's spell file (tools/spell/en.utf-8.add)
local function load_names(root)
  local names = {}
  for _, w in ipairs(lines_of(root .. "/tools/spell/en.utf-8.add") or {}) do
    w = vim.trim(w)
    if w:match("^%u") and not w:match("/") then
      names[#names + 1] = w
    end
  end
  return names
end

local function lev(a, b, max)
  local ca, cb = ts.chars(a), ts.chars(b)
  if math.abs(#ca - #cb) > max then
    return max + 1
  end
  local prev = {}
  for j = 0, #cb do
    prev[j] = j
  end
  for i = 1, #ca do
    local cur = { [0] = i }
    local best = i
    for j = 1, #cb do
      local cost = ca[i] == cb[j] and 0 or 1
      cur[j] = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
      best = math.min(best, cur[j])
    end
    if best > max then
      return max + 1
    end
    prev = cur
  end
  return prev[#cb]
end

-- Spell checking runs in a hidden buffer that carries the novel's spell settings
local spellbuf
local function spell_bad(root)
  if not spellbuf or not vim.api.nvim_buf_is_valid(spellbuf) then
    spellbuf = vim.api.nvim_create_buf(false, true)
  end
  local add = root .. "/tools/spell/en.utf-8.add"
  vim.bo[spellbuf].spelllang = "en_gb"
  if vim.uv.fs_stat(add) then
    vim.bo[spellbuf].spellfile = add
  end
  local cache = {}
  local spl = vim.uv.fs_stat(add .. ".spl")
  local src = vim.uv.fs_stat(add)
  if src and (not spl or spl.mtime.sec < src.mtime.sec) then
    vim.cmd("silent! mkspell! " .. vim.fn.fnameescape(add))
  end
  return function(word)
    if cache[word] == nil then
      local ascii = word:gsub("’s$", ""):gsub("’", "'")
      local bad = false
      vim.api.nvim_buf_call(spellbuf, function()
        vim.wo.spell = true
        for _, r in ipairs(vim.spell.check(ascii)) do
          if r[2] == "bad" then
            bad = true
          end
        end
      end)
      cache[word] = bad
    end
    return cache[word]
  end
end

--- Check lines; returns quickfix items (without filename).
--- opts.expect = chapter number the first heading must have (chapter files)
function M.lines(lines, root, opts)
  opts = opts or {}
  local items = {}
  local function add(lnum, col, typ, text)
    items[#items + 1] = { lnum = lnum, col = col, type = typ, text = text }
  end
  local is_bad = spell_bad(root)
  local names = load_names(root)
  local nameset = {}
  for _, n in ipairs(names) do
    nameset[n] = true
  end
  local near = {}

  -- headings
  local heads = M.headings(lines)
  for i, l in ipairs(lines) do
    if l:match("^#") and not l:match("^#%s+%d+%s*$") then
      add(i, 1, "E", "Chapter heading must be '# <number>', e.g. '# 32'")
    end
  end
  if opts.expect then
    if not heads[1] then
      add(1, 1, "E", ("Missing chapter heading: expected '# %d'"):format(opts.expect))
    elseif heads[1].n ~= opts.expect then
      add(heads[1].lnum, 1, "E", ("Chapter number is %d, expected %d"):format(heads[1].n, opts.expect))
    end
    if #heads > 1 then
      add(heads[2].lnum, 1, "E", "A chapter file must hold a single chapter")
    end
  else
    for k = 2, #heads do
      if heads[k].n ~= heads[k - 1].n + 1 then
        add(heads[k].lnum, 1, "E", ("Chapter %d follows chapter %d"):format(heads[k].n, heads[k - 1].n))
      end
    end
  end

  local in_yaml = lines[1] == "---"
  for i, l in ipairs(lines) do
    if in_yaml then
      if i > 1 and l == "---" then
        in_yaml = false
      end
      goto next_line
    end
    if l == "" or l:match("^#") or l == "* * *" then
      goto next_line
    end
    -- paragraph broken over two lines
    if lines[i - 1] and lines[i - 1] ~= "" and not lines[i - 1]:match("^#") and lines[i - 1] ~= "---" and i > 1 then
      add(i, 1, "E", "Paragraph continues on this line: add a blank line between paragraphs")
    end

    local c = ts.chars(l)
    local byte = { 1 }
    for k = 1, #c do
      byte[k + 1] = byte[k] + #c[k]
    end
    -- character-level checks and quote balance
    local open, inner = false, false
    for k, ch in ipairs(c) do
      local prev, nxt = c[k - 1], c[k + 1]
      if ch == '"' or ch == "'" then
        add(i, byte[k], "E", "Straight quote: use ‘ ’ (or “ ” inside dialogue). :Typeset fixes it")
      elseif ch == "‘" then
        if open then
          add(i, byte[k], "E", "Quote opened while another is open: missing closing ’ before this?")
        end
        open = true
      elseif ch == "’" then
        -- followed by a letter it is an apostrophe (don’t, Oleksandr’s, ’till)
        local na = nxt and nxt:match("^%w$")
        if not na then
          if open then
            open = false
          elseif prev and prev:match("^[%.,!%?]$") or prev == "…" then
            add(i, byte[k], "E", "Closing quote without an opening ‘")
          end
        end
      elseif ch == "“" then
        if not open then
          add(i, byte[k], "W", "Double quote outside dialogue: narration uses ‘ ’")
        end
        inner = true
      elseif ch == "”" then
        inner = false
      end
    end
    if inner then
      add(i, #l, "E", "Inner quote “ not closed with ”")
    end
    if open then
      local nextpara
      for j = i + 1, #lines do
        if lines[j] ~= "" then
          nextpara = lines[j]
          break
        end
      end
      -- a speech running over several paragraphs reopens with ‘ and is fine
      if nextpara and nextpara:sub(1, 3) == "‘" then
        add(i, #l, "W", "Quote not closed: fine only if the same speaker carries on in the next paragraph")
      else
        add(i, #l, "E", "Quote opened with ‘ is not closed in this paragraph")
      end
    end

    local s = l:find("...", 1, true)
    if s then
      add(i, s, "E", "Three full stops: use the ellipsis character … (:Typeset)")
    end
    s = l:find("  ", 1, true)
    if s then
      add(i, s, "W", "Double space")
    end
    s = l:find(" - ", 1, true)
    if s then
      add(i, s, "W", "Hyphen used as a dash: use a spaced en dash ( – )")
    end
    s = l:find("’ ‘", 1, true)
    if s then
      add(i, s, "W", "Two quotations back to back: a new speaker starts a new paragraph")
    end

    -- dialogue tags: look at the word(s) after each closing quote
    local pos = 1
    while true do
      local a, b = l:find("’ ", pos, true)
      if not a then
        break
      end
      pos = b + 1
      local before = l:sub(1, a - 1)
      local last = ts.chars(before)
      last = last[#last]
      local w1, w2 = l:sub(b + 1):match("^([%a]+)%s+([%a]+)")
      local w = l:sub(b + 1):match("^([%a]+)")
      if w and IS_SPEECH[w:lower()] and w:match("^%u") and last and not last:match("^%w$") then
        add(i, a, "W", ("Speech tag after a quote is lowercase: ‘…’ %s"):format(w:lower()))
      elseif w and IS_SPEECH[w] then
        if last == "." then
          add(i, a, "W", ("Full stop before a speech tag: ‘…,’ %s"):format(w))
        elseif last and last:match("^%a$") and not before:match("s$") then
          add(i, a, "W", ("Missing comma before the closing quote: ‘…,’ %s"):format(w))
        end
      elseif w1 and (w1 == "He" or w1 == "She" or w1 == "They" or w1 == "We") and IS_SPEECH[w2] then
        if last == "?" or last == "!" or last == "…" or last == "," then
          add(i, a, "W", ("Pronoun after the quote is lowercase: ‘…?’ %s %s"):format(w1:lower(), w2))
        elseif last == "." then
          add(i, a, "W", ("Full stop before a speech tag: ‘…,’ %s %s"):format(w1:lower(), w2))
        end
      end
    end

    -- word-level checks: -ize spelling, spelling, name near-misses
    local k = 1
    while k <= #c do
      if is_letter(c[k]) then
        local j = k
        while j < #c and (is_letter(c[j + 1]) or ((c[j + 1] == "’" or c[j + 1] == "-") and is_letter(c[j + 2]))) do
          j = j + 1
        end
        local word = table.concat(c, "", k, j)
        local st = byte[k]
        k = j + 1
        if #word > 1 then
          local lw = word:lower():match("([^%-]+)$") or word:lower()
          local ize = false
          for _, suf in ipairs(IZE_SUFFIX) do
            if lw:sub(-#suf) == suf and #lw - #suf >= 3 and not IZE_OK[lw] then
              ize = true
            end
          end
          if ize and not word:match("^%u") then
            add(i, st, "W", ("-ize spelling: house style is -ise (%s)"):format(word))
          elseif not word:find("-", 1, true) and is_bad(word) then
            local hint = ""
            if word:match("^%u") and #ts.chars(word) >= 4 and not nameset[word] then
              if near[word] == nil then
                near[word] = false
                for _, n in ipairs(names) do
                  if lev(word, n, 2) <= 2 then
                    near[word] = n
                    break
                  end
                end
              end
              if near[word] then
                hint = (" — did you mean %s?"):format(near[word])
              end
            end
            add(i, st, "W", ("Spelling: %s%s"):format(word, hint))
          elseif word:find("-", 1, true) then
            for part in word:gmatch("[^%-]+") do
              if #part > 1 and is_bad(part) then
                add(i, st, "W", ("Spelling: %s (in %s)"):format(part, word))
              end
            end
          end
        end
      else
        k = k + 1
      end
    end
    ::next_line::
  end
  table.sort(items, function(x, y)
    return x.lnum < y.lnum or (x.lnum == y.lnum and x.col < y.col)
  end)
  return items
end

--- Check a file, fill the quickfix list. Returns number of errors, warnings.
function M.file(root, path, opts)
  local lines = lines_of(path)
  if not lines then
    vim.notify("Cannot read " .. path, vim.log.levels.ERROR)
    return 1, 0
  end
  local items = M.lines(lines, root, opts)
  local e, w = 0, 0
  for _, it in ipairs(items) do
    it.filename = path
    if it.type == "E" then
      e = e + 1
    else
      w = w + 1
    end
  end
  vim.fn.setqflist({}, " ", { title = ("Novel check: %s"):format(vim.fs.basename(path)), items = items })
  return e, w, items
end

function M.expect_for(root, path)
  local base = vim.fs.basename(path)
  local last = M.last_chapter(root)
  if base == novel.files.previous then
    return last + 1
  elseif base == novel.files.current then
    return last + 2
  end
end

function M.run(path)
  local root = novel.root_or_warn()
  if not root then
    return
  end
  path = path and vim.fn.fnamemodify(path, ":p") or root .. "/" .. novel.files.previous
  local e, w = M.file(root, path, { expect = M.expect_for(root, path) })
  local msg = ("%s: %d error%s, %d warning%s"):format(vim.fs.basename(path), e, e == 1 and "" or "s", w, w == 1 and "" or "s")
  if e + w > 0 then
    vim.cmd("copen | wincmd p")
  end
  vim.notify(msg, e > 0 and vim.log.levels.ERROR or (w > 0 and vim.log.levels.WARN or vim.log.levels.INFO))
end

return M

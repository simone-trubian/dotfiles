-- House typography: single curly quotes for dialogue, double inside, curly
-- apostrophes, a single-character ellipsis, spaced en dash, closed em dash.
local M = {}

local UTF8 = "[%z\1-\127\194-\244][\128-\191]*"

function M.chars(s)
  local t = {}
  for c in s:gmatch(UTF8) do
    t[#t + 1] = c
  end
  return t
end

local function alnum(c)
  return c ~= nil and c ~= "" and (c:match("^%w$") ~= nil or #c > 1 and c:match("^[\195-\223]") ~= nil)
end

local function space(c)
  return c == nil or c == "" or c:match("^%s$") ~= nil
end

-- characters after which a quote opens
local OPENERS = { ["("] = true, ["["] = true, ["‘"] = true, ["“"] = true }

local ELISION = { "till", "til", "em", "cause", "cos", "n", "tis", "twas" }

local function is_elision(chars, k)
  local word = {}
  for j = k + 1, math.min(k + 5, #chars) do
    if not alnum(chars[j]) then
      break
    end
    word[#word + 1] = chars[j]
  end
  local w = table.concat(word):lower()
  if w:match("^%d0s$") then
    return true
  end
  for _, e in ipairs(ELISION) do
    if w == e then
      return true
    end
  end
  return false
end

--- Convert one paragraph (one line) to house typography.
function M.line(s)
  s = s:gsub("%s+$", "")
  while s:sub(-2) == "94p" do
    s = s:sub(1, -3):gsub("%s+$", "")
  end
  s = s:gsub("%.%.%.", "…"):gsub("([^%.])%.%.([^%.])", "%1…%2"):gsub("  +", " ")
  s = s:gsub("%-%-%-", "—"):gsub(" %-%- ", " – "):gsub(" %- ", " – ")
  local c = M.chars(s)
  local out = {}
  local dbl, sgl, sgl_inside = false, false, false
  local skip_space = false
  for k, ch in ipairs(c) do
    local prev, nxt = c[k - 1], c[k + 1]
    if skip_space and ch == " " then
      skip_space = false
      goto continue
    end
    skip_space = false
    if ch == '"' or ch == "“" or ch == "”" then
      local opening
      if space(prev) or OPENERS[prev] then
        opening = true
      elseif space(nxt) or (nxt and nxt:match("^[%.,;:!%?%)]$")) or nxt == "…" or nxt == "—" or nxt == "–" then
        opening = false
      else
        opening = not dbl
      end
      if opening then
        dbl = true
        out[#out + 1] = "‘"
        skip_space = true
      else
        if sgl and sgl_inside then
          out[#out + 1] = "”"
          sgl = false
        end
        dbl = false
        out[#out + 1] = "’"
      end
    elseif ch == "'" or ch == "‘" or ch == "’" then
      local pa, na = alnum(prev), alnum(nxt)
      if pa and na then
        out[#out + 1] = "’"
      elseif not pa and na and (space(prev) or OPENERS[prev] or prev == '"') then
        if is_elision(c, k) then
          out[#out + 1] = "’"
        else
          sgl, sgl_inside = true, dbl
          out[#out + 1] = dbl and "“" or "‘"
        end
      elseif sgl then
        sgl = false
        out[#out + 1] = sgl_inside and "”" or "’"
      else
        out[#out + 1] = "’"
      end
    else
      out[#out + 1] = ch
    end
    ::continue::
  end
  return table.concat(out)
end

function M.range(buf, l1, l2)
  local lines = vim.api.nvim_buf_get_lines(buf, l1 - 1, l2, false)
  local changed = 0
  for i, l in ipairs(lines) do
    if not l:match("^#") and not l:match("^%-%-%-$") and not l:match("^%* %* %*$") then
      local n = M.line(l)
      if n ~= l then
        lines[i] = n
        changed = changed + 1
      end
    end
  end
  vim.api.nvim_buf_set_lines(buf, l1 - 1, l2, false, lines)
  vim.notify(("Typeset: %d paragraph%s changed"):format(changed, changed == 1 and "" or "s"))
end

-- Insert-mode autocorrect ---------------------------------------------------

local function before_cursor(n)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line():sub(1, col)
  local c = M.chars(line)
  local t = {}
  for i = math.max(1, #c - n + 1), #c do
    t[#t + 1] = c[i]
  end
  return t
end

local BS = vim.api.nvim_replace_termcodes("<BS>", true, false, true)

function M.attach(buf)
  local map = function(lhs, fn)
    vim.keymap.set("i", lhs, fn, { buffer = buf, expr = true, replace_keycodes = false, desc = "Novel typography" })
  end
  -- ' opens ‘ after a space or opener, otherwise it is ’ (closing quote or apostrophe)
  map("'", function()
    local p = before_cursor(1)[1]
    return (space(p) or OPENERS[p]) and "‘" or "’"
  end)
  -- " is the quote inside dialogue: “ … ”
  map('"', function()
    local p = before_cursor(1)[1]
    return (space(p) or OPENERS[p]) and "“" or "”"
  end)
  -- .. + . → …
  map(".", function()
    local b = before_cursor(2)
    if b[1] == "." and b[2] == "." then
      return BS .. BS .. "…"
    end
    return "."
  end)
  -- space-hyphen-hyphen → en dash; a third hyphen turns it into an em dash
  map("-", function()
    local b = before_cursor(2)
    if b[2] == "–" then
      return BS .. "—"
    end
    if b[1] == "-" and b[2] == "-" then
      return BS .. BS .. "—"
    end
    if b[2] == "-" and space(b[1]) then
      return BS .. "–"
    end
    return "-"
  end)
end

return M

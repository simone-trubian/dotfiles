-- House-style rules for :NovelCheck, read from tools/style-rules.txt in the
-- novel folder. One rule per line, "wrong => right"; # starts a comment.
-- Matching is case-sensitive on whole words; {Name} matches any capitalised
-- word. Pure Lua (no vim.*), so it can be tested outside Neovim.
local M = {}

local NAME = {}
local CHAR = "[\1-\127\194-\244][\128-\191]*"

local function chars(s)
  local t = {}
  for ch in s:gmatch(CHAR) do
    t[#t + 1] = ch
  end
  return t
end
M.chars = chars

-- letters and digits, including two-byte Latin-1, Greek and Cyrillic letters
local function is_word(ch)
  if not ch then
    return false
  end
  if #ch == 1 then
    return ch:match("^%w$") ~= nil
  end
  local b = ch:byte(1)
  return #ch == 2 and b >= 195 and b <= 223
end

local function is_upper(ch)
  if not ch then
    return false
  end
  if #ch == 1 then
    return ch:match("^%u$") ~= nil
  end
  local b1, b2 = ch:byte(1, 2)
  return #ch == 2 and ((b1 == 195 and b2 >= 128 and b2 <= 158 and b2 ~= 151) or (b1 == 208 and b2 >= 128 and b2 <= 175))
end

--- Parse the text of a rules file into a list of rules.
function M.parse(text)
  local rules = {}
  local n = 0
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    n = n + 1
    line = line:gsub("\r$", "")
    if not line:match("^%s*#") then
      local wrong, right = line:match("^%s*(.-)%s*=>%s*(.-)%s*$")
      if wrong and wrong ~= "" then
        local toks, rest = {}, wrong
        while #rest > 0 do
          if rest:sub(1, 6) == "{Name}" then
            toks[#toks + 1] = NAME
            rest = rest:sub(7)
          else
            local ch = rest:match("^" .. CHAR) or rest:sub(1, 1)
            toks[#toks + 1] = ch
            rest = rest:sub(#ch + 1)
          end
        end
        rules[#rules + 1] = { wrong = wrong, right = right, toks = toks, line = n }
      end
    end
  end
  return rules
end

local cache = {}
--- Rules from <root>/tools/style-rules.txt (empty list if there is none).
function M.load(root)
  local path = root .. "/tools/style-rules.txt"
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local text = f:read("*a")
  f:close()
  if cache.text ~= text then
    cache.text, cache.rules = text, M.parse(text)
  end
  return cache.rules
end

local function match_at(c, k, toks)
  local j = k
  for _, t in ipairs(toks) do
    if t == NAME then
      if not is_upper(c[j]) then
        return nil
      end
      j = j + 1
      while c[j] and is_word(c[j]) do
        j = j + 1
      end
    else
      if c[j] ~= t then
        return nil
      end
      j = j + 1
    end
  end
  return j - 1
end

--- Matches in a line given as a list of characters.
--- Returns a list of { k = first character, e = last character, rule = rule }.
function M.check_chars(c, rules)
  local hits = {}
  for _, r in ipairs(rules) do
    local first, last = r.toks[1], r.toks[#r.toks]
    local before = first == NAME or is_word(first)
    local after = last == NAME or is_word(last)
    for k = 1, #c do
      if (first == NAME and is_upper(c[k])) or c[k] == first then
        local e = match_at(c, k, r.toks)
        if e and not (before and is_word(c[k - 1])) and not (after and is_word(c[e + 1])) then
          hits[#hits + 1] = { k = k, e = e, rule = r }
        end
      end
    end
  end
  return hits
end

return M

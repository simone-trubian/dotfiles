-- :NovelMerge appends the checked Previous Chapter.md to Manuscript.md,
-- moves Current Chapter.md into Previous Chapter.md and starts a new
-- Current Chapter.md. :NovelBuild makes the submission .docx.
local novel = require("novel")
local check = require("novel.check")
local M = {}

local function write(path, text)
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
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

local function strip(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function git(root, args)
  local r = vim.system(vim.list_extend({ "git", "-C", root }, args), { text = true }):wait()
  return r.code == 0, (r.stdout or "") .. (r.stderr or "")
end

function M.merge()
  local root = novel.root_or_warn()
  if not root then
    return
  end
  local p = function(name)
    return root .. "/" .. novel.files[name]
  end

  -- unsaved edits would be lost or skipped
  for _, name in ipairs({ "master", "previous", "current" }) do
    local buf = vim.fn.bufnr(p(name))
    if buf ~= -1 and vim.bo[buf].modified then
      vim.notify(novel.files[name] .. " has unsaved changes: save it first", vim.log.levels.ERROR)
      return
    end
  end

  local last = check.last_chapter(root)
  local n = last + 1
  local e, w = check.file(root, p("previous"), { expect = n })
  if e > 0 then
    vim.cmd("copen")
    vim.notify(("Merge stopped: %d error%s in %s"):format(e, e == 1 and "" or "s", novel.files.previous), vim.log.levels.ERROR)
    return
  end
  local question = ("Merge chapter %d into %s?"):format(n, novel.files.master)
  if w > 0 then
    vim.cmd("copen")
    question = ("%d warning%s (listed in the quickfix window). %s"):format(w, w == 1 and "" or "s", question)
  end
  if vim.fn.confirm(question, "&Merge\n&Cancel", 2) ~= 1 then
    vim.notify("Merge cancelled")
    return
  end

  local master = read(p("master"))
  local previous = strip(read(p("previous")))
  local current = read(p("current")) or ""
  local cur_heads = check.headings(vim.split(current, "\n", { plain = true }))
  local next_n = (cur_heads[1] and cur_heads[1].n or n + 1) + 1

  write(p("master"), master:gsub("%s+$", "") .. "\n\n" .. previous .. "\n")
  write(p("previous"), strip(current) .. "\n")
  write(p("current"), ("# %d\n\n"):format(next_n))
  vim.cmd("checktime")
  vim.fn.setqflist({}, "r", { title = "Novel check", items = {} })

  local msg = ("Merged chapter %d. Previous Chapter.md is now chapter %d; Current Chapter.md starts chapter %d."):format(
    n, next_n - 1, next_n)
  if vim.uv.fs_stat(root .. "/.git") then
    git(root, { "add", "--", novel.files.master, novel.files.previous, novel.files.current })
    local ok, out = git(root, { "commit", "-m", ("Merge chapter %d"):format(n) })
    msg = msg .. (ok and " Saved in git." or (" Git commit failed: " .. out))
  end
  vim.notify(msg)
end

function M.build()
  local root = novel.root_or_warn()
  if not root then
    return
  end
  if vim.fn.executable("pandoc") == 0 then
    vim.notify("pandoc is not installed (brew install pandoc)", vim.log.levels.ERROR)
    return
  end
  vim.notify("Building the manuscript…")
  vim.system({ "sh", root .. "/tools/build.sh" }, { text = true, cwd = root }, function(r)
    vim.schedule(function()
      if r.code == 0 then
        vim.notify("Built " .. vim.trim(r.stdout))
      else
        vim.notify("Build failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

return M

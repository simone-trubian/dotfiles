-- Novel workflow: house-style typing, checks, chapter merge and manuscript build.
-- Active for Markdown files inside a novel folder: a folder that holds
-- Manuscript.md and a tools/ directory.
local M = {}

M.files = {
  master = "Manuscript.md",
  previous = "Previous Chapter.md",
  current = "Current Chapter.md",
  outline = "Outline.md",
  spell = "tools/spell/en.utf-8.add",
}

--- Novel folder that contains `path`, or nil.
function M.root(path)
  path = path and path ~= "" and path or vim.api.nvim_buf_get_name(0)
  local start = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()
  local found = vim.fs.find(M.files.master, { upward = true, path = start, type = "file" })[1]
  if not found then
    return nil
  end
  local dir = vim.fs.dirname(found)
  if vim.uv.fs_stat(dir .. "/tools") then
    return dir
  end
end

function M.root_or_warn()
  local root = vim.b.novel_root or M.root()
  -- e.g. called from the quickfix window: use a novel buffer that is open
  if not root then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      root = root or vim.b[vim.api.nvim_win_get_buf(win)].novel_root
    end
  end
  if not root then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      root = root or (vim.api.nvim_buf_is_loaded(buf) and vim.b[buf].novel_root or nil)
    end
  end
  if not root then
    vim.notify("Not inside a novel folder (needs Manuscript.md and tools/)", vim.log.levels.WARN)
  end
  return root
end

--- Spell file kept with the novel, so names added with `zg` travel with it.
local function setup_spell(root)
  -- the novel is British English only, whatever the global 'spelllang'
  vim.opt_local.spelllang = { "en_gb" }
  vim.opt_local.spell = true
  local add = root .. "/tools/spell/en.utf-8.add"
  if not vim.uv.fs_stat(add) then
    return
  end
  local spl = vim.uv.fs_stat(add .. ".spl")
  local src = vim.uv.fs_stat(add)
  if not spl or spl.mtime.sec < src.mtime.sec then
    vim.cmd("silent! mkspell! " .. vim.fn.fnameescape(add))
  end
  vim.opt_local.spellfile = add
end

function M.setup_buffer(buf)
  local root = M.root(vim.api.nvim_buf_get_name(buf))
  if not root then
    return
  end
  vim.b[buf].novel_root = root
  vim.api.nvim_buf_call(buf, function()
    setup_spell(root)
  end)
  require("novel.typeset").attach(buf)
  -- strip trailing spaces on save: they are Markdown hard line breaks
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    group = vim.api.nvim_create_augroup("novel_trim_" .. buf, { clear = true }),
    callback = function()
      local view = vim.fn.winsaveview()
      vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
      vim.fn.winrestview(view)
    end,
  })
end

-- :help novel — build the help tags for ~/.config/nvim/doc when needed
local function helptags()
  local doc = vim.fn.stdpath("config") .. "/doc"
  local txt, tags = vim.uv.fs_stat(doc .. "/novel.txt"), vim.uv.fs_stat(doc .. "/tags")
  if txt and (not tags or tags.mtime.sec < txt.mtime.sec) then
    pcall(vim.cmd.helptags, vim.fn.fnameescape(doc))
  end
end

function M.setup()
  helptags()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    group = vim.api.nvim_create_augroup("novel", { clear = true }),
    callback = function(ev)
      M.setup_buffer(ev.buf)
    end,
  })
  -- buffers already open when this runs (it loads on VeryLazy)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
      M.setup_buffer(buf)
    end
  end

  vim.api.nvim_create_user_command("Typeset", function(opts)
    require("novel.typeset").range(0, opts.line1, opts.line2)
  end, { range = "%", desc = "Novel: curly UK quotes, ellipses and dashes" })

  vim.api.nvim_create_user_command("NovelCheck", function(opts)
    require("novel.check").run(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", complete = "file", desc = "Novel: check a chapter (default: Previous Chapter.md)" })

  vim.api.nvim_create_user_command("NovelMerge", function()
    require("novel.merge").merge()
  end, { desc = "Novel: check Previous Chapter.md, append it to Manuscript.md, rotate chapter files" })

  vim.api.nvim_create_user_command("NovelCommit", function(opts)
    require("novel.merge").commit(opts.args)
  end, { nargs = "?", desc = "Novel: commit Outline.md and the spell list" })

  vim.api.nvim_create_user_command("NovelBuild", function()
    require("novel.merge").build()
  end, { desc = "Novel: build the submission .docx with pandoc" })
end

return M

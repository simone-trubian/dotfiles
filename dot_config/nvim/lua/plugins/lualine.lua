-- Word count in the status bar for Markdown files: "2,338 words", or
-- "142 / 2,338 words" while text is selected.

local function thousands(n)
  return (tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

-- recount only after an edit, not on every redraw
local function total()
  local tick = vim.b.changedtick
  if vim.b.word_count_tick ~= tick then
    vim.b.word_count = vim.fn.wordcount().words
    vim.b.word_count_tick = tick
  end
  return vim.b.word_count
end

local function word_count()
  if vim.fn.mode():find("^[vV\22]") then
    local wc = vim.fn.wordcount()
    return ("%s / %s words"):format(thousands(wc.visual_words or 0), thousands(wc.words))
  end
  return thousands(total()) .. " words"
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_y, 1, {
      word_count,
      cond = function()
        return vim.bo.filetype == "markdown"
      end,
    })
  end,
}

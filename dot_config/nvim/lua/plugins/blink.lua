-- No completion popup in Markdown: it gets in the way of writing prose.
-- Command-line completion is unaffected (blink.cmp checks it separately).
return {
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      return vim.bo.filetype ~= "markdown"
    end,
  },
}

-- The Markdown extra (lazyvim.json) is here for its rendering: render-markdown
-- in the buffer (<leader>um) and markdown-preview in the browser (<leader>cp).
-- Its markdownlint warnings and format-on-save would rewrite and flag prose,
-- so both are off for Markdown.

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = nil
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.markdown = nil
      opts.formatters_by_ft["markdown.mdx"] = nil
    end,
  },
}

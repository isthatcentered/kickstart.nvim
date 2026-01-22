return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {},
    opts = {
      lsp_format = 'never',
      format_on_save = false,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        rust = { 'rustfmt', lsp_format = 'fallback' },
        typescript = { 'prettierd', 'prettier', 'biome', stop_after_first = false },
        typescriptreact = { 'prettierd', 'prettier', 'biome', stop_after_first = false },
        javascript = { 'prettierd', 'prettier' },
        json = { 'jq' },
      },
    },
  },
}

return {
  {
    dir = '/Users/edouardpenin/Test/nvim/refactor.nvim',
    name = 'refactor.nvim',
    keys = {
      {
        'grq',
        function()
          local Refactor = require 'refactor'

          Refactor.typescript.replace_with_template_string(Refactor.context())
        end,
        desc = 'Replace with template string',
      },
      {
        'grif',
        function()
          local Refactor = require 'refactor'

          Refactor.typescript.inline_function(Refactor.context())
        end,
        desc = 'Inline function',
      },
    },
  },
  -- { dir = '/Users/edouardpenin/Test/nvim/acid.nvim', lazy = true, opts = {}, priority = 1000 },
}

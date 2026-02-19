local LazyDev = {
  'folke/lazydev.nvim',
  ft = 'lua', -- only load on lua files
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  },
}
local Refactoring = {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  lazy = false,
  config = function()
    require('refactoring').setup()
    -- vim.keymap.set("x", "gre", ":Refactor extract ")
    -- vim.keymap.set("x", "", ":Refactor extract_to_file ")

    vim.keymap.set('x', 'gre', ':Refactor extract_var ')

    vim.keymap.set({ 'n' }, 'gri', ':Refactor inline_var')

    -- vim.keymap.set( "n", "<leader>rI", ":Refactor inline_func")

    -- vim.keymap.set("n", "<leader>rb", ":Refactor extract_block")
    -- vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file")
  end,
}
local VTSLS = { 'yioneko/nvim-vtsls' }

-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
local TreeSitter = {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate', -- Rebuild tree sitter on update
  config = function()
    -- No need to call setup when using the default config
    local languages = {
      'c', --
      'lua',
      'vim',
      'vimdoc',
      'query',
      'markdown',
      'markdown_inline',
      'json',
      'javascript',
      'tsx',
      'jsx',
      'typescript',
      'toml',
      'php',
      'json',
      'yaml',
      'css',
      'html',
    }

    require('nvim-treesitter').install(languages)
    require('nvim-treesitter').update(languages)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = languages,
      callback = function()
        vim.treesitter.start()
        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end,
    })
  end,
}

local TreesitterTextObjects = {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
}
local LANGUAGE_SERVERS = {
  'ast-grep',
  'biome',
  'eslint-lsp',
  'eslint_d',
  'prettier',
  'prettierd',
  'typescript-language-server',
  'vtsls',
  'emmet-language-server',
  'tailwindcss-language-server',
}

local LSP = {
  'neovim/nvim-lspconfig',
  -- commit = '782dda984da54e465dcc142544133606139d0306',
  dependencies = {
    -- Package manager for lsp/formatters/linters
    {
      'mason-org/mason.nvim',
      opts = {
        ensure_installed = {
          'ast-grep',
          'jq',
          'biome',
          'eslint-lsp',
          'eslint_d',
          'prettier',
          'prettierd',
          'typescript-language-server',
          'vtsls',
          'emmet-language-server',
          'tailwindcss-language-server',
        },
      },
    },
    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- Completions
    -- https://github.com/Saghen/blink.cmp
    {
      'saghen/blink.cmp',

      dependencies = {
        'L3MON4D3/LuaSnip',
        -- follow latest release.
        version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = 'make install_jsregexp',
      },

      build = 'cargo build --release',

      opts = {
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap

        keymap = {
          preset = 'enter',
          ['<C-s>'] = {
            function(cmp)
              cmp.show()
            end,
          },
          ['<C-a>'] = {
            function(cmp)
              cmp.show_signature()
            end,
          },
        },

        completion = {
          menu = {
            auto_show = true,
            border = 'rounded',

            draw = {
              columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind', gap = 1 } },
              treesitter = { 'lsp' },
            },
          },

          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
            window = { border = 'rounded' },
          },

          -- ghost_text = { enabled = true },
        },

        signature = {
          window = { border = 'rounded', show_documentation = true },
          enabled = true,
          trigger = {
            -- Show the signature help automatically
            enabled = false,
            -- Show the signature help window after typing any of alphanumerics, `-` or `_`
            show_on_keyword = true,
            blocked_trigger_characters = {},
            blocked_retrigger_characters = {},
            -- Show the signature help window after typing a trigger character
            show_on_trigger_character = true,
            -- Show the signature help window when entering insert mode
            show_on_insert = false,
            -- Show the signature help window when the cursor comes after a trigger character when entering insert mode
            show_on_insert_on_trigger_character = true,
          },
        },

        snippets = { preset = 'luasnip' },

        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        fuzzy = { implementation = 'prefer_rust_with_warning' },
      },

      opts_extend = { 'sources.default' },
    },
  },
  config = function()
    local language_servers = {
      'lua_ls',
      -- 'eslint',
      -- 'biome',
      -- 'ts_ls',
      'vtsls',
      'emmet_language_server',
      'jsonls',
    }

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities.textDocument.completion.completionItem = {
      documentationFormat = { 'markdown', 'plaintext' },
      snippetSupport = true,
      preselectSupport = true,
      insertReplaceSupport = true,
      labelDetailsSupport = true,
      deprecatedSupport = true,
      commitCharactersSupport = true,
      tagSupport = { valueSet = { 1 } },
      resolveSupport = {
        properties = {
          'documentation',
          'detail',
          'additionalTextEdits',
        },
      },
    }

    vim.lsp.config('*', { capabilities = capabilities })

    require('lspconfig.configs').vtsls = require('vtsls').lspconfig
    vim.lsp.config('vtsls', {
      settings = {
        vtsls = {
          enableMoveToFileCodeAction = true,
        },
        typescript = {
          tsserver = {
            maxTsServerMemory = 8192,
          },
          updateImportsOnFileMove = {
            enabled = 'always',
          },
          referencesCodeLens = {
            enabled = true,
            showOnAllFunctions = true,
            showOnInterfaceMethods = true,
          },
          preferences = {
            importModuleSpecifier = 'non-relative',
          },
        },
      },
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          workspace = {
            checkThirdParty = false,
            ignoreDir = { '__lua__', '.git', 'node_modules', '.dist', '.temp' },
          },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config('ts_ls', {
      settings = {
        supportsMoveToFileCodeAction = true,
        -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md#preferences-options
        preferences = {
          importModuleSpecifierPreference = 'relative',
          maximumHoverLength = 1000,
        },
      },
      init_options = {
        supportsMoveToFileCodeAction = true,
        -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md#preferences-options
        preferences = {
          importModuleSpecifierPreference = 'relative',
          maximumHoverLength = 1000,
        },
      },
    })

    vim.lsp.commands['editor.action.showReferences'] = function(command, ctx)
      local locations = command.arguments[3]
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if locations and #locations > 0 then
        local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
        vim.fn.setloclist(0, {}, ' ', { title = 'References', items = items, context = ctx })
        vim.api.nvim_command 'lopen'
      end
    end

    for _, ls in pairs(language_servers) do
      vim.lsp.enable(ls)
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grr', vim.lsp.buf.rename, '[R]efactor [R]ename')

        map('gra', vim.lsp.buf.code_action, '[R]efactor [A]ctions', { 'n', 'x' })

        map('glr', function()
          require('telescope.builtin').lsp_references { jump_type = 'never' }
        end, '[L]ens [R]eferences')

        map('gli', function()
          require('telescope.builtin').lsp_implementations { jump_type = 'never' }
        end, '[L]ens [I]mplementation')

        --  To jump back, press <C-t>.
        map('gld', function()
          require('telescope.builtin').lsp_definitions { jump_type = 'never' }
        end, '[G]oto [D]efinition')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('glD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        map('gls', require('telescope.builtin').lsp_document_symbols, '[L]ens [S]ymbols')

        map('glws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[L]ens [W]orkspace [S]ymbols')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('glt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        -- vim.print(vim.fn.getcompletion('@lsp', 'highlight'))
        -- for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
        --   vim.api.nvim_set_hl(0, group, {})
        -- end

        -- Highlight word under cursor
        --
        -- local original_handler = vim.lsp.handlers['textDocument/rename']
        -- vim.lsp.handlers['textDocument/rename'] = function(err, method, result, ...)
        --   vim.print 'Calling rename'
        --   original_handler(err, method, result, ...)
        --   vim.print 'Reame done:::'
        -- end
        --

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange, event.buf) then
          vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end,
    })
  end,
}

return {
  VTSLS,
  LazyDev,
  TreeSitter,
  TreesitterTextObjects,
  Refactoring,
  LSP,
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'python' } },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'pyright' } },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'basic',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'openFilesOnly',
              },
            },
          },
        },
      },
    },
  },
}

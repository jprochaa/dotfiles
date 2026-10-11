return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'c_sharp' } },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        omnisharp = {
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
        },
      },
    },
  },
}

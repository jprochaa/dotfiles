return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>a', '<cmd>AerialToggle!<CR>', desc = 'Toggle Aerial (code outline)' },
  },
  opts = {
    -- Attach to the window rather than the buffer so it follows splits
    attach_mode = 'window',
    -- Show the outline panel on the right
    layout = { default_direction = 'prefer_right' },
  },
}

return {
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- must hook BufReadCmd for *.ipynb before any notebook is opened
    opts = {
      style = "percent", -- # %% cell markers
      output_extension = "auto", -- buffer treated as .py for python kernels
      force_ft = nil, -- derive filetype from notebook metadata
    },
  },
}

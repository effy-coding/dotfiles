return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        "dist/",
        "build/",
        ".next/",
        "%.lock",
        "%-lock.json",
      },
    },
  },
}

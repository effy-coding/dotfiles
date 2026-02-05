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
    pickers = {
      find_files = {
        hidden = true, -- 숨김 파일(.dotfiles) 포함
      },
      live_grep = {
        additional_args = { "--hidden" }, -- ripgrep에 --hidden 옵션 추가
      },
    },
  },
}

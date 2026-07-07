-- Fuzzy finder, backed by ripgrep for both file listing and content search.
local home_code_globs = {
  -- extensions
  "*.py",
  "*.ipynb",
  "*.rb",
  "*.sh",
  "*.bash",
  "*.zsh",
  "*.c",
  "*.h",
  "*.cc",
  "*.cpp",
  "*.hpp",
  "*.hxx",
  "*.js",
  "*.jsx",
  "*.mjs",
  "*.cjs",
  "*.ts",
  "*.tsx",
  "*.lua",
  "*.go",
  "*.rs",
  "*.html",
  "*.htm",
  "*.css",
  "*.scss",
  "*.json",
  "*.jsonc",
  "*.yaml",
  "*.yml",
  "*.toml",
  "*.md",
  "*.sql",
  -- common extensionless project files
  "Makefile",
  "Dockerfile*",
  "Rakefile",
  "Gemfile",
}

local home_ignore_dirs = {
  "node_modules",
  ".git",
  ".cache",
  ".local",
  ".npm",
  ".cargo",
  ".rustup",
  "venv",
  ".venv",
  "__pycache__",
  "dist",
  "build",
  "target",
  "Downloads",
  "Pictures",
  "Videos",
  "Music",
  ".Trash",
}

local function home_find_command()
  local cmd = { "rg", "--files", "--hidden" }
  for _, dir in ipairs(home_ignore_dirs) do
    table.insert(cmd, "--glob")
    table.insert(cmd, "!" .. dir .. "/**")
  end
  for _, pattern in ipairs(home_code_globs) do
    table.insert(cmd, "--glob")
    table.insert(cmd, pattern)
  end
  return cmd
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  keys = {
    {
      "<leader>f",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find files (repo/cwd)",
    },
    {
      "<leader>g",
      function()
        require("telescope.builtin").find_files({
          prompt_title = "Find Files (~, code only)",
          cwd = vim.env.HOME,
          find_command = home_find_command(),
        })
      end,
      desc = "Find files ($HOME, code only)",
    },
    {
      "<leader>h",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Live grep (repo/cwd)",
    },
  },
  opts = {
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
    },
  },
}

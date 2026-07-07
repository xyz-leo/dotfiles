-- Real syntax highlighting. Without this, Neovim falls back to each
-- filetype's legacy regex syntax file, which lumps most keywords,
-- imports, and control-flow words into one or two highlight groups —
-- that's what made everything look red. Treesitter gives fine-grained
-- capture groups (@function, @variable, @keyword, ...) instead.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ensure_installed = {
      "bash",
      "python",
      "ruby",
      "c",
      "cpp",
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "lua",
      "vim",
      "vimdoc",
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
    }
    require("nvim-treesitter").install(ensure_installed)

    -- Try to start treesitter highlighting for every filetype; silently
    -- no-ops where a parser isn't installed instead of erroring.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}

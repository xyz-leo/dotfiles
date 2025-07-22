-- HTML Boilerplate
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.html",
  callback = function()
    local lines = {
      "<!-- Filename: " .. vim.fn.expand("%:t") .. "-->",
      "",
      "<!DOCTYPE html>",
      "<html lang=\"en\">",
      "<head>",
      "  <meta charset=\"UTF-8\">",
      "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
      "  <link rel=\"stylesheet\" href=\"styles.css\">",
      "  <title>Document</title>",
      "</head>",
      "<body>",
      "",
      "  <script src=\"script.js\"></script>",
      "</body>",
      "</html>",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end,
})

-- JavaScript Boilerplate
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.js",
  callback = function()
    local lines = {
      "// Filename: " .. vim.fn.expand("%:t"),
      "",
      "'use strict';",
      "",
      "function main() {",
      "  console.log('Hello, world!');",
      "}",
      "",
      "main();",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end,
})

-- CSS Boilerplate 62.5 rem trick included
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.css",
  callback = function()
    local lines = {
      "/* Filename: " .. vim.fn.expand("%:t") .. " */",
      "",
      "html {",
      "  font-size: 62.5%; /* 1rem = 10px */",
      "}",
      "",
      "body {",
      "  margin: 0;",
      "  padding: 0;",
      "  background-color: #121212;",
      "  color: #eee;",
      "  font-family: sans-serif;",
      "  font-size: 1.6rem; /* = 16px */",
      "}",
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  end,
})


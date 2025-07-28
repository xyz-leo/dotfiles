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
      "* {",
      "  margin: 0;",
      "  padding: 0;",
      "  box-sizing: border-box;",
      "}",
      "",
      "html {",
      "  font-size: 62.5%; /* 1rem = 10px */",
      "  scroll-behavior: smooth;",
      "}",
      "",
      "body {",
      "  background-color: #121212;",
      "  color: #eee;",
      "  font-family: sans-serif;",
      "  font-size: 1.6rem; /* = 16px */",
      "  line-height: 1.5;",
      "  -webkit-font-smoothing: antialiased;",
      "}",
      "",
      "h1, h2, h3, h4, h5, h6 {",
      "  font-weight: 600;",
      "  line-height: 1.2;",
      "  color: inherit;",
      "}",
      "",
      "a {",
      "  color: inherit;",
      "  text-decoration: none;",
      "}",
      "",
      "ul, ol {",
      "  list-style: none;",
      "}",
      "",
      "img, picture, video, canvas, svg {",
      "  max-width: 100%;",
      "  display: block;",
      "}",
      "",
      "button, input, textarea, select {",
      "  font: inherit;",
      "  color: inherit;",
      "  background: none;",
      "  border: none;",
      "  outline: none;",
      "}",
      "",
      "input[type=\"number\"]::-webkit-inner-spin-button,",
      "input[type=\"number\"]::-webkit-outer-spin-button {",
      "  -webkit-appearance: none;",
      "  margin: 0;",
      "}",
      "",
      "body, html {",
      "  min-height: 100%;",
      "  width: 100%;",
      "}",
      }
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end,
})


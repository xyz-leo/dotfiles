-- Completion UI. LSP servers only report *what* can be completed;
-- this is what actually shows the popup and lets you accept an item.
return {
  "saghen/blink.cmp",
  version = "1.*", -- pinned to tagged releases that ship a prebuilt fuzzy-matcher binary
  opts = {
    keymap = {
      -- super-tab: <Tab> accepts the selected item (or jumps a snippet
      -- placeholder if one's active); <CR> also accepts explicitly.
      -- Neither key does anything special when the menu isn't open.
      preset = "super-tab",
      ["<CR>"] = { "accept", "fallback" },
    },
    sources = {
      default = { "lsp", "path", "buffer", "snippets" },
    },
  },
}

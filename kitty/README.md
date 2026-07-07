# kitty config — shortcuts reference

Theme: **Ruby Noir** (dark, muted ruby/red accents, transparent + blurred background)
Font: **JetBrainsMono Nerd Font**, size 13.5

All shortcuts below are defined in `kitty.conf`. Kitty auto-reloads the config on save.

> **Why Alt instead of Super:** on Cinnamon, `Super` is claimed by the desktop environment for
> window-manager shortcuts (workspaces, window snapping, etc.), so `Super`-based kitty bindings
> get intercepted before kitty ever sees them. Everything below uses `Alt` instead. The only
> exception is **`Super+T`** for opening a new tab, kept as requested.

## Panes (splits)

Kitty calls panes within a tab "windows". The `splits` layout lets you freely split horizontally/vertically.

| Shortcut | Action |
|---|---|
| `Alt+Shift+D` | Split horizontally (new pane below) |
| `Alt+Shift+R` | Split vertically (new pane beside) |
| `Alt+←` / `Alt+→` / `Alt+↑` / `Alt+↓` | Move **focus** to the pane in that direction |
| `Ctrl+Alt+←` / `→` / `↑` / `↓` | Move the focused **pane's position** in that direction |
| `Alt+W` | Close the focused pane |
| `Alt+]` | Cycle to next pane |
| `Alt+[` | Cycle to previous pane |
| `Alt+Z` | Toggle zoom (fullscreen focused pane / restore layout) |

### Resizing panes

| Shortcut | Action |
|---|---|
| `Alt+Shift+←` | Make focused pane narrower |
| `Alt+Shift+→` | Make focused pane wider |
| `Alt+Shift+↑` | Make focused pane taller |
| `Alt+Shift+↓` | Make focused pane shorter |
| `Ctrl+Alt+R` | Reset pane sizes to default |

Since `Alt+Arrows` is used for moving focus, resizing lives on `Alt+Shift+Arrows`, and moving a
pane's position (a much rarer action) got bumped to `Ctrl+Alt+Arrows`.

## Layouts

Enabled layouts: `splits`, `stack`, `tall`, `fat`. `Alt+Z` toggles into stack (fullscreen) mode for quick focus.

## Tabs

Tabs are separate from panes — each tab can contain its own arrangement of split panes.

| Shortcut | Action |
|---|---|
| `Super+T` | New tab |
| `Alt+Shift+W` | Close current tab |
| `Alt+1` … `Alt+5` | Jump to tab 1–5 |
| `Alt+Shift+]` | Next tab |
| `Alt+Shift+[` | Previous tab |
| `Alt+Shift+T` | Rename current tab |

## Font size

| Shortcut | Action |
|---|---|
| `Alt++` | Increase font size |
| `Alt+-` | Decrease font size |
| `Alt+0` | Reset font size |

## Config

| Shortcut | Action |
|---|---|
| `Alt+Shift+F5` | Reload config manually |
| `Alt+Shift+E` | Open `kitty.conf` in your `$EDITOR` |

## Not yet configured (possible future additions)

- **Startup sessions** — a `session.conf` that defines a saved tab/pane layout with preset commands, launched via `kitty --session`.
- **Remote control** (`allow_remote_control`) — lets external scripts create/resize/close panes programmatically (useful for custom automation or status-bar integrations).

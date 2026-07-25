![LazaroBox.nvim](./lazarobox-nvim.png)

# 🟥 LazaroBox.nvim

```text
[ LZBOX ] :: signal > noise*Signal over noise.*
```

A cyberpunk-inspired Neovim colorscheme built on top of Catppuccin, designed for clarity, contrast, and long coding sessions.

> ⚡ For the full experience, pair it with the official WezTerm config.

---

<p align="center">
    <img src="./lazarobox-home.png" alt="LazaroBox preview"/>
</p>

---

## 🚀 Quick Start

One command installs the Nerd Font, the external tools the config needs, and links
everything into place. No manual font copying, no `fc-cache`, no extra steps.

**Linux · macOS · WSL**

```bash
git clone https://github.com/pichu2707/lazarobox-nvim.git
cd lazarobox-nvim
./install.sh
```

**Windows (PowerShell)**

```powershell
git clone https://github.com/pichu2707/lazarobox-nvim.git
cd lazarobox-nvim
.\install.ps1
```

Then restart your terminal, select **JetBrainsMono Nerd Font** as its font, and open
`nvim`. Plugins install themselves on first launch.

Verify the result at any time with `:checkhealth lazarobox`.

### What the installer does

| Step | Detail |
| --- | --- |
| Nerd Font | Downloads JetBrainsMono Nerd Font and **registers** it, so the system actually sees it |
| Dependencies | `ripgrep`, `fd`, `imagemagick`, `chafa`, `node`, a C compiler — detected via apt, pacman, dnf, zypper, brew or winget |
| Clipboard | `xclip` on X11, `wl-clipboard` on Wayland, `win32yank.exe` on WSL, native on macOS |
| Config | Links the repository into `~/.config/nvim` (`%LOCALAPPDATA%\nvim` on Windows), backing up anything already there |
| Git hooks | Runs `scripts/install-hooks.sh` |

The installer is **idempotent** — re-running it skips whatever is already in place, so
it is safe to use to repair a broken setup.

### Options

| Flag | Effect |
| --- | --- |
| `--fonts-only` | Install just the Nerd Font |
| `--no-deps` | Skip system packages |
| `--no-link` | Do not touch `~/.config/nvim` |
| `-y`, `--yes` | Answer yes to everything |

On Windows the equivalents are `-FontsOnly`, `-NoDeps`, `-NoLink` and `-Yes`.

### Why downloading a font is not installing it

A font only exists for your applications once it lives in a directory the system scans
**and** the font index has been refreshed. Downloading a `.ttf` to your Downloads folder
does neither. Each platform differs:

| Platform | Where it goes | What registers it |
| --- | --- | --- |
| Linux | `~/.local/share/fonts` | `fc-cache -f` |
| macOS | `~/Library/Fonts` | Core Text scans it automatically |
| Windows | `%LOCALAPPDATA%\Microsoft\Windows\Fonts` | A registry entry under `HKCU` |
| WSL | **the Windows host** | See below |

> [!IMPORTANT]
> **WSL users:** your terminal is a *Windows* application, so Windows renders the glyphs.
> Installing the font inside your distro will not fix the boxes you see — it has to be
> installed on the Windows host. `install.sh` detects WSL and does both automatically.

---

## 🧠 Philosophy

> Prioritize signal. Suppress noise.

LazaroBox is not just a palette — it's a visual filtering layer for code.

- Reduced cognitive load via controlled contrast
- Semantic color grouping aligned with LSP scopes
- Minimal distractions, maximum readability
- Designed for long sessions in low-light environments

---

## 🎨 Palette

| Element    | Color     |
| ---------- | --------- |
| Background | `#191E28` |
| Surface    | `#1C212C` |
| Borders    | `#232A40` |
| Text       | `#F3F6F9` |
| Muted text | `#5C6170` |
| Cyan       | `#00FFFF` |
| Blue       | `#7FB4CA` |
| Purple     | `#B99BF2` |
| Mauve      | `#C99AD6` |
| Green      | `#B7CC85` |
| Yellow     | `#FFE066` |
| Gold       | `#E0C15A` |
| Red        | `#CB7C94` |
| Orange     | `#DEBA87` |

---

## 🧠 Concept

LazaroBox is built around a simple idea:

> Reduce noise. Highlight signal.

- Deep dark backgrounds
- Soft neon accents
- High contrast where it matters
- Minimal visual fatigue

Inspired by cyberpunk terminals and modern developer workflows.

---

## ⚙️ Using the colorscheme on its own

Prefer to keep your own config and only take the colours? Install LazaroBox as a plugin
instead of running the installer.

### Using lazy.nvim

```lua
{
  "pichu2707/lazarobox-nvim",
  name = "lazarobox",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      transparent_background = true,

      color_overrides = {
        all = {
          base = "#191E28",
          mantle = "#191E28",
          crust = "#232A40",

          text = "#F3F6F9",
          subtext0 = "#5C6170",
          subtext1 = "#00FFFF",

          blue = "#7FB4CA",
          mauve = "#C99AD6",
          pink = "#B99BF2",
          green = "#B7CC85",
          yellow = "#FFE066",
          rosewater = "#E0C15A",
          red = "#CB7C94",
          peach = "#DEBA87",
        },
      },
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
```

## Configuration

This theme is based on Catppuccin, using custom color overrides.

Example setup:

```lua
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,

  color_overrides = {
    all = {
      base = "#191E28",
      mantle = "#191E28",
      crust = "#232A40",

      text = "#F3F6F9",
      subtext0 = "#5C6170",
      subtext1 = "#00FFFF",

      blue = "#7FB4CA",
      mauve = "#C99AD6",
      pink = "#B99BF2",
      green = "#B7CC85",
      yellow = "#FFE066",
      rosewater = "#E0C15A",
      red = "#CB7C94",
      peach = "#DEBA87",
    },
  },
})

vim.cmd.colorscheme("catppuccin")
```

## ⚡ Features

- Transparent background first-class support
- Tuned for Treesitter + LSP highlights
- Balanced saturation (no retina burn)
- Functional color semantics (not decorative)
- Compatible with modern plugin ecosystems

---

## 🧩 Ecosystem

LazaroBox is designed as part of a cohesive terminal experience.

### 🖥️ Neovim

- LazaroBox.nvim (this repository)
- Optimized for Treesitter, LSP and modern workflows

### 🟧 WezTerm

To fully experience the intended visual environment, use the matching WezTerm configuration:

👉 [https://github.com/pichu2707/lazarobox-wezterm](https://github.com/pichu2707/lazarobox-wezterm)

Includes:

- Matching color palette
- Transparency tuning
- Font and rendering optimizations
- Terminal-level contrast control

---

## 🔗 Recommended Setup

For best results:

- Neovim → LazaroBox.nvim
- Terminal → WezTerm config
- Background → Transparent compositor

## This combination ensures consistent color rendering across the entire stack.

## 🧬 Design Notes

- Background layers (`base`, `mantle`, `crust`) are flattened to reduce visual fragmentation
- Accent colors are scoped by syntax role (functions, types, constants, etc.)
- High-frequency elements (diagnostics, hints) use controlled emphasis
- No random color noise — every token has intent

---

## 🙏 Acknowledgements

Inspired by the work of **Gentleman-Programming**,  
especially the Kanagawa Blur aesthetic and terminal-driven workflows.

## 👤 Author

Built by Javi Lázaro
🌐 https://www.javilazaro.es

## 📜 License

MIT

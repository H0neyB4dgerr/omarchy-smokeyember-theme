# SmokeyEmber

A restrained dark theme for [Omarchy](https://omarchy.org/) built from charcoal surfaces, muted lavender structure, and focused burnt-orange accents.

![SmokeyEmber charcoal wallpaper](./backgrounds/01-smokeyember-charcoal.png)

### 32:9 ultrawide variant

These versions are composed specifically for a 5120×1440 49-inch display rather than stretching or cropping the 16:9 artwork.

![SmokeyEmber charcoal ultrawide wallpaper](./backgrounds/02-smokeyember-charcoal-5120x1440.png)

SmokeyEmber keeps Omarchy's native spacing, layout, and component behavior intact. Its identity comes from color: nearly black foundations, quiet purple borders, and small ember-orange points of focus.

## Palette

| Role | Color |
| --- | --- |
| Primary background | `#0B0B0F` |
| Surface | `#121218` |
| Raised surface | `#191820` |
| Primary foreground | `#C8C7D0` |
| Muted foreground | `#8176A5` |
| Burnt orange | `#FF6B35` |
| Dark orange | `#D9572B` |
| Lavender | `#9D7CD8` |
| Muted purple | `#8176A5` |
| Focus lavender | `#A79ABD` |
| Border / selection | `#332F3D` |

The full ANSI and semantic application palette lives in [`colors.toml`](./colors.toml).

## Compatibility

SmokeyEmber targets the semantic theme format in Omarchy 4 and was built against Omarchy `4.0.0-1`.

Omarchy renders the source palette into its current integrations when the theme is applied:

- Hyprland window and group borders
- omarchy-shell bar, launcher, menus, notifications, OSD, and lock screen
- Kitty, Foot, Ghostty, and Alacritty
- Neovim and Helix
- btop
- VS Code, VSCodium, Cursor, Chromium, Obsidian, Claude, Pi, Gum, and keyboard RGB where available

Waybar, Walker, mako, and standalone hyprlock theme files are deliberately not included. Omarchy 4 provides those desktop surfaces through omarchy-shell/Quickshell, and `colors.toml` is their supported theme source.

Kitty includes a small theme-specific refinement: ember-orange cursor and active tab, grey-lavender structure, and a warmer ANSI orange range inspired by the dark, restrained Codex palette. Other supported terminals inherit the same semantic warm colors directly from `colors.toml`.

## Local preview

From the repository root, run:

```bash
./scripts/preview-local.sh
```

The script validates the project, creates a development symlink at `~/.config/omarchy/themes/smokeyember`, remembers the current theme, applies SmokeyEmber, and restores the previous theme when you press Enter or interrupt it.

It refuses to overwrite an existing theme directory or unrelated symlink.

## Local installation

Install the development checkout without applying it:

```bash
./scripts/install-local.sh
```

Then apply it explicitly:

```bash
omarchy theme set smokeyember
```

Return to another installed theme at any time:

```bash
omarchy theme set "Tokyo Night"
```

## Installation from GitHub

After publishing the repository, users can install and apply it with Omarchy's native installer:

```bash
omarchy theme install https://github.com/Suuso/omarchy-smokeyember-theme.git
```

The repository name is intentional: Omarchy strips the `omarchy-` prefix and `-theme` suffix, installing it under the `smokeyember` slug.

## Wallpaper

The two editable SVG sources live in [`assets/wallpaper/`](./assets/wallpaper/): one 3840×2160 version and one 5120×1440 ultrawide version. Their wordmark uses the official vector geometry shipped by Omarchy and follows the compact scale of its stock wallpapers.

Both committed PNG files live in `backgrounds/`, so Omarchy automatically indexes them in the theme background carousel. Cycle between them with:

```bash
omarchy theme bg next
```

If the theme was already active while these files changed, reapply it once with `omarchy theme set smokeyember` so Omarchy refreshes its current-theme copy and carousel cache.

### Multi-monitor behavior

Omarchy 4 currently keeps one global `current/background` link. Its Quickshell background plugin creates a surface for every display, but every surface reads that same image and uses proportional cropping. A portable theme therefore cannot assign a different wallpaper to each monitor or choose an aspect ratio per output automatically.

Both aspect-ratio variants remain available in the carousel for manual selection. True simultaneous per-monitor selection would require a separate user-level omarchy-shell plugin customization and per-output background state; it is intentionally not bundled into this theme.

To regenerate both PNG files after editing the SVG sources:

```bash
./scripts/export-wallpaper.sh
```

The export script requires `rsvg-convert` from `librsvg`; it is only needed when changing the wallpaper, not when using the theme.

## Validation

Run the non-destructive checks with:

```bash
./scripts/validate.sh
```

Validation checks the shell scripts, SVG, PNG dimensions, required project files, icon theme, and Omarchy's resolution of every required semantic color.

## Screenshots

Real screenshots can be added later at these stable paths:

- `screenshots/desktop.png`
- `screenshots/launcher.png`
- `screenshots/terminal-nvim.png`

See [`screenshots/README.md`](./screenshots/README.md) for the capture notes.

## Project structure

```text
.
├── colors.toml                  # Semantic Omarchy palette
├── icons.theme                  # Yaru-purple icon integration
├── kitty.conf                   # Focused orange/lavender Kitty treatment
├── backgrounds/                 # Raster backgrounds selected by Omarchy
├── assets/wallpaper/            # Editable wallpaper source
├── docs/                         # Design decisions and resume context
├── screenshots/                 # Stable paths for real captures
└── scripts/                     # Export, validation, install, and preview helpers
```

Generated shell, editor, application, and other terminal configs are not committed. Omarchy creates them from `colors.toml` using the templates shipped by the installed version, which keeps the theme small and forward-compatible; `kitty.conf` is the sole deliberate terminal override.

## Concept

Smoke supplies the depth; lavender supplies the structure; ember orange marks attention. The result is technical and modern without becoming neon or visually noisy.

## Development context

The current visual decisions, measured wallpaper geometry, Omarchy constraints, resume workflow, and next-iteration ideas are recorded in [`docs/DESIGN-NOTES.md`](./docs/DESIGN-NOTES.md).

## License

SmokeyEmber is released under the [MIT License](./LICENSE).

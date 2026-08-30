# SmokeyEmber design notes

This document records the decisions behind the current private checkpoint so development can resume without relying on chat history.

## Checkpoint

- Date: 2026-08-15
- Target format: Omarchy 4 semantic themes
- Version inspected during creation: Omarchy `4.0.0-1`
- Theme name: `SmokeyEmber`
- Theme slug: `smokeyember`
- Repository name: `omarchy-smokeyember-theme`
- Reference display: 5120×1440, 32:9, 49-inch ultrawide

The project remains independent from the active Omarchy configuration. Local testing uses the safe development symlink created by `scripts/install-local.sh`.

## Visual direction

SmokeyEmber combines nearly black charcoal surfaces, subdued grey-lavender structure, and restrained burnt-orange interaction accents. It should feel technical, clean, modern, and sober rather than neon or ornamental.

Current key decisions:

- Focused window borders use one solid grey-lavender (`#A79ABD`). The earlier purple-to-orange gradient was removed because it felt busier than Omarchy's native aesthetic.
- Inactive borders remain quiet (`#332F3D`).
- Orange is a functional accent, not the dominant wallpaper color.
- Omarchy generates every terminal configuration from the shared semantic palette.
- The wallpaper wordmark remains muted purple on charcoal.
- The orange-wordmark-on-purple-background experiments were removed from the project and carousel.

## Wallpaper geometry

The wordmark uses the vector geometry shipped with Omarchy. Its scale was measured against a stock Omarchy wallpaper screenshot rather than estimated visually.

| Variant | Canvas | Embedded wordmark | Position |
| --- | --- | --- | --- |
| Standard | 3840×2160 | 1600×376 | x=1120, y=892 |
| Ultrawide | 5120×1440 | 2134×502 | x=1493, y=469 |

The stock reference wordmark measured approximately 2134×502 pixels on a 5120×1440 screenshot. Omarchy displays the 3840×2160 image on the 32:9 monitor using proportional crop; the resulting wordmark measures approximately 2138×506 pixels, a difference below one percent. The native ultrawide version measures approximately 2134×500 pixels after rasterization.

Only these two carousel entries currently remain:

- `backgrounds/01-smokeyember-charcoal.png`
- `backgrounds/02-smokeyember-charcoal-5120x1440.png`

Future wallpapers should be added only with clear usage rights. The intended workflow is to adapt suitable images to the existing charcoal, grey-lavender, and restrained orange identity.

A later smoke and hacker-tech wallpaper exploration was deliberately kept out of the publishable theme. Although several 4K, native-canvas, outpainted, and Real-ESRGAN variants were tested, the 5120×1440 results retained visible aliasing or reconstruction artifacts on the reference OLED display. The editable wordmark pair is therefore the quality baseline and the only wallpaper set in the repository.

## Omarchy integration decisions

- `colors.toml` is the semantic source for current Omarchy integrations.
- Kitty, Foot, Ghostty, Alacritty, Neovim, Helix, btop, Chromium, VS Code/Cursor, Obsidian, and omarchy-shell use Omarchy's installed templates.
- Separate Waybar, Walker, mako, and hyprlock files are not included because Omarchy 4 provides these surfaces through omarchy-shell/Quickshell.
- The theme includes `unlock.png` and `preview-unlock.png` for `Style → Unlock`, but does not include `shell.lock.toml`; the desktop lock screen inherits Omarchy's generated `[lock]` section.
- Omarchy 4 currently keeps one global background state. Automatic per-monitor wallpaper selection is therefore outside the portable theme format.

## Resume workflow

From the repository root:

```bash
./scripts/validate.sh
./scripts/install-local.sh
omarchy theme set smokeyember
```

After changing either SVG wallpaper source:

```bash
./scripts/export-wallpaper.sh
./scripts/validate.sh
omarchy theme set smokeyember
```

The install script never overwrites an unrelated theme directory or applies the theme automatically.

## Suggested next iteration

1. Add another wallpaper only when a properly licensed source is genuinely sharp at its target 16:9 and 32:9 resolutions; do not derive a release asset from the rejected generated experiments.
2. Capture real `desktop.png`, `launcher.png`, and `terminal-nvim.png` screenshots.
3. Review orange emphasis across the generated terminal themes, Neovim, btop, and omarchy-shell together.
4. Test the generated palette in Foot, Ghostty, and Alacritty before public release.
5. Revisit automatic per-monitor selection only if Omarchy adds per-output background state.

## Decision log

| Date | Decision |
| --- | --- |
| 2026-08-14 | Renamed the theme from LavEmber to SmokeyEmber. |
| 2026-08-14 | Selected charcoal, grey-lavender, and burnt orange as the core identity. |
| 2026-08-14 | Added standard 4K and 5120×1440 wallpaper variants. |
| 2026-08-14 | Replaced the dual-color focused border with solid focus lavender. |
| 2026-08-14 | Added a Kitty-specific orange/lavender treatment. |
| 2026-08-15 | Matched the wallpaper wordmark scale to a stock Omarchy reference. |
| 2026-08-15 | Removed both orange-wordmark wallpaper experiments from the carousel. |
| 2026-08-15 | Evaluated smoke and hacker-tech generated wallpapers through 4K export, outpainting, native-canvas conversion, and Real-ESRGAN restoration. |
| 2026-08-15 | Rejected the generated raster experiments because aliasing remained visible at 5120×1440; retained only the clean SVG-derived wordmark pair. |
| 2026-08-30 | Refined ANSI green to grey sage and cyan to slate blue for calmer semantic separation. |
| 2026-08-30 | Removed the Kitty override so public Git installs and local checkouts use the same generated terminal palette. |
| 2026-08-30 | Added reproducible Plymouth Unlock artwork using the official OMARCHY wordmark. |

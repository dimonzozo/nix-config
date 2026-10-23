# internal.desktop.plasma

KDE Plasma user configuration via [plasma-manager]. The NixOS side (plasma6, sddm, kwallet pam)
lives separately in `modules/nixos/desktop/plasma`; this module only owns the user's settings.

Enabled on `vizima` only. The contents were read off `toussaint`, which still configures Plasma
through the GUI — so this file is also the record of what toussaint's desktop actually looks like.

## Options

| Option | Default | Notes |
|---|---|---|
| `enable` | `false` | |
| `overrideConfig` | `false` | Hands the KDE config files to plasma-manager outright: anything undeclared is deleted on every activation. On for vizima, which was a fresh machine. |
| `appDashboard` | `true` | The kickerdash applet on the desktop, bound to Meta+R. |
| `lightweightEffects` | `false` | Turns off window/desktop animations, blur, translucency and slide-back. On for vizima, which has no GPU driver. |

## Affected config files

Everything this module writes, and what it owns in each. Counts are `set` = keys given a value,
`persist` = keys declared only to be left alone (see below), `del` = keys explicitly removed so KDE
falls back to its default.

| File | set | persist | del | What |
|---|---:|---:|---:|---|
| `kdeglobals` | 27 | 81 | 0 | Terminal app, Xft hinting, file-dialog defaults, `ScreenScaleFactors`, `Ctrl+Ins` copy, widget style. The 81 persistent keys are the colour scheme, written by `plasma-apply-colorscheme` at login. |
| `kglobalshortcutsrc` | 53 | 0 | 0 | Every global shortcut that differs from KDE's defaults, plus the KRunner and Spectacle service entries. |
| `kwinrulesrc` | 43 | 0 | 0 | All three window rules. plasma-manager owns this file outright. |
| `kwinrc` | 36 | 0 | 8 | 5 virtual desktops, night light, effects, tab box, dead screen edges, Xwayland scale. The 8 removals are night-light mode/location and blur strengths. |
| `powerdevilrc` | 12 | 0 | 0 | Display and suspend timeouts, power profiles, low-battery behaviour. |
| `dolphinrc` | 8 | 0 | 0 | Details view, preview size, menu bar off, preview plugins. |
| `kuriikwsfilterrc` | 4 | 0 | 1 | Web shortcuts — plasma-manager defaults, not ported from anywhere. |
| `krunnerrc` | 3 | 0 | 0 | Free-floating, no type-to-search on desktop, Baloo search off. |
| `plasmanotifyrc` | 3 | 0 | 0 | Popup position, donation message off. |
| `kcminputrc` | 2 | 1 | 0 | Key repeat delay/rate. The persistent key is the cursor theme, applied by `plasma-apply-cursortheme`. |
| `klipperrc` | 2 | 0 | 0 | Clipboard history disabled. |
| `data/dolphin/view_properties/global/.directory` | 2 | 0 | 0 | The global Dolphin view mode. |
| `baloofilerc` | 1 | 0 | 0 | File indexing off. |
| `kactivitymanagerdrc` | 1 | 0 | 0 | Resource scoring off. |
| `kactivitymanagerd-pluginsrc` | 1 | 0 | 0 | What-to-remember. |
| `kscreenlockerrc` | 1 | 0 | 0 | Lock timeout. |
| `ksmserverrc` | 1 | 0 | 0 | Start with an empty session. |
| `plasma-localerc` | 1 | 0 | 0 | Number/date formats. |
| `plasma_calendar_holiday_regions` | 1 | 0 | 0 | Holiday region. |
| `plasmarc` | 0 | 1 | 0 | Desktop theme, applied by `plasma-apply-desktoptheme`. |
| `ksplashrc` | 0 | 0 | 0 | Written empty; the look-and-feel package supplies the splash screen. |

Not written as INI at all, but generated as scripts under `~/.local/share/plasma-manager/` and run at
login — these are what produce the panel, the desktop widget, the wallpaper and the theme:

| Script | What it does |
|---|---|
| `scripts/1_script_apply_themes.sh` | `plasma-apply-lookandfeel`, `-desktoptheme`, `-cursortheme`, `-colorscheme`, `plasma-changeicons` |
| `data/desktop_script_panels.js` | Removes all panels, rebuilds the left panel and its five widgets |
| `data/desktop_script_set_desktop_widgets.js` | Removes all desktop widgets, adds kickerdash and sets its `Meta+R` shortcut |
| `data/desktop_script_wallpaper_potd.js` | Sets the Picture-of-the-Day plugin, provider and fill mode |
| `data/desktop_script_set_desktop_folder_settings.js` | Desktop icon sort mode |
| `scripts/0_script_reset_lastrun_desktopscripts.sh` | Clears the `last_run_*` markers so the above re-run |

Also touched indirectly: `plasma-org.kde.plasma.desktop-appletsrc` is **deleted** before the panel
script runs (plasma-manager works around an upstream bug that way), and the panel, widgets and
wallpaper are then recreated inside it by the scripts above.

## Seeing what gets written

The INI files are not built into the Nix store — they are written at activation time by
`write_config.py`, which merges the declared keys into whatever is already in `~/.config`. So there
is no derivation to build and inspect. `render.nix` next to this file closes that gap: it produces
the exact same input `write_config.py` receives, but with every path rooted at `./result`.

```bash
nix shell nixpkgs#jq nixpkgs#python3 --command bash -euo pipefail <<'EOS'
R=modules/home/desktop/plasma/render.nix
PM=$(nix flake metadata --json | jq -r '.locks.nodes["plasma-manager"].locked | "git+\(.url)?rev=\(.rev)"')
PMSRC=$(nix flake prefetch --json "$PM" | jq -r .storePath)

rm -rf result && mkdir -p result/config result/data result/home
nix eval --impure --json --apply 'f: (f {}).data' -f "$R" > result/data.json
RESET=$(nix eval --impure --raw --apply 'f: builtins.concatStringsSep " " (f {}).resetFiles' -f "$R")
python3 "$PMSRC/script/write_config.py" result/data.json "$RESET" ""
rm result/data.json

find result -type f | sort
EOS
```

`result/` then holds real, readable KDE config files. Pass `host`/`user` to render a different host:
`--apply 'f: (f { host = "toussaint"; }).data'`.

Because `result/` starts empty, this shows the **fully-owned** outcome — what you get on a machine
with no existing config, which is also what `overrideConfig = true` converges to. To see the merge
instead, seed it with the live files first:

```bash
cp ~/.config/kdeglobals ~/.config/kwinrc result/config/
# ...then re-run write_config.py, with "" as RESET to simulate overrideConfig = false
```

Diffing a rendered file against the live one is the quickest way to review a change:

```bash
diff <(sort result/config/kwinrc) <(sort ~/.config/kwinrc)
```

Two expected differences from a GUI-managed file: `kglobalshortcutsrc` entries carry an empty
default column (`Meta+Q,,`) that kglobalaccel refills on first run, and virtual desktop ids are
`Desktop_1…5` rather than UUIDs.

The generated scripts can be read straight out of the store without rendering anything:

```bash
nix eval --raw '.#nixosConfigurations.vizima.config.home-manager.users.dima.xdg.dataFile."plasma-manager/data/desktop_script_panels.js".text'
```

## How overrideConfig works

Worth being precise about, because it is not the usual Home Manager model.

Ordinary `home.file` entries are symlinks into the Nix store, so they are read-only and a GUI cannot
touch them. plasma-manager does the opposite: `programs.plasma.configFile` never becomes a store
symlink. Instead a single activation script (`home.activation.configure-plasma`) runs
`write_config.py` over a JSON description of the declared keys, and that script **edits the real
files in `~/.config` in place**. They stay ordinary writable files that KDE owns at runtime.

So GUI changes always work, and always stick — until the next activation. What happens then is the
only thing `overrideConfig` changes:

- **`overrideConfig = false`** (the default): each target file is read, the declared keys are
  overwritten, everything else is written back untouched. Undeclared settings survive indefinitely.
- **`overrideConfig = true`**: roughly 35 files are additionally marked *reset*. For those, the
  existing contents are read but **discarded**, so only declared keys survive. A file in that list
  with nothing declared for it is deleted outright — which is how the
  `~/.local/share/plasma-manager/last_run_*` markers get cleared, forcing the login scripts to re-run.

Either way nothing is enforced between activations. `overrideConfig = true` does not stop you
changing something in System Settings; it just means the change is reverted on the next
`nixos-rebuild switch`.

Three ways to carve out exceptions, in increasing precision:

| Mechanism | Effect |
|---|---|
| `resetFilesExclude = [ "kcminputrc" ]` | Takes a whole file out of the reset list, so it merges even under `overrideConfig`. Used here for pointer and touchpad calibration. |
| `persistent = true` with `value = null` | Declares a single key as "leave whatever is there". plasma-manager uses this itself: the 81 colour keys in `kdeglobals` and the cursor/desktop theme keys are persistent, because `plasma-apply-colorscheme` and friends write them at login and must not be wiped. |
| `immutable = true` / `immutableByDefault` | The opposite direction — appends `[$i]` to the key, which makes *KDE itself* refuse to change it and greys out the matching System Settings page. Off here: it makes bring-up confusing. |

Note that `null` on its own is not the same as persistent. A plain `value = null` **removes** the key,
resetting it to KDE's compiled-in default. `value = null` *with* `persistent = true` leaves it alone.
The `del` column in the table above counts the former.

One file is reset regardless of `overrideConfig`: declaring any `window-rules` puts `kwinrulesrc` in
the reset list, so rules added through the GUI are dropped on the next activation.

## Nothing happens until you log out

Panels, desktop widgets, wallpaper and themes are applied by a login autostart script
(`~/.local/share/plasma-manager/run_all.sh`), not by Home Manager activation. Only the
`configFile`/`dataFile` writes happen at switch time. So after `nixos-rebuild switch`, log out and
back in — "I switched and nothing changed" is expected, not a Nix problem.

Individual pieces can be nudged without a full logout:

```bash
qdbus org.kde.KWin /KWin reconfigure          # kwinrc
systemctl --user restart plasma-kglobalaccel  # kglobalshortcutsrc
```

Activating while Plasma is running also races with Plasma, which may flush its in-memory state over
the freshly written INI files when it exits. Activate, then log out promptly.

## Caveats

- **Every panel/widget/wallpaper edit rebuilds the desktop.** plasma-manager deletes
  `plasma-org.kde.plasma.desktop-appletsrc` before running the panel script, and a `runAlways` script
  clears all `last_run_desktop_script_*` markers whenever any desktop script changes. Desktop icon
  positions are collateral on each such change.
- **`window-rules` takes exclusive ownership of `kwinrulesrc`** as soon as it is non-empty, even with
  `overrideConfig = false`. Rules added through the GUI will be deleted.
- **`overrideConfig` discards undeclared keys** in ~35 files on every activation — `kwinrc`,
  `kdeglobals`, `kglobalshortcutsrc`, `plasmashellrc`, `powerdevilrc` and the rest; a listed file
  with nothing declared is deleted outright. `kcminputrc` is in `resetFilesExclude` because it holds
  pointer and touchpad calibration keyed by per-machine device ids, which cannot be expressed
  declaratively. See "How overrideConfig works".
- **Applet ids are generated by Plasma.** Never hardcode `activate widget <n>`,
  `[Containments][1]` or `[Containments][2][Applets][93]`. The Meta+R binding is set on the widget
  object via `extraConfig` (`widget.globalShortcut`) for exactly this reason.
- **Panel geometry is in logical pixels** against the screen height — `plasmashellrc` even keys it by
  resolution (`[PlasmaViews][Panel 2][Vertical960]`). The values here (thickness 40, length 634–706,
  offset 108) are toussaint's, against a 960 px logical height.
- **Night Light has no explicit mode**, so it relies on KDE's automatic geolocation. If the day/night
  switch never fires, set `mode = "times"` with explicit morning/evening instead.
- **`kglobalshortcutsrc` will not be byte-identical** to a GUI-managed one: plasma-manager writes an
  empty default column (`keys,,`) that kglobalaccel refills on first run.

## Deliberately not configured

- **Keyboard layouts.** toussaint has no `~/.config/kxkbrc` at all — `us,ru` + `ctrl:nocaps` comes
  from `modules/nixos/system/xkb`. Setting `input.keyboard.layouts` here would create a second,
  competing source. Only the Meta+Space switcher shortcut is declared.
- **`internal.desktop.theme`** must stay off on any host using this module. It sets a Qogir
  `home.pointerCursor` and `qt.platformTheme.name = "kvantum"`, which exports
  `QT_QPA_PLATFORMTHEME`/`QT_STYLE_OVERRIDE` session-wide and overrides Plasma's own Qt integration
  for every KDE app. It would also wake the currently-dormant `catppuccin.kvantum`/`catppuccin.gtk`
  config in `modules/home/tools/common`. For nerd fonts, add the packages to `home.packages` instead.
- **Desktop right-click menu allowlist** (`[ActionPlugins][0][RightButton;NoModifier]`).
  `desktop.mouseActions` only picks which plugin handles a button, not the menu contents. A custom
  `startup.desktopScript` could write it, but it is pure polish and the most fragile option.
- **Folder View containment.** No scripting setter and no plasma-manager option. It is the Plasma 6
  default, so normally there is nothing to do; if a host comes up with a plain Desktop containment,
  set it once via right-click → Desktop and Wallpaper → Layout.
- **KWin tiling layout.** toussaint carries a 25/50/25 three-column layout keyed by output UUID.
  Not wanted, and the UUID is per-machine anyway.
- **Per-device hardware settings** — `plasmaparc` mute state and the `kcminputrc [Libinput][…]`
  touchpad block are keyed by vendor/product ids. Tune them in the GUI; they can be lifted into
  `input.touchpads` later once the real ids are known.
- **Outlook/Teams PWA icon rules.** Obsolete on both hosts.

## Todo

- [ ] Retune the four panel geometry constants for vizima's actual logical resolution
      (`kscreen-doctor -o`) — they are currently toussaint's.
- [ ] Confirm `Xwayland.Scale = 2` and `KScreen.ScreenScaleFactors = "eDP-1=1;"` are right for
      vizima; the output name in particular is a guess.
- [ ] Lift vizima's trackpad settings into `input.touchpads` once its device ids are known, so
      `kcminputrc` can come out of `resetFilesExclude`.
- [ ] When `internal.impermanence.enable` is turned on for vizima, persist `~/.config` **and**
      `~/.local/share/plasma-manager` — otherwise every login replays every desktop script and
      rebuilds the panel.

## Migrating toussaint

Enabling this module on `toussaint` would make both hosts declarative from one source. It is a
one-way door on a working daily driver, so the costs, up front:

Because the panel script deletes `plasma-org.kde.plasma.desktop-appletsrc`, the first login after
enabling it drops, unrecoverably:

- the hand-placed desktop icon layout (`positions=` for ~20 files across three resolutions),
  `ItemGeometries-*` and the `ScreenMapping` block
- two `kwinrulesrc` rules not carried over here: a maximize/noborder rule and a Teams window
  position rule

Sequence it as its own change, after vizima is verified working:

```bash
cp -a ~/.config ~/config-backup-$(date +%F)
tar -czf ~/plasma-manager-backup-$(date +%F).tar.gz -C ~/.local/share plasma-manager
```

Then set `plasma = { enable = true; lightweightEffects = false; }` and leave `overrideConfig` at
`false` — turning it on would also discard the GUI touchpad calibration. Before logging out, diff the
generated attrsets against the live files so the only post-login deltas are the desktop rebuild:

```bash
nix eval --json '.#nixosConfigurations.toussaint.config.home-manager.users.dima.programs.plasma.configFile.kwinrc'
nix eval --json '.#nixosConfigurations.toussaint.config.home-manager.users.dima.programs.plasma.configFile.kdeglobals'
```

## Deriving this from a live machine

`nix run github:nix-community/plasma-manager#rc2nix` dumps the current machine's live KDE config as
Nix, which is how this module was derived. It emits machine-generated noise (UUIDs, applet ids, icon
positions, store paths, dialog geometry) that must not be committed.

[plasma-manager]: https://github.com/nix-community/plasma-manager

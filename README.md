# IGIPatch
A fan-made patch for Project IGI, currently in an early stage of development. Bug-fixing, QoL improvements and better compatibility with modern systems are the main goals of the patch.

## Installation

1. Find your IGI installation directory and backup the file 'pc\IGI.exe'.
2. Extract the contents of the ZIP archive (IGIPatch_vx.xx_XX_NoSetup.zip) to the root directory of your game, accept when prompted to replace IGI.exe.
3. Review `IGIPatch.ini` and enable or disable the options you want.

This repository does not include Project IGI game files, disc images, or third-party wrapper binaries.

## Modern Windows Setup

For CUE/BIN disc-image installs and DirectX 7 device errors on modern Windows, see `docs/local-compatibility-guide.md`.

Common fixes:

- Mount `.cue` files rather than individual `.bin` files.
- Use `RemoveCDCheck=1` if the original CD check fails on a mounted image.
- Use dgVoodoo2's 32-bit DirectX wrapper if the game exits with `DDERR_UNSUPPORTED` or `Couldn't create device`.
- Use `tools/Install-DgVoodoo2.ps1` to fetch dgVoodoo2 locally without committing wrapper DLLs to this repo.
- Use `tools/Test-ProjectIGISetup.ps1` to check for the common local causes behind missing videos, DirectX device errors, and mission-load crashes.

## Configuration
Individual features of the patch can be tweaked by editing the file 'IGIPatch.ini' with a text editor (eg.: Notepad). Numeric constant '1' means true/enable, whereas '0' means false/disable.

Useful compatibility options:

```ini
[Options]
RemoveCDCheck=1
UnlockAllMissions=1
```

`UnlockAllMissions=1` unlocks mission selection without requiring the debug command-line features to be enabled.

## Supported game versions
- European/Chinese
- American
- Japanese

## Current feature list - v0.60 (updated 2025-07-29)
- CD check removal.
- Improved timer resolution (beyond microseconds).
- Fixed windows cursor being visible in windowed mode.
- Fixed cursor accuracy in fullscreen mode for menus.
- Added support for borderless window mode. Use command-line parameters 'Window' and 'Borderless' to turn it on.
- Fixed buffer overflow when retrieving display modes. This solves the very known graphics menu crash.
- Display modes below the max bit depth of the screen are no longer selectable. This has been done because the game is limited to only 64 display modes.
- Fixed Resolution listbox showing a wrong display mode; Resolution limit raised from 8192x8192x32 to 65536x65536.
- Added widescreen support; Screen shrinking/stretching is disabled and horizontal FOV is automatically adjusted.
- Added debug features via command-line arguments: NoLightmaps, NoTerrainLightmaps, DebugText, Debug, Small, DebugKeys.
- Added dedicated `UnlockAllMissions` option for mission selection, independent from debug features.
- Disabled the hard-coded 640x480x16 mode set for the main menu. A custom main menu resolution can be set in the INI file.
- IGI is now DPI-Aware. Solves the issue with the size of the client window being incorrect when Windows DPI scaling is set higher than 100%.

## Development Notes

- `docs/reverse-engineering-notes.md` tracks compatibility-oriented analysis and patch addresses.
- Do not commit proprietary game binaries, disc images, copied game assets, generated decompilation dumps, or downloaded wrapper DLLs.
- Keep source changes focused on patch code, docs, reproducible helpers, and clean configuration files.

## Troubleshooting

Run the setup checker against the folder that contains `IGI.exe`:

```powershell
tools\Test-ProjectIGISetup.ps1 -GamePcDir "C:\Games\Project IGI\pc"
```

Common findings:

1. Intro videos do not play:
- The game needs the legacy Indeo Video 5 codec (`IV50`). The setup checker reports whether the codec appears to be registered. Install/register a trusted IV50 codec only if you need the original intro videos.
2. The game falls back to 640x480 at 2K or higher:
- DirectX 7 is limited around 2048x2048. Use dgVoodoo2 or another wrapper without that limitation. `tools\Install-DgVoodoo2.ps1` installs the required local wrapper files.
3. The game crashes when loading a mission:
- Disable overlay/hook software first, especially Rivatuner/RTSS, MSI Afterburner, Discord overlay, Steam overlay, Game Bar, and GPU capture overlays. The setup checker reports common running overlay processes.

## Credits
Special thanks to @neoxaero [(Sagatt)](https://github.com/Sagatt) for the immense help provided.

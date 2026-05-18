# Reverse Engineering Notes

These notes document compatibility-oriented analysis only. Do not commit proprietary game binaries, disc images, generated decompilation output, or copied game assets to this repository.

## Tested Binaries

| Build | SHA-256 | Notes |
| --- | --- | --- |
| Europe rerelease `IGI.exe` | `8EFC6C036ED6FC065A2DD18CD2C86A4F3040781A3380BC7C7781BC4B27FC971B` | Worked with the rerelease CUE mounted as the first visible CD drive. |
| USA original install `IGI.exe` | `75CC29C4FD9B60CB8F4ABA0C3DF863209814E1CC51F1AA096DF1CF99119F0946` | Installed successfully, but kept failing the CD check in the tested WinCDEmu/ISO setup. |

The existing patch source identifies three supported executable layouts through `IGIMUTEX` build IDs and per-version address tables in:

- `IGIPatchDLL/base/_code_patches_id0.asm`
- `IGIPatchDLL/base/_code_patches_id1.asm`
- `IGIPatchDLL/base/_code_patches_id2.asm`

## CD Check

Observed failure:

```text
IGI CD not found. Please insert CD in drive.
```

Windows' built-in ISO mounting was enough to install the game from a converted data track, but not enough to satisfy the game's runtime CD check. Mounting the original CUE with WinCDEmu preserved the disc layout better, but the USA executable still rejected it in the tested setup. The Europe rerelease executable cleared the CD check when run against installed game data.

IGIPatch already has `RemoveCDCheck`, enabled by default, which is the preferred repo-level fix.

## DirectX 7 Device Creation

Observed failure:

```text
Fatal error:
Couldn't create device
DirectX error message: DDERR_UNSUPPORTED
```

The working local compatibility stack was dgVoodoo2's 32-bit DirectX wrapper placed beside `IGI.exe`:

- `DDraw.dll`
- `D3DImm.dll`
- `dgVoodoo.conf`

The repo should not vendor dgVoodoo2 binaries. Use `tools/Install-DgVoodoo2.ps1` to fetch the current official release into a local game install.

## Mission Unlock

The main-menu mission screen has version-specific checks that require completing all 14 missions before everything is selectable. Existing address tables already patched those checks under `EnableDebugFeatures`.

This change splits that behavior into a dedicated INI option:

```ini
[Options]
UnlockAllMissions=1
```

Implemented patch sites:

| Build table | Addresses |
| --- | --- |
| `id0` | `0x00415002`, `0x0041505A` |
| `id1` | `0x00415092`, `0x004150EA` |
| `id2` | `0x00488FC2`, `0x0048901A` |

## Save/Profile File

The game's profile/progress/config data lives in `pc/config.qvm`. Public save-game instructions for IGI 1 also identify `config.qvm` as the file to replace for a 100% save, but the patch route is cleaner because it avoids shipping a binary save file and preserves the user's controls/settings.

Strings observed in `config.qvm` include:

- `GOPlayer`
- `GOActiveMission`
- `GOGameDiff`
- `GOInRemap`
- `GOGfxDevice`
- `GOSoundMusic`

The file begins with the `LOOP` magic and contains a string-offset table followed by QVM bytecode/data. More format work is needed before safely generating arbitrary profile saves.

# Local Compatibility Guide

This guide describes a clean modern-Windows setup without committing copyrighted game files or third-party wrapper binaries.

## Disc Image

If you have a Redump-style CUE/BIN set, mount the `.cue`, not an individual `.bin`.

Recommended tool:

- WinCDEmu, because it can mount CUE/BIN images through `batchmnt64.exe`.

Older IGI builds may expect the game disc to be the first visible CD drive. If the game reports that the CD is missing, either use IGIPatch with `RemoveCDCheck=1` or mount the disc to the first optical drive letter.

## DirectX Wrapper

For `DDERR_UNSUPPORTED` or `Couldn't create device`, install dgVoodoo2's DirectX wrapper into the folder containing `IGI.exe`.

Required files:

- `DDraw.dll`
- `D3DImm.dll`
- `dgVoodoo.conf`

Use:

```powershell
tools\Install-DgVoodoo2.ps1 -GamePcDir "C:\Games\Project IGI\pc"
```

## Setup Checker

Run:

```powershell
tools\Test-ProjectIGISetup.ps1 -GamePcDir "C:\Games\Project IGI\pc"
```

It checks for:

- `IGI.exe`
- `IGIPatch.ini`
- dgVoodoo2 DirectX wrapper DLLs
- Indeo Video 5 (`IV50`) codec registration/files
- display sizes that can hit DirectX 7's 2048 limit
- common overlay/hook processes associated with mission-load crashes

## Launch Helper

Use the launcher helper when you want the CUE mounted automatically before starting the game:

```powershell
tools\Launch-ProjectIGI.ps1 `
  -GamePcDir "C:\Games\Project IGI\pc" `
  -CuePath "D:\Images\Project IGI.cue" `
  -DriveLetter D
```

## Mission Unlock

In `IGIPatch.ini`:

```ini
[Options]
RemoveCDCheck=1
UnlockAllMissions=1
```

`UnlockAllMissions` bypasses the mission-screen completion requirement. It is separate from debug command-line features so players can unlock mission selection without enabling debug options.

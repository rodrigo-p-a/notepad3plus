# ------------------------------------------------------------
# embed_minipath.ps1
# Embeds minipath.exe into Notepad3.exe as an RCDATA resource named "MINIPATH"
# so the single Notepad3.exe can self-extract it at runtime (single-file dist).
# Run AFTER building the solution.
#   .\Build\embed_minipath.ps1 [-Config Release] [-Platform x64]
# ------------------------------------------------------------
param(
    [string]$Config   = "Release",
    [string]$Platform = "x64",
    [string]$Toolset  = "v143"
)
$ErrorActionPreference = "Stop"

$root   = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root ("Bin\{0}_{1}_{2}" -f $Config, $Platform, $Toolset)
$built  = Join-Path $outDir "Notepad3.exe"
$np3    = Join-Path $outDir "NotePad3Plus.exe"   # distributable name
$mp     = Join-Path $outDir "minipath.exe"

if (-not (Test-Path $built)) { throw "Notepad3.exe nao encontrado: $built" }
if (-not (Test-Path $mp))    { throw "minipath.exe nao encontrado: $mp" }

# the build outputs Notepad3.exe; rename a copy to NotePad3Plus.exe and embed into it
Copy-Item $built $np3 -Force

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class ResUpd {
    [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
    public static extern IntPtr BeginUpdateResource(string fileName, bool deleteExisting);
    [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
    public static extern bool UpdateResource(IntPtr h, IntPtr type, string name, ushort lang, byte[] data, uint cb);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool EndUpdateResource(IntPtr h, bool discard);
}
"@

$RT_RCDATA = [IntPtr]10
$LANG_NEUTRAL = [uint16]0

# Files to embed as RCDATA: minipath.exe + the ENTIRE lng\ language tree (all
# locales), so the single-exe distribution is self-contained. The installer
# extracts them next to the installed exe (see _ProvisionLanguagePacks in
# Dialogs.c), reconstructing the relative path from the resource name. Resource
# name = the file's path relative to the build output dir (e.g.
# "lng\pt-BR\np3lng.dll.mui"); the runtime filters names starting with "lng\".
$lng = Join-Path $outDir "lng"
$embeds = [ordered]@{ "MINIPATH" = $mp }

# the two stub DLLs at the lng root + every <locale>\*.dll.mui (skip build obj\)
$lngFiles  = @(Get-ChildItem $lng -File | Where-Object { $_.Name -in @("np3lng.dll", "mplng.dll") })
$lngFiles += @(Get-ChildItem $lng -Recurse -File -Filter *.dll.mui | Where-Object { $_.FullName -notmatch "\\obj\\" })
foreach ($f in $lngFiles) {
    $rel = $f.FullName.Substring($outDir.Length).TrimStart('\')   # e.g. lng\pt-BR\np3lng.dll.mui
    $embeds[$rel] = $f.FullName
}

$h = [ResUpd]::BeginUpdateResource($np3, $false)   # keep existing resources (icon, manifest, version)
if ($h -eq [IntPtr]::Zero) {
    throw "BeginUpdateResource falhou (err $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}
$total = 0
foreach ($name in $embeds.Keys) {
    $path = $embeds[$name]
    if (-not (Test-Path $path)) {
        [ResUpd]::EndUpdateResource($h, $true) | Out-Null
        throw "arquivo a embarcar nao encontrado: $path"
    }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if (-not [ResUpd]::UpdateResource($h, $RT_RCDATA, $name, $LANG_NEUTRAL, $bytes, [uint32]$bytes.Length)) {
        [ResUpd]::EndUpdateResource($h, $true) | Out-Null
        throw "UpdateResource ($name) falhou (err $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
    }
    $total += $bytes.Length
}
if (-not [ResUpd]::EndUpdateResource($h, $false)) {
    throw "EndUpdateResource falhou (err $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}

Write-Host ("OK: {0} recursos ({1:N0} bytes) embarcados em {2}" -f $embeds.Count, $total, $np3)

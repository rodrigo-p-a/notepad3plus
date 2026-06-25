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
$np3    = Join-Path $outDir "Notepad3.exe"
$mp     = Join-Path $outDir "minipath.exe"

if (-not (Test-Path $np3)) { throw "Notepad3.exe nao encontrado: $np3" }
if (-not (Test-Path $mp))  { throw "minipath.exe nao encontrado: $mp" }

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

$bytes = [System.IO.File]::ReadAllBytes($mp)
$RT_RCDATA = [IntPtr]10
$LANG_NEUTRAL = [uint16]0

$h = [ResUpd]::BeginUpdateResource($np3, $false)   # keep existing resources (icon, manifest, version)
if ($h -eq [IntPtr]::Zero) {
    throw "BeginUpdateResource falhou (err $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}
if (-not [ResUpd]::UpdateResource($h, $RT_RCDATA, "MINIPATH", $LANG_NEUTRAL, $bytes, [uint32]$bytes.Length)) {
    [ResUpd]::EndUpdateResource($h, $true) | Out-Null
    throw "UpdateResource falhou (err $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}
if (-not [ResUpd]::EndUpdateResource($h, $false)) {
    throw "EndUpdateResource falhou (err $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error()))"
}

Write-Host ("OK: minipath.exe ({0:N0} bytes) embarcado em {1}" -f $bytes.Length, $np3)

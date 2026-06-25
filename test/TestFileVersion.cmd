@echo off
setlocal enableextensions
set SCRIPT_DIR=%~dp0

set NP3_WIN32_DIR=%SCRIPT_DIR%..\Bin\Release_x86_v145\
set NP3_X64_DIR=%SCRIPT_DIR%..\Bin\Release_x64_v145\
set NP3_BUILD_VER=%SCRIPT_DIR%..\Versions\build.txt

:: --------------------------------------------------------------------------------------------------------------------

set YY=00
set MDD=000

call :GETDATE

set BUILD=0
call :GETBUILD "%~1"

set VERSHOULD=7.%YY%.%MDD%.%BUILD%

:: --------------------------------------------------------------------------------------------------------------------

set TEST_RESULT=failure

set FILEVER=
set FILEVER32=
if exist "%NP3_WIN32_DIR%Notepad3.exe" call :GETFILEVER "%NP3_WIN32_DIR%Notepad3.exe"
if defined FILEVER set FILEVER32=%FILEVER%
set FILEVER=
set FILEVER64=
if exist "%NP3_X64_DIR%Notepad3.exe" call :GETFILEVER "%NP3_X64_DIR%Notepad3.exe"
if defined FILEVER set FILEVER64=%FILEVER%

if defined FILEVER32 set TEST_RESULT=success
if defined FILEVER64 set TEST_RESULT=success
call :COMPAREVER "%VERSHOULD%" "%FILEVER32%" "%FILEVER64%"

:: ====================================================================================================================
goto :END
:: --------------------------------------------------------------------------------------------------------------------

:COMPAREVER
if ["%~2"] NEQ [""] (
  if ["%~1"] NEQ ["%~2"] (
      echo ERROR: Expected version "%~1", found version "%~2" in 32-bit exe 
      set TEST_RESULT=failure
  )
)
if ["%~3"] NEQ [""] (
  if ["%~1"] NEQ ["%~3"] (
      echo ERROR: Expected version "%~1", found version "%~3" in 64-bit exe
      set TEST_RESULT=failure
  )
)
goto:EOF
:: --------------------------------------------------------------------------------------------------------------------

:GETDATE
:: Mirror the build's version stamp (Generate version step): 7.<yy>.<Mdd>.<build>.
:: Use PowerShell, not wmic - wmic is absent on Windows 11 24H2 / Server 2025
:: (the windows-2025 CI image), which made both this and :GETFILEVER return empty
:: and the version test always fail.
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-Date -Format yy"`) do set "YY=%%a"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-Date -Format Mdd"`) do set "MDD=%%a"
goto:EOF
:: --------------------------------------------------------------------------------------------------------------------

:GETFILEVER
set "file=%~1"
if not defined file goto:EOF
if not exist "%file%" goto:EOF
set "FILEVER="
:: PowerShell replacement for `wmic datafile ... Get Version` (wmic removed on
:: Windows 11 24H2 / Server 2025). Compose the numeric file version a.b.c.d.
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "$v=[System.Diagnostics.FileVersionInfo]::GetVersionInfo('%file%'); '{0}.{1}.{2}.{3}' -f $v.FileMajorPart,$v.FileMinorPart,$v.FileBuildPart,$v.FilePrivatePart"`) do set "FILEVER=%%a"
::echo %file% = %FILEVER%
goto:EOF
:: --------------------------------------------------------------------------------------------------------------------

:GETBUILD
set argbuild=%~1
if defined argbuild (
    set BUILD=%argbuild%
    goto:EOF
)
::set /p nxbuild=<"%NP3_BUILD_VER%"
::set /a BUILD=%nxbuild% - 1
set /p BUILD=<"%NP3_BUILD_VER%"
goto:EOF
:: --------------------------------------------------------------------------------------------------------------------

:: ====================================================================================================================
:END
echo Expected Version = %VERSHOULD%
if ["%FILEVER32%"] NEQ [""] (
  echo 32-bit exe Version = %FILEVER32%
) else (
  echo No 32-bit exe Version found
)
if ["%FILEVER64%"] NEQ [""] (
  echo 64-bit exe Version = %FILEVER64%
) else (
  echo No 64-bit exe Version found
)
echo Version Test Result: %TEST_RESULT%
:: - make TEST_RESULT survive 'endlocal'
endlocal & set TEST_RESULT=%TEST_RESULT%
::pause
if [%TEST_RESULT%] NEQ [success] exit /B 1
:: ====================================================================================================================

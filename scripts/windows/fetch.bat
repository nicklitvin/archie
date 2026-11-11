@echo off
rem Downloads depot_tools and the Chromium source at CHROMIUM_VERSION.
rem Needs ~100 GB free on an NTFS drive and takes an hour or more.
rem Run from Command Prompt (cmd.exe), not PowerShell, the first time.
setlocal
call "%~dp0config.bat"

echo [archie] You need, before starting:
echo [archie]   - Visual Studio 2026 with "Desktop development with C++" and "MFC/ATL support"
echo [archie]   - Windows 11 SDK 10.0.28000.2270 with "Debugging Tools for Windows"
echo [archie]   - Git for Windows, and about 100 GB free on an NTFS drive

where git >nul 2>nul || (echo [archie] Install Git for Windows first: https://git-scm.com/download/win & exit /b 1)
git config --global core.autocrlf false
git config --global core.filemode false
git config --global core.longpaths true

if not exist "%DEPOT_TOOLS%\gclient.bat" (
  echo [archie] Cloning depot_tools into %DEPOT_TOOLS%
  git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git "%DEPOT_TOOLS%" || exit /b 1
)
echo [archie] Setting up depot_tools (the first time this downloads its own Python and Git)
call gclient >nul 2>nul

if not exist "%CHROMIUM_DIR%" mkdir "%CHROMIUM_DIR%"
> "%CHROMIUM_DIR%\.gclient" (
  echo solutions = [{
  echo   "name": "src",
  echo   "url": "https://chromium.googlesource.com/chromium/src.git@refs/tags/%CHROMIUM_VERSION%",
  echo   "managed": False,
  echo   "custom_deps": {},
  echo   "custom_vars": {"checkout_pgo_profiles": False},
  echo }]
)

echo [archie] Syncing Chromium %CHROMIUM_VERSION% (this takes a while)
cd /d "%CHROMIUM_DIR%" || exit /b 1
call gclient sync --nohooks --no-history --shallow -D --force --revision "src@refs/tags/%CHROMIUM_VERSION%" || exit /b 1
call gclient runhooks || exit /b 1
echo [archie] Done. Next: scripts\windows\prepare.bat

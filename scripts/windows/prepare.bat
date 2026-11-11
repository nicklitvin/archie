@echo off
rem Turns the Chromium checkout into Archie: applies patches\series, installs
rem the branding and renames the product in UI strings. Safe to re-run.
rem   prepare.bat --reset   discards all local changes in the checkout first
setlocal EnableDelayedExpansion
call "%~dp0config.bat"

if not exist "%SRC%\.git" (echo [archie] No Chromium checkout at %SRC%. Run scripts\windows\fetch.bat first. & exit /b 1)

if /i "%~1"=="--reset" (
  echo [archie] Resetting %SRC% to a clean %CHROMIUM_VERSION%
  git -C "%SRC%" reset --hard -q
  git -C "%SRC%" clean -fdq
)

for /f "usebackq eol=# delims=" %%P in ("%ARCHIE_ROOT%\patches\series") do (
  set "PATCH=%ARCHIE_ROOT%\patches\%%P"
  git -C "%SRC%" apply --reverse --check "!PATCH!" >nul 2>nul
  if !errorlevel! equ 0 (
    echo [archie] already applied: %%P
  ) else (
    git -C "%SRC%" apply "!PATCH!" || (echo [archie] failed to apply %%P. Try: prepare.bat --reset & exit /b 1)
    echo [archie] applied: %%P
  )
)

copy /y "%ARCHIE_ROOT%\branding\BRANDING" "%SRC%\chrome\app\theme\chromium\BRANDING" >nul || exit /b 1
echo [archie] installed branding
call python3 "%ARCHIE_ROOT%\scripts\rebrand.py" "%SRC%" || exit /b 1
call python3 "%ARCHIE_ROOT%\scripts\write_version_header.py" "%SRC%" "%ARCHIE_UPDATE_REPO%" || exit /b 1
echo [archie] Done. Next: scripts\windows\build.bat

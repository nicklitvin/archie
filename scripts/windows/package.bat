@echo off
rem Copies the built installer to dist\archie-<version>-windows-x64-setup.exe.
setlocal
call "%~dp0config.bat"
set "INSTALLER=%SRC%\%OUT_DIR%\mini_installer.exe"
if not exist "%INSTALLER%" (echo [archie] No installer at %INSTALLER%. Run scripts\windows\build.bat first. & exit /b 1)
if not exist "%ARCHIE_ROOT%\dist" mkdir "%ARCHIE_ROOT%\dist"
set "OUT=%ARCHIE_ROOT%\dist\archie-%ARCHIE_VERSION%-windows-x64-setup.exe"
copy /y "%INSTALLER%" "%OUT%" >nul || exit /b 1
echo [archie] Wrote %OUT%
echo [archie] It installs Archie for the current user into %%LOCALAPPDATA%%\Archie.

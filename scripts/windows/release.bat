@echo off
rem Publishes every package in dist\ for ARCHIE_VERSION as a GitHub release.
rem   release.bat notes.md
rem notes.md becomes the release notes shown in Archie's Patch notes window.
rem Needs the GitHub CLI (gh), logged in.
setlocal EnableDelayedExpansion
call "%~dp0config.bat"
if "%~1"=="" (echo Usage: scripts\windows\release.bat NOTES.md & exit /b 1)
if not exist "%~1" (echo [archie] Notes file not found: %~1 & exit /b 1)
where gh >nul 2>nul || (echo [archie] Install the GitHub CLI first: https://cli.github.com & exit /b 1)

set "ASSETS="
for %%F in ("%ARCHIE_ROOT%\dist\archie-%ARCHIE_VERSION%-*") do set ASSETS=!ASSETS! "%%~fF"
if not defined ASSETS (echo [archie] No packages for %ARCHIE_VERSION% in dist\. Run package.bat first. & exit /b 1)

echo [archie] Publishing Archie %ARCHIE_VERSION% as v%ARCHIE_VERSION% on %ARCHIE_UPDATE_REPO%
gh release create "v%ARCHIE_VERSION%" !ASSETS! --repo "%ARCHIE_UPDATE_REPO%" --title "Archie %ARCHIE_VERSION%" --notes-file "%~1" || exit /b 1
echo [archie] Done.

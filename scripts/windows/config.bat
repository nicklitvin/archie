@echo off
rem Shared settings for the Windows build scripts. The other scripts call this.
rem Override any of these by setting them before running a script, e.g.
rem   set ARCHIE_JOBS=2

for %%I in ("%~dp0..\..") do set "ARCHIE_ROOT=%%~fI"
for /f "usebackq delims=" %%V in ("%ARCHIE_ROOT%\CHROMIUM_VERSION") do set "CHROMIUM_VERSION=%%V"
for /f "usebackq delims=" %%V in ("%ARCHIE_ROOT%\ARCHIE_VERSION") do set "ARCHIE_VERSION=%%V"

rem Chromium's checkout path must not contain spaces.
if not defined CHROMIUM_DIR set "CHROMIUM_DIR=C:\archie-build\chromium"
if not defined DEPOT_TOOLS set "DEPOT_TOOLS=C:\archie-build\depot_tools"
if not defined OUT_DIR set "OUT_DIR=out\Archie"

rem Low memory by default: about 8 GB of RAM in use at most.
if not defined ARCHIE_LOW_MEMORY set "ARCHIE_LOW_MEMORY=1"
if not defined ARCHIE_JOBS set "ARCHIE_JOBS=4"
if not defined ARCHIE_UPDATE_REPO set "ARCHIE_UPDATE_REPO=nicklitvin/archie"

set "SRC=%CHROMIUM_DIR%\src"
set "PATH=%DEPOT_TOOLS%;%PATH%"
rem Use the locally installed Visual Studio, not Google's internal toolchain.
set "DEPOT_TOOLS_WIN_TOOLCHAIN=0"

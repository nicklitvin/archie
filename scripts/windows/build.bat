@echo off
rem Builds Archie and its installer into <checkout>\src\out\Archie.
rem With the low-memory defaults the first build can take most of a day;
rem later builds only redo what changed.
setlocal
call "%~dp0config.bat"
cd /d "%SRC%" || exit /b 1

if "%ARCHIE_LOW_MEMORY%"=="1" (
  call python3 "%ARCHIE_ROOT%\scripts\make_args.py" "%OUT_DIR%" --low-memory || exit /b 1
) else (
  call python3 "%ARCHIE_ROOT%\scripts\make_args.py" "%OUT_DIR%" || exit /b 1
)
call gn gen "%OUT_DIR%" || exit /b 1

echo [archie] Building with %ARCHIE_JOBS% parallel jobs (set ARCHIE_JOBS to change).
call autoninja -C "%OUT_DIR%" -j %ARCHIE_JOBS% chrome mini_installer %* || exit /b 1
echo [archie] Done. Try it: %SRC%\%OUT_DIR%\chrome.exe
echo [archie] Next: scripts\windows\package.bat

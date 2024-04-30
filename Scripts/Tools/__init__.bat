@echo off

if defined CONTOOLS_OLD_PROJECT_ROOT_INIT0_DIR if exist "%CONTOOLS_OLD_PROJECT_ROOT_INIT0_DIR%\*" exit /b 0

call "%%~dp0__init__\__init__.bat" || exit /b

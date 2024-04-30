@echo off

rem Create local variable's stack
setlocal

call "%%~dp0__init__/__init__.bat" || exit /b
call "%%CONTOOLS_TESTLIB_ROOT%%/init.bat" "%%~f0" || exit /b

call "%%TESTS_PROJECT_ROOT%%/test_strchr.bat"
call "%%TESTS_PROJECT_ROOT%%/test_strrep.bat"
call "%%TESTS_PROJECT_ROOT%%/test_stresc.bat"
call "%%TESTS_PROJECT_ROOT%%/test_cstresc.bat"
rem call "%%TESTS_PROJECT_ROOT%%/test_setvarsfromfile.bat"

rem WARNING: must be called without the call prefix!
"%CONTOOLS_TESTLIB_ROOT%/exit.bat"

rem no code can be executed here, just in case
exit /b

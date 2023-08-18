echo off
set arg1=%1
set arg2=%2
shift
shift
echo %arg1%
powershell.exe -ExecutionPolicy Bypass -file "%cd%/generate-bindings.ps1" %arg1% %arg2%
pause
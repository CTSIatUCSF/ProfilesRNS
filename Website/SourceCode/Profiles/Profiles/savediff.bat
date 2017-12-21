rem @echo off
set WKDIR=%~dp0
cd %WKDIR%
for /f "tokens=*" %%i in ('dir /s /b /a-d %WKDIR%\UCSD') do call :DOFILE "%%i"
goto :EOF

:DOFILE
set FILE=%1
set DIR=%~dp1
set FILENAME=%~nx1
set FROMFILE=%FILE:UCSD\=%
set TOFILE=%FILE:UCSD=UCSF%
set TODIR=%DIR:UCSD=UCSF%
echo TOFILE=%TOFILE%
echo FROMFILE=%FROMFILE%
set TODIR=
xcopy %FROMFILE% %TOFILE%
pause goto :EOF
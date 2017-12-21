@echo off
set UNV=%1
set WKDIR=%~dp0
cd %WKDIR%
if exist %WKDIR%\%UNV%\Profiles (
	xcopy /s /r /y %WKDIR%\%UNV%\Profiles %WKDIR%\Profiles
)
goto :EOF
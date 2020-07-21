@echo off
set WKDIR=%~dp0
echo WKDIR=%WKDIR%
set CONFIG=%1
if $%CONFIG%$==$$ (
	echo "usage: GetPMID.bat <DB Configuration File>
	goto :EOF
)
if not exist %WKDIR%%CONFIG% (
	echo <DB Configuration File> does not exist
	goto :EOF
)
powershell -executionpolicy bypass -command %WKDIR%getPMID_XML.ps1 %CONFIG%



@echo off
set WKDIR=%~dp0
pushd %WKDIR%
if $%1$ == $$ (
	echo need XML file with authentifications
	goto :EOF
)
set PASSFILE=%~nx1
if not exist %PASSFILE% (
	echo file %PASSFILE% does not exist in directory %WKDIR%
	goto :EOF
)
powershell -executionpolicy bypass -command .\ProcessDimensionsPubs.ps1 %PASSFILE%


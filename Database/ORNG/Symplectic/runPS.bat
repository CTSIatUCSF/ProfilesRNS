@echo off
set WKDIR=%~dp0
if "%1" == "" (
	echo ERROR, no script name
	goto :EOF
) else ( 
	set SCRIPT=%WKDIR%%1
	set PARAMS=
	shift
)
:BEGIN
if "%1" == "" goto :EXEC
set PARAMS=%PARAMS% %1
shift
goto :BEGIN

:EXEC
for /f "delims=/ tokens=1,2,3" %%i in ('date /T') do (
       set MONTH=%%i
       set DAY=%%j
       set /a YEAR=%%k
)
for /f "tokens=1,2 delims= " %%i in ('echo %MONTH%') do (
      set WEEKDAY=%%i
      set MONTH=%%j
)
if "%MONTH:~0,1%" == "0" (
	set MONTH=%MONTH:~1,1%
) 
set /a MONTH_NUM=%MONTH% 
for /f "tokens=1,2 delims= " %%i in ('time /T') do (
       set TM=%%i
       set ATM=%%j
)
set LOGFILE=%WKDIR%%MONTH%%YEAR%proc.log
rem set /a MONTH_NUM=1
set /a MONTH_NUM_DEL=%MONTH_NUM%-2
set /a YEAR_DEL=%YEAR%
if %MONTH_NUM_DEL% LEQ 0 (
	set /a MONTH_NUM_DEL=%MONTH_NUM_DEL%+12
	set /a YEAR_DEL=%YEAR_DEL%-1
)
if %MONTH_NUM_DEL% LEQ 9 (
	set MONTH_CH_DEL=0%MONTH_NUM_DEL%
) else (
	set MONTH_CH_DEL=%MONTH_NUM_DEL%
)
set LOGFILE_DEL=%WKDIR%%MONTH_CH_DEL%%YEAR_DEL%proc.log
if exist %LOGFILE_DEL% del /q %LOGFILE_DEL%
powershell -executionpolicy bypass -command "%SCRIPT% %PARAMS%"


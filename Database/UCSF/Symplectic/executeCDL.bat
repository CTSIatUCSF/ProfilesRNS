set WORKDIR=%~dp0
echo WORKDIR=%WORKDIR%
cd /d %WORKDIR%
powershell -executionpolicy bypass -command %WORKDIR%UCLibrary_Pubs_with_params.ps1

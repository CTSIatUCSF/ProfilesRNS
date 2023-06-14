set projectDir=%1
"git.exe" rev-parse --abbrev-ref HEAD > %projectDir%GitVersion.txt
echo. >>  %projectDir%GitVersion.txt
"git.exe" rev-parse --short HEAD >>  %projectDir%GitVersion.txt

set projectDir=%1
"C:\Program Files\Git\bin\git.exe" rev-parse --abbrev-ref HEAD > %projectDir%GitVersion.txt
echo. >>  %projectDir%GitVersion.txt
"C:\Program Files\Git\bin\git.exe" describe --tags --long >>  %projectDir%GitVersion.txt

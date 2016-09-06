echo OFF
"C:\Program Files (x86)\Git\bin\git.exe" rev-parse --abbrev-ref HEAD > %1GitVersion.txt
echo. >> %1GitVersion.txt
"C:\Program Files (x86)\Git\bin\git.exe" describe --tags --long >> %1GitVersion.txt
@echo off
set /p projectName=Enter test name: 
set folderName="%projectName%Test"
mkdir "%foldername%"
echo ; Assembly file > "%foldername%\main.asm"
echo .ORIGx0000 >> "%foldername%\main.asm"
echo ; Start code here >> "%foldername%\main.asm"
echo. >> "%foldername%\main.asm"
echo. >> "%foldername%\main.asm"
echo. >> "%foldername%\main.asm"
echo .END >> "%foldername%\main.asm"
echo ; Define constants here >> "%foldername%\main.asm"
echo Folder "%foldername%" created with main.asm inside.

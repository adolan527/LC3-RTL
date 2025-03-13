@echo off
:: Get pathname
if "%~1"=="" ( 
    echo Usage: %~nx0 RELATIVE_PATHNAME
    exit /b 1
)

:: Go to specified path
cd /d "%~1" || exit /b 1 

:: Remove memdump
if exist pennsim_memDump.hex del /f /q pennsim_memDump.hex
:: Remove trace
if exist pennsim_trace.hex del /f /q pennsim_trace.hex 

:: Run PennSim script
echo script ../pennSimScript | java -jar ../PennSim.jar -t 

:: Creates .hex file
python ..\bin_to_hex.py main.obj main.hex

:: Pause to keep window open
:: set /p close=Press any key to quit:

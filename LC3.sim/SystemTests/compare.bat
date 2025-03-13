@echo off
:: Get pathname
if "%~1"=="" ( 
    echo Usage: %~nx0 RELATIVE_PATHNAME
    exit /b 1
)


python compare.py "%~1"

type "%~1"\sim.log

set /p close=Press any key to quit:
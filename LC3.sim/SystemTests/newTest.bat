@echo off
setlocal enabledelayedexpansion

:: Get user input
set /p projectName=Enter test name: 
set "folderName=%projectName%Test"
mkdir "%folderName%"

set "template_asm_path=TEST_TEMPLATE\TEMPLATE.asm"
set "template_tb_path=TEST_TEMPLATE\TEMPLATE_tb.v"
set "template_wcfg_path=TEST_TEMPLATE\TEMPLATE.wcfg"

set "output_asm_path=%folderName%/main.asm" 
set "output_tb_path=%folderName%/%projectName%_tb.v"
set "output_wcfg_path=%folderName%\%projectName%.wcfg"

set "search_name=REPLACENAMEHERE"
set "replace_name=%projectName%"

set "asm_search_date=REPLACEDATEHERE"

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "asm_replace_date=%datetime:~0,8%"


set "tb_search_path=REPLACEPATHHERE"
set "tb_replace_path=%folderName%"




python naming.py %template_asm_path% %output_asm_path% %search_name% %replace_name%
python naming.py %output_asm_path% %output_asm_path% %asm_search_date% %asm_replace_date%

python naming.py %template_tb_path% %output_tb_path% %tb_search_path% %tb_replace_path%
python naming.py %output_tb_path% %output_tb_path% %search_name% %replace_name%

python naming.py %template_wcfg_path% %output_wcfg_path% %search_name% %replace_name%



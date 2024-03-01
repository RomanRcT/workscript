@echo off
setlocal EnableDelayedExpansion
call init.cmd
:listBackups
set c=0
echo List of backups:
for %%x in (%BKP_DIR%\*.state) do (
set /a c+=1
set /p line=<%%x
echo ^| !c! ^| %%~nx	^| !line!  
)
if !c! equ 0 (
echo Nothing to restore.
goto end 
)
pause

@echo off
setlocal 
set c=0
if '%1'=='' goto :paramError
if '%2' NEQ '' (
  set choose=%2
  goto :deleteBackups
)
  echo List of backups:
for %%x in (%1\*.state) do (
  set /a c+=1
echo  %%~nx
)
if %c% equ 0 (
  echo Nothing to delete
  goto end
)
:chooseBackup
set /p choose=Enter backup for deleting:
if not exist %1\%choose%.state (
  echo File not found. Choose another.
  goto chooseBackup
)

:deleteBackups
:: echo list of files:
if not exist %1\%choose%.state (
  echo This restore point doesn't exist.
  goto end
)
for /F "delims= skip=2" %%i in (%1\%choose%.state) do (
  del %%i
)
del %1\%choose%.state
echo Backup %choose% was deleted.
goto end
:paramError
echo Usage %0 [bakup_dir] [bkp_name_to_delete] 

:end


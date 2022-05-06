@echo off
setlocal EnableDelayedExpansion
set backup_name=
set count=0
set descr=
set descr_init=
:: check parameters %1 - destination for backup file %2 bakup file name  %3 - directory for backup
if '%1'=='' goto :paramError
if '%2'=='' goto :paramError
if '%3'=='' goto :paramError
set bckpdest=%1
set bckpname=%2
for %%x in (!bckpdest!\!bckpname!*.7z) do @(set /a count+=1 >nul)
if not exist !bckpdest!\!bckpname!.7z goto createInitial
:: create incremental backup
echo Creating incremental backup.
:createIncr
if %count% lss 10 (
set "backup_name=incr_0%count%"
) else (
set "backup_name=incr_%count%"
)
if exist "!bckpdest!\%bckpname%_%backup_name%.7z" (
  echo File already exist. Backup doesn't created!
  goto end
)
if not exist "!bckpdest!\%backup_name%.state" (
set /p descr=Enter description of backup:
echo !descr! >> "!bckpdest!\%backup_name%.state"
echo FILELIST >> "!bckpdest!\%backup_name%.state"
)
7z u -mx1 !bckpdest!\!bckpname!.7z -u- -"up1q1r3x1y1z0w1^!!bckpdest!\!bckpname!_%backup_name%.7z" %3*
7z u -mx1 !bckpdest!\!bckpname!.7z %3* -up0q0r2x2y2z1w2
echo !bckpdest!\!bckpname!_%backup_name%.7z;%3 >> "!bckpdest!\%backup_name%.state"
goto end

:createInitial
echo Creating initial backup.
if not exist !bckpdest!\full.state (
set /p descr_init=Create description of initial state:
echo !descr_init! >> !bckpdest!\full.state
echo FILELIST >> !bckpdest!\full.state
)
7z a -mx1 !bckpdest!\!bckpname!.7z %3*
echo !bckpdest!\!bckpname!.7z;%3 >> !bckpdest!\full.state
goto end

:paramError
echo Usage %0 [destination_dir] [filename] [dir_to_backup]

:end

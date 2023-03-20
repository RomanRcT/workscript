@echo off
setlocal EnableDelayedExpansion
set backup_name=

if '%1'=='' goto :paramError
:listBackups
set c=0
echo List of backups:
for %%x in (%1\*.state) do (
set /a c+=1
set /p line=<%%x
echo ^| !c! ^| %%~nx	^| !line!  
)
if !c! equ 0 (
echo Nothing to restore.
goto end 
)
:chooseBackup
if NOT '%2'=='' (
set choose=%2
goto restoreBackups
) else (
set /p choose=Enter number of resore point to restore:
if 1!choose! equ +1!choose!  (
	if !choose! geq 1 (
		if !choose! leq !c! (
			goto restoreBackups
		)
	) 
)
)
echo Please enter 1 ^<= number ^<= !c!.
goto listBackups

:restoreBackups
for /F "tokens=1,2 delims=; skip=2" %%i in (%1\full.state) do (
  7z x -y %%i -o%%j
)
::set /a c=!c!-1
::set /a choose=!choose!-1
for /L %%n in (!c!,-1,!choose!) do (
if %%n lss 10 (
		set newval=incr_0%%n
	) else (
		set newval=incr_%%n
	)	
for /F "tokens=1,2 delims=; skip=2" %%y in (%1\!newval!.state) do (
   7z x -y %%y -o%%z
)
)

goto end
:paramError
echo Usage %0 [bakup_dir] 

:end

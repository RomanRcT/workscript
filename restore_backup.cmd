@echo off
:: BatchGotAdmin
:: :-------------------------------------
REM  --> Check for permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
 if '%errorlevel%' NEQ '0' (
  echo Requesting administrative privileges...
  goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
  echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
  set params= %*
  echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

  "%temp%\getadmin.vbs"
  del "%temp%\getadmin.vbs"
  exit /B

:gotAdmin
  pushd "%CD%"
  CD /D "%~dp0"
:--------------------------------------
call init.cmd
if %errorlevel% neq 0 (
goto error
)
echo Stop TC services...
sc stop "%TC_SERVER_NAME%"
sc stop "%PROCESS_NAME:~1,-1%"
sc stop "%FMS_NAME%"

echo Stop DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo shutdown immediate;  
) | sqlplus -s -l /nolog

::echo Copy database files from %ORACLE_DATA_DIR%
::7z x -aoa %BKP_DIR%\db_bkp.7z -o%ORACLE_DATA_DIR%\..\
::if exist %BKP_DIR%\fra_bkp.7z (
::7z x -aoa %BKP_DIR%\fra_bkp.7z -o%FRA_DIR%\..\ 
::)

call rest_bckp.cmd %BKP_DIR%
::echo Copy TC volume files from %TC_VOLUME_DIR%
::7z x -aoa %BKP_DIR%\tc_bkp.7z -o%TC_VOLUME_DIR%\..\

:: starting database and services back
echo Start DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo startup;  
) | sqlplus -s -l /nolog

echo Start DataBase %ORACLE_SID%
sc start "%FMS_NAME%"
sc start "%PROCESS_NAME:~1,-1%"
sc start "%TC_SERVER_NAME%"
:error
pause

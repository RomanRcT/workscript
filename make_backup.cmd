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
sc stop %TC_SERVER_NAME%
sc stop %PROCESS_NAME%
sc stop %FMS_NAME%

echo Stop DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo shutdown immediate;  
) | sqlplus -s -l /nolog

echo Copy database files from %ORACLE_DATA_DIR%
:: 7z a -aoa -mx1 %BKP_DIR%\db_bkp.7z %ORACLE_DATA_DIR%
call create_bckp.cmd %BKP_DIR% db_bkp %ORACLE_DATA_DIR%
if exist %FRA_DIR% (
:: 7z a -aoa -mx1 %BKP_DIR%\fra_bkp.7z %FRA_DIR%
call create_bckp.cmd %BKP_DIR% fra_bkp %FRA_DIR%
)

echo Copy TC volume files from %TC_VOLUME_DIR%
:: 7z a -aoa -mx1 %BKP_DIR%\tc_bkp.7z %TC_VOLUME_DIR%
call create_bckp.cmd %BKP_DIR% tc_bkp %TC_VOLUME_DIR%

:: starting database and services back
echo Start DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo startup;  
) | sqlplus -s -l /nolog

echo Start DataBase %ORACLE_SID%
sc start %FMS_NAME%
sc start %PROCESS_NAME%
sc start %TC_SERVER_NAME%
:error
pause

@echo off

set ORACLE_SID=tc
set TC_VOLUME_DIR=C:\Siemens\volume
set ORACLE_DATA_DIR=c:\oracle\database\oradata\tc\
set FRA_DIR=c:\oracle\database\flash_recovery_area\TC\
set BKP_DIR=C:\app\backup
set TC_DATA=C:\Siemens\tcdata
set TC_ROOT=C:\Siemens\Teamcenter13
set tcservicename="Teamcenter Server Manager config1_PoolA"
set fscservicename="Teamcenter FSC Service FSC_tcserver_user"
set processservicename="Teamcenter Process Manager"

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
echo Stop TC services...
sc stop %tcservicename%
sc stop %processservicename%
sc stop %fscservicename%

echo Stop DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo shutdown immediate;  
) | sqlplus -s -l /nolog

echo Copy database files from %ORACLE_DATA_DIR%
7z x -aoa %BKP_DIR%\db_bkp.7z -o%ORACLE_DATA_DIR%\..\
if exist %BKP_DIR%\fra_bkp.7z (
7z x -aoa %BKP_DIR%\fra_bkp.7z -o%FRA_DIR%\..\ 
)


echo Copy TC volume files from %TC_VOLUME_DIR%
7z x -aoa %BKP_DIR%\tc_bkp.7z -o%TC_VOLUME_DIR%\..\
if exist %BKP_DIR%\tcdata_bkp.7z (
  set /p ask="Do you want to restore TC_DATA directory(y/n)?"
  if %ask% == y (
 echo Copy TC data directory %TC_DATA%
 7z x -aoa %BKP_DIR%\tcdata_bkp.7z -o%TC_DATA%\..\
  )
)

:: starting database and services back
echo Start DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo startup;  
) | sqlplus -s -l /nolog

echo Start DataBase %ORACLE_SID%
sc start %fscservicename%
sc start %processservicename%
sc start %tcservicename%

pause

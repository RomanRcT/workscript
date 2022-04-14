@echo off
rem setlocal EnableDelayedExpansion
set err=0
rem ********** variables **************
set TC_ROOT=C:\Siemens\Teamcenter13
set TC_DATA=C:\Siemens\tcdata
set TNSLISTENER_NAME="OracleOraDB19Home1TNSListener"
set TC_SERVER_NAME="Teamcenter Server Manager config1_PoolA"
set FMS_NAME="Teamcenter FSC Service FSC_DESKTOP_6D2SMVG_user"
set PROCESS_NAME="Teamcenter Process Manager"
set dbapassfile="C:\Siemens\Teamcenter13\security\config1_infodba.pwf"
set ORACLE_SID=tc
set TC_VOLUME_DIR=C:\Siemens\volume
set ORACLE_DATA_DIR=c:\oracle\database\oradata\tc\
set FRA_DIR=c:\oracle\database\flash_recovery_area\TC\
set BKP_DIR=C:\app\backup
rem ********** end of variables **************

call :check TC_ROOT Directory
set /a err=%err%+%errorlevel%
call :check TC_DATA Directory
set /a err=%err%+%errorlevel%
call :check TC_VOLUME_DIR Directory
set /a err=%err%+%errorlevel%
call :check ORACLE_DATA_DIR Directory
set /a err=%err%+%errorlevel%
call :check FRA_DIR Directory
set /a err=%err%+%errorlevel%
call :check BKP_DIR Directory
set /a err=%err%+%errorlevel%
call :check dbapassfile File
set /a err=%err%+%errorlevel%
call :serviceexists PROCESS_NAME
set /a err=%err%+%errorlevel%
call :serviceexists TNSLISTENER_NAME
set /a err=%err%+%errorlevel%
call :serviceexists TC_SERVER_NAME
set /a err=%err%+%errorlevel%
call :serviceexists FMS_NAME
set /a err=%err%+%errorlevel%

call :oracheck ORACLE_SID
set /a err=%err%+%errorlevel%

goto end 
:check  
set _var=%1
rem set res=!%_var%!
call set res=%%%_var%%%
if not exist %res% (
echo ERROR. %2 %res% doesn't exist!
echo      Please check %_var% variable in the init.cmd file.
exit /B 1
)
exit /B 0

:serviceexists
set _var=%1
rem set res=!%_var%!
call set res=%%%_var%%%
sc query | findstr /C:"SERVICE_NAME: %res:~1,-1%">nul
if %errorlevel% == 0 (
  exit /B 0
) else (
  echo ERROR. Service %res% doesn't exist!
echo      Please check %_var% variable in the init.cmd file.
exit /B 1
)

:oracheck
set _var=%1
rem set res=!%_var%!
call set res=%%%_var%%%
tnsping %ORACLE_SID%>nul
if %errorlevel% == 0 (
  exit /B 0
) else (
echo ERROR. Unable to connect to Oracle database %ORACLE_SID%.
echo      Please check %_var% variable in the init.cmd file.
exit /B 1
)

:end 
if %err% gtr 0 (
  exit /B 1
) else (
  exit /B 0
)

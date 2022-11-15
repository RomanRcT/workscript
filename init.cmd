@echo off
REM setlocal EnableDelayedExpansion
set err=0
rem ********** variables **************
rem ==============
rem Services OralceTNSListener, TC FMS and Pool Manager will find automatically.
set TNSLISTENER_NAME=xxxxxxxx
set TC_SERVER_NAME=xxxxxxxxx
set FMS_NAME=xxxxxxxxxx
rem ==============
set AWC=no
set "TC_ROOT=C:\Siemens\Teamcenter10"
set "TC_DATA=C:\Siemens\tcdata"
set PROCESS_NAME="Teamcenter Process Manager"
set "dbapassfile=C:\Siemens\Teamcenter10\security\config1_infodba.pwf"
set ORACLE_SID=tc
set "TC_VOLUME_DIR=C:\Siemens\volume\"
set ORACLE_DATA_DIR=c:\app\oracle\oradata\tc\
set FRA_DIR=c:\app\oracle\flash_recovery_area\TC\
set BKP_DIR=C:\app\backup
rem ********** end of variables **************
:start
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
if "%AWC%"=="yes" (
call :serviceexists PROCESS_NAME 
set /a err=%err%+%errorlevel%
)
call :serviceexists2 TNSLISTENER_NAME *TNS*
set /a err=%err%+%errorlevel%
call :serviceexists2 TC_SERVER_NAME *Teamcenter*Pool*
set /a err=%err%+%errorlevel%
call :serviceexists2 FMS_NAME *FSC*
set /a err=%err%+%errorlevel%

rem call :oracheck ORACLE_SID
rem set /a err=%err%+%errorlevel%

goto end 

:check
set var_name=%1
rem set var_value=!%var_name%!
call set var_value=%%%var_name%%%
if not exist "%var_value%" (
echo ERROR. %2 %var_value% doesn't exist!
echo      Please check %var_name% variable in the init.cmd file.
exit /B 1
)
exit /B 0

:serviceexists2
set srvname=%2
REM echo srvname = %srvname%
powershell ./CheckSrv.ps1 %srvname%
set /p Myvar=<srvname.txt
if "%Myvar%"=="" (
del srvname.txt
exit /B 1
) else (
REM echo Myvar=[%Myvar%]
set "%~1=%Myvar%
del srvname.txt
exit /B 0
)
exit /B 1



:serviceexists
set var_name=%1
set search_str=%2
rem set var_value=!%var_name%!
call set var_value=%%%var_name%%%
sc query state= all | findstr /C:"SERVICE_NAME: %var_value:~1,-1%">nul
if %errorlevel% == 0 (
  exit /B 0
) else (
call :findservice %2 %var_name% %var_value%
REM set "%~1=%n%"
  REM echo ERROR. Service %var_value% doesn't exist!
REM echo      Please check %var_name% variable in the init.cmd file.
exit /B 1
)

:oracheck
set var_name=%1
rem set var_value=!%var_name%!
call set var_value=%%%var_name%%%
tnsping %ORACLE_SID%>nul
if %errorlevel% == 0 (
  exit /B 0
) else (
echo ERROR. Unable to connect to Oracle database %ORACLE_SID%.
echo      Please check %var_name% variable in the init.cmd file.
exit /B 1
)

:findservice
set search_str=%1
set var_name=%2
call set var_value=%%%var_name%%%
set n=
set sname=
sc query state= all | findstr %search_str% | findstr SERVICE_NAME > %temp%\var.txt
set /p sname=<%temp%\var.txt
if "%sname%"=="" (
set n=
) else (
set n="%sname:~14%"
)
if "%sname%"=="" (
  echo ERROR. Service %var_value% doesn't exist!
echo      Please check %var_name% variable in the init.cmd file.
exit /B 1
) else (
set "%~2=%n%"
set /a err=%err%-1
exit /B 0
)


:end 
if %err% gtr 0 (
  exit /B 1
) else (
  exit /B 0
)

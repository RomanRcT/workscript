@echo off
SETLOCAL EnableExtensions
set COUNTER=0
rem ********** variables **************
set TC_ROOT=C:\Siemens\Teamcenter10
set TC_DATA=C:\Siemens\tcdata
set TNSLISTENER_NAME="OracleOraDB12Home1TNSListener"
set TC_SERVER_NAME="Teamcenter Server Manager config1_PoolA"
set dbapassfile="C:\Siemens\Teamcenter10\security\config1_infodba.pwf"
rem ********** end of variables **************

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
echo UAC.ShellExecute "cmd.exe", "/c "%~s0"" %params:"="%", ", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B

:gotAdmin
pushd "%CD%"
CD /D "%~dp0"
:--------------------------------------


:query_tns
echo Checking service %TNSLISTENER_NAME%
sc query %TNSLISTENER_NAME% | findstr RUNNING

if %ERRORLEVEL% == 2 goto trouble
if %ERRORLEVEL% == 1 goto stopped
if %ERRORLEVEL% == 0 goto started

echo unknown status
goto end
:trouble
echo Oh noooo.. trouble mas bro
goto end
:started
echo %TNSLISTENER_NAME% is started
goto query_tc
:stopped
echo %TNSLISTENER_NAME% is stopped
echo Starting service
net start %TNSLISTENER_NAME%
goto restart_tc
:erro
echo Error please check your command.. mas bro 
goto end

:restart_tc
echo Need to restart %TC_SERVER_NAME% after starting %TNSLISTENER_NAME%
timeout 5
net stop %TC_SERVER_NAME%
timeout 3
net start %TC_SERVER_NAME%
timeout 3

:query_tc
echo Checking service %TC_SERVER_NAME%
sc query %TC_SERVER_NAME% | findstr RUNNING

if %ERRORLEVEL% == 2 goto troubletc
if %ERRORLEVEL% == 1 goto stoppedtc
if %ERRORLEVEL% == 0 goto startedtc

echo unknown status
goto end
:troubletc
echo Oh noooo.. trouble mas bro
goto end
:startedtc
echo %TC_SERVER_NAME% is started
goto checktcserver
:stoppedtc
echo %TC_SERVER_NAME% is stopped
echo Starting service
net start %TC_SERVER_NAME%
goto query_tc
:erro
echo Error please check your command.. mas bro 
goto end


:checktcserver
set /A COUNTER=%COUNTER%+1
if %COUNTER%==6 goto bigerror
echo [%COUNTER%] Checking running porcess for tcserver.exe
if %COUNTER%==1 (timeout 1) else (timeout 10)
tasklist /fi "ImageName eq tcserver.exe" /fo csv 2>NUL | find /I "tcserver.exe">NUL
if "%ERRORLEVEL%"=="0" goto checklogin
goto checktcserver

:checklogin
echo Check login to TC
call %TC_DATA%\tc_profilevars
list_users -u=infodba -pf=%dbapassfile% -g=dba | findstr infodba
if %ERRORLEVEL% == 1 goto notloggedin
if %ERRORLEVEL% == 0 goto loggedin

:loggedin
echo Teamcenter is working...
goto end

:bigerror
echo We are unable to start tcserver.exe
echo Ask administrator to help
goto end
:notloggedin
echo Can't login to TC database
echo Ask administrator to help
:end
pause

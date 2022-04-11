@echo off

set ORACLE_SID=tc
set TC_VOLUME_DIR=C:\Siemens\volume
set ORACLE_DATA_DIR=c:\app\oracle\oradata\tc\
set BKP_DIR=C:\app\backup
set TC_DATA=C:\Siemens\tcdata
set TC_ROOT=C:\Siemens\Teamcenter10

del /q %BKP_DIR%\*

echo Stop TC services...
sc stop "Teamcenter Server Manager config1_PoolA"
sc stop "Teamcenter FSC Service FSC_tcserver_user"

echo Stop DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo shutdown immediate;  
) | sqlplus -s -l /nolog

echo Copy database files from %ORACLE_DATA_DIR%
7z a -aoa -mx1 %BKP_DIR%\db_bkp.7z %ORACLE_DATA_DIR%



echo Copy TC volume files from %TC_VOLUME_DIR%
7z a -aoa -mx1 %BKP_DIR%\tc_bkp.7z %TC_VOLUME_DIR%
rem echo Copy TC data directory %TC_DATA%
rem 7z a -aoa -mx1 %BKP_DIR%\tcdata_bkp.7z %TC_DATA%

:: starting database and services back
echo Start DataBase %ORACLE_SID%
(
  echo conn / as sysdba;
  echo startup;  
) | sqlplus -s -l /nolog

echo Start DataBase %ORACLE_SID%
sc start "Teamcenter FSC Service FSC_tcserver_user"
sc start "Teamcenter Server Manager config1_PoolA"

pause

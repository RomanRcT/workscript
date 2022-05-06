# workscript
Some useful scripts for work.

## Backup and restore Oracle database, Teamcenter volume etc.

NOTE: Implemented incremental change

`name.7z` first created as initial state of working directories. 
Next backup states of working folder named from `name_incr_01.7z` to `name_incr_NN.7z`.
Information about backup is stored in the files with .state extension. For initial state this is the `full.state` file. For next states from `incr_01.state` to `incr_NN.state`.
Each backup as `full.state` as `incr_NN.state` can contains several backups, for example `volume_incr_03.7z`, `db_incr_03.7z`, `tcdata_incr_03.7z` and information about these backups are stored in the `incr_03.state` file.
File .state contains description of backup in the first row. There is a keyword FILELIST in the second row. Next rows contain list of backup files for this restore point and destination of archived directories (where backup will be restored). 

List of file `incr_02.state`
```
last changes 04.05.2022 
FILELIST
c:\app\backup\test_incr_02.7z;c:\test_folder
c:\app\backup\db_incr_02.7z;c:\oracle\oradata\TC
c:\app\backup\tcdata_incr_02.7z;c:\Teamcenter13\tcdata
```
If you create several backups consequently information about these backups are stored in one .state file. When you try to create next backup for created backup, a new .state file will be created and information about another backups for current state will be stored in this .state file.


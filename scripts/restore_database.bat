@echo off
REM Restore a PostgreSQL custom-format backup.
REM Usage:
REM restore_database.bat path_to_backup.dump

set PG_BIN=C:\Program Files\PostgreSQL\18\bin
set DB_NAME=production_capstone

if "%~1"=="" (
    echo Usage: restore_database.bat backup_file.dump
    exit /b 1
)

"%PG_BIN%\pg_restore.exe" -U postgres -d %DB_NAME% --clean --if-exists "%~1"

if %ERRORLEVEL% EQU 0 (
    echo Restore completed successfully.
) else (
    echo Restore failed.
    exit /b 1
)

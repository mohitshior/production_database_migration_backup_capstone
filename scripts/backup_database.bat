@echo off
REM Production capstone PostgreSQL backup script
REM Edit PG_BIN, DB_NAME and BACKUP_DIR for your machine.

set PG_BIN=C:\Program Files\PostgreSQL\18\bin
set DB_NAME=production_capstone
set BACKUP_DIR=.\backups

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

for /f "tokens=1-3 delims=/" %%a in ("%date%") do set TODAY=%%c-%%a-%%b

"%PG_BIN%\pg_dump.exe" -U postgres -d %DB_NAME% -F c -f "%BACKUP_DIR%\%DB_NAME%_%TODAY%.dump"

if %ERRORLEVEL% EQU 0 (
    echo Backup completed successfully.
) else (
    echo Backup failed.
    exit /b 1
)

# bcsh2

## Build pro produkci
- Visual Studio
- Build -> Publish app -> Folder
- Publish

## Spuštění aplikace
- otevřít terminál ve vygenerovaná složce
- nastavim proměnnou prostředí `CONNECTIONSTRINGS__DBCONNECTION` na connection string databáze, \
např. `set CONNECTIONSTRINGS__DBCONNECTION=Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=127.0.0.1)(PORT=1521)))(CONNECT_DATA=(SID=xe)));User ID=pepa;Password=pepa`
- spustit aplikaci skrz terminál pomocí `app.exe`
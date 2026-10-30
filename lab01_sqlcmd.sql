/* =====================================================================
   Лабораторна робота №1. SQL Server і командний рядок SQL
   Виконується в sqlcmd (командний рядок)

   Приклад 1.1. Запуск sqlcmd (у cmd / PowerShell):
       sqlcmd -S localhost -E          -- Windows-автентифікація
       sqlcmd -S localhost -U sa       -- SQL-автентифікація (далі пароль)
   Запуск цього файлу цілком:
       sqlcmd -S localhost -E -i lab01_sqlcmd.sql
   ===================================================================== */

-- Приклад 1.2. Перевірка бази даних за замовчуванням
SELECT DB_NAME() AS DefaultDatabase;
GO

-- Приклад 1.3. Список баз даних MS SQL Server (через системне подання)
SELECT name, database_id, create_date
FROM   sys.databases;
GO

-- Приклад 1.4. Список баз даних (через збережену процедуру)
EXEC sp_databases;
GO

-- Приклад 1.5. Перевірка середовища на чутливість до регістру
-- CI — нечутливий до регістру, CS — чутливий;
-- AI — нечутливий до акцентів, AS — чутливий.
SELECT SERVERPROPERTY('Collation') AS ServerCollation;
GO

-- Приклад 1.6. Те саме через процедуру sp_helpsort
EXEC sp_helpsort;
GO

-- Приклад 1.7. Перевірка випуску (версії та редакції) MS SQL Server
SELECT @@VERSION AS Version;
SELECT SERVERPROPERTY('Edition')        AS Edition,
       SERVERPROPERTY('ProductVersion') AS ProductVersion,
       SERVERPROPERTY('ProductLevel')   AS ProductLevel;
GO

-- Приклад 1.8. Перевірка режиму автентифікації
-- 1 — лише Windows-автентифікація;
-- 0 — змішаний режим (Windows + SQL Server).
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
           WHEN 1 THEN N'Windows Authentication'
           WHEN 0 THEN N'Windows and SQL Server Authentication'
       END AS AuthenticationMode;
GO

-- Приклад 1.9. Перелік змінних середовища sqlcmd
-- (команда sqlcmd, працює тільки в sqlcmd або в SQLCMD Mode)
:listvar
GO

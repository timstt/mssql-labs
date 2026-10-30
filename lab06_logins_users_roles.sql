/* =====================================================================
   Лабораторна робота №6. Облікові записи, користувачі, ролі
   Варіант 3. Усі запити виконуються в Azure Data Studio.

   !!! Паролі нижче — шаблонні. Перед виконанням заміни їх на свої
   і НЕ пуш справжні паролі на GitHub.
   Щоб входити під SQL-логінами, на сервері має бути ввімкнений
   змішаний режим автентифікації (див. лабу 1, приклад 1.8).
   ===================================================================== */

USE master;
GO

-- ---------------------------------------------------------------------
-- 1. Обліковий запис (login) для сервера
-- ---------------------------------------------------------------------
IF SUSER_ID(N'district_admin') IS NULL
    CREATE LOGIN district_admin
        WITH PASSWORD = N'ChangeMe_Admin1!',
             DEFAULT_DATABASE = SQLLAB,
             CHECK_POLICY = ON;

-- облікові записи для двох користувачів БД
IF SUSER_ID(N'district_viewer') IS NULL
    CREATE LOGIN district_viewer
        WITH PASSWORD = N'ChangeMe_Viewer1!',
             DEFAULT_DATABASE = SQLLAB;

IF SUSER_ID(N'district_operator') IS NULL
    CREATE LOGIN district_operator
        WITH PASSWORD = N'ChangeMe_Operator1!',
             DEFAULT_DATABASE = SQLLAB;
GO

USE SQLLAB;
GO

-- ---------------------------------------------------------------------
-- 2. Користувач для облікового запису district_admin
-- ---------------------------------------------------------------------
IF USER_ID(N'district_admin') IS NULL
    CREATE USER district_admin FOR LOGIN district_admin;
GO

-- ---------------------------------------------------------------------
-- 3. Два користувачі бази даних
-- ---------------------------------------------------------------------
IF USER_ID(N'viewer') IS NULL
    CREATE USER viewer   FOR LOGIN district_viewer;
IF USER_ID(N'operator') IS NULL
    CREATE USER operator FOR LOGIN district_operator;
GO

-- ---------------------------------------------------------------------
-- 4. Дві ролі:
--    ReadOnlyRole   — лише перегляд даних БД;
--    DataManagerRole — повна маніпуляція даними (SELECT/INSERT/UPDATE/DELETE).
-- ---------------------------------------------------------------------
IF DATABASE_PRINCIPAL_ID(N'ReadOnlyRole') IS NULL
    CREATE ROLE ReadOnlyRole;
IF DATABASE_PRINCIPAL_ID(N'DataManagerRole') IS NULL
    CREATE ROLE DataManagerRole;
GO

GRANT SELECT ON SCHEMA::dbo TO ReadOnlyRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO DataManagerRole;
GO

-- Додаємо користувачів до ролей
ALTER ROLE ReadOnlyRole    ADD MEMBER viewer;
ALTER ROLE DataManagerRole ADD MEMBER operator;
ALTER ROLE DataManagerRole ADD MEMBER district_admin;
-- старий синтаксис з методички:
-- EXEC sp_addrolemember 'ReadOnlyRole', 'viewer';
GO

-- Перевірка: хто в яких ролях
SELECT r.name AS RoleName, m.name AS MemberName
FROM   sys.database_role_members AS rm
JOIN   sys.database_principals   AS r ON r.principal_id = rm.role_principal_id
JOIN   sys.database_principals   AS m ON m.principal_id = rm.member_principal_id
WHERE  r.name IN (N'ReadOnlyRole', N'DataManagerRole');

-- Перевірка прав: viewer може читати, але не може змінювати
EXECUTE AS USER = N'viewer';
    SELECT TOP (3) * FROM dbo.Personnel;                       -- OK
    -- UPDATE dbo.Personnel SET Awards = N'Немає' WHERE ID = 2; -- помилка доступу
REVERT;
GO

/* =====================================================================
   Запити за варіантом 3
   ===================================================================== */

-- 1. Інформація про вид військ, який мав локацію на певній території (м. Одеса)
SELECT DISTINCT t.ID, t.Name AS MilitaryType, l.Country, l.City, l.Address
FROM   dbo.MilitaryTypes AS t
JOIN   dbo.Units         AS u ON u.MilitaryTypeID = t.ID
JOIN   dbo.Locations     AS l ON l.Id             = u.LocationID
WHERE  l.City = N'Одеса';

-- 2. Інформація про військовослужбовців і їх частину
SELECT p.FullName, p.Position, p.YearsOfService, c.CompanyNumber, u.UnitNumber
FROM   dbo.Personnel AS p
JOIN   dbo.Companies AS c ON c.ID         = p.CompanyID
JOIN   dbo.Units     AS u ON u.UnitNumber = c.UnitNumber;

-- 3. Військовослужбовці, їх вид військ, номер частини і дислокація
SELECT p.FullName,
       p.Position,
       t.Name       AS MilitaryType,
       u.UnitNumber,
       l.Country,
       l.City,
       l.Address
FROM   dbo.Personnel     AS p
JOIN   dbo.Companies     AS c ON c.ID         = p.CompanyID
JOIN   dbo.Units         AS u ON u.UnitNumber = c.UnitNumber
JOIN   dbo.MilitaryTypes AS t ON t.ID         = u.MilitaryTypeID
JOIN   dbo.Locations     AS l ON l.Id         = u.LocationID;
GO

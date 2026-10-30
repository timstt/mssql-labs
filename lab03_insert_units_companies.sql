/* =====================================================================
   Лабораторна робота №3. Робота з Azure Data Studio. Додавання даних
   Варіант 3

   1. За допомогою запиту додати у другу таблицю (MilitaryTypes)
      5 записів — запит виконати у командному рядку:
          sqlcmd -S localhost -E -d SQLLAB -i lab03_insert_units_companies.sql
   2. Створити таблиці частини і роти:
      Частини (Units): номер частини, вид військ, місце дислокації.
      Роти (Companies): номер роти, номер частини.
   ===================================================================== */

USE SQLLAB;
GO

-- ---------------------------------------------------------------------
-- 1. Додавання 5 записів у таблицю «вид військ»
-- ---------------------------------------------------------------------
INSERT INTO dbo.MilitaryTypes (Name)
VALUES (N'Десантно-штурмові війська'),
       (N'Сили територіальної оборони'),
       (N'Війська ППО'),
       (N'Війська зв''язку'),
       (N'Інженерні війська');
GO

SELECT * FROM dbo.MilitaryTypes;
GO

-- ---------------------------------------------------------------------
-- 2. Таблиця «частини» (зв'язана з видом військ і місцем дислокації)
-- ---------------------------------------------------------------------
CREATE TABLE dbo.Units (
    UnitNumber     INT NOT NULL PRIMARY KEY,                       -- номер частини
    MilitaryTypeID INT NOT NULL
        CONSTRAINT FK_Units_MilitaryTypes REFERENCES dbo.MilitaryTypes(ID),
    LocationID     INT NOT NULL
        CONSTRAINT FK_Units_Locations     REFERENCES dbo.Locations(Id)
);
GO

-- ---------------------------------------------------------------------
-- 3. Таблиця «роти» (зв'язана з частинами)
-- ---------------------------------------------------------------------
CREATE TABLE dbo.Companies (
    CompanyNumber INT NOT NULL,                                    -- номер роти
    UnitNumber    INT NOT NULL
        CONSTRAINT FK_Companies_Units REFERENCES dbo.Units(UnitNumber),
    ID            INT IDENTITY(1,1) PRIMARY KEY
);
GO

-- ---------------------------------------------------------------------
-- Наповнення: ще 2 місця дислокації, 5 частин і 3 роти
-- ---------------------------------------------------------------------
INSERT INTO dbo.Locations (Country, City, Address, Area)
VALUES (N'Україна', N'Житомир', N'вул. Чуднівська, 103', 320.10),
       (N'Україна', N'Дніпро',  N'вул. Робоча, 55',      180.25);

INSERT INTO dbo.Units (UnitNumber, MilitaryTypeID, LocationID)
VALUES (101, 1, 1),
       (204, 3, 2),
       (315, 3, 3),
       (408, 4, 4),
       (512, 5, 5);

INSERT INTO dbo.Companies (CompanyNumber, UnitNumber)
VALUES (1, 101),
       (2, 204),
       (3, 315);
GO

SELECT * FROM dbo.Units;
SELECT * FROM dbo.Companies;
GO

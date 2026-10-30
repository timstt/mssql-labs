/* =====================================================================
   Лабораторна робота №5. Багатотабличні запити. Запити на з'єднання
   Варіант 3
   ===================================================================== */

USE SQLLAB;
GO

/* =====================================================================
   Частина 1 (консоль): з'єднання таблиць MilitaryTypes і Units
   ===================================================================== */

-- 1. Декартів добуток двох таблиць
SELECT t.ID, t.Name, u.UnitNumber, u.MilitaryTypeID
FROM   dbo.MilitaryTypes AS t
CROSS JOIN dbo.Units     AS u;

-- те саме в старому синтаксисі
SELECT * FROM dbo.MilitaryTypes, dbo.Units;

-- 2. Ліве зовнішнє з'єднання: усі види військ, навіть без частин (NULL)
SELECT t.Name AS MilitaryType, u.UnitNumber
FROM   dbo.MilitaryTypes AS t
LEFT JOIN dbo.Units      AS u ON u.MilitaryTypeID = t.ID;

-- 3. Праве зовнішнє з'єднання: усі частини з їх видом військ
SELECT t.Name AS MilitaryType, u.UnitNumber
FROM   dbo.MilitaryTypes AS t
RIGHT JOIN dbo.Units     AS u ON u.MilitaryTypeID = t.ID;
GO

/* =====================================================================
   Частина 2 (SSMS): індивідуальні завдання за варіантом 3
   ===================================================================== */

-- ---------------------------------------------------------------------
-- 1. Таблиця особового складу військовослужбовців
--    ПІБ, рота, посада, рік народження, рік надходження на службу,
--    вислуга (років), нагороди, участь у військових заходах.
--    Зв'язана з таблицею Companies (рота).
-- ---------------------------------------------------------------------
CREATE TABLE dbo.Personnel (
    ID               INT IDENTITY(1,1) PRIMARY KEY,
    FullName         NVARCHAR(100) NOT NULL,
    Position         NVARCHAR(50)  NOT NULL,
    BirthYear        INT           NOT NULL,
    EnrollmentYear   INT           NOT NULL,
    YearsOfService   INT           NOT NULL,
    Awards           NVARCHAR(100) NULL,
    CombatExperience NVARCHAR(10)  NULL,           -- Так / Ні
    CompanyID        INT           NOT NULL
        CONSTRAINT FK_Personnel_Companies REFERENCES dbo.Companies(ID)
);
GO

INSERT INTO dbo.Personnel
       (FullName, Position, BirthYear, EnrollmentYear, YearsOfService, Awards, CombatExperience, CompanyID)
VALUES (N'Шевченко О.М.', N'Сержант',   1995, 2015, 11, N'За відвагу',                     N'Так', 1),
       (N'Коваленко І.П.', N'Солдат',    1999, 2019,  7, N'Немає',                          N'Ні',  1),
       (N'Ткачук В.С.',    N'Лейтенант', 1990, 2012, 14, N'Орден Данила Галицького',        N'Так', 2),
       (N'Бойко М.В.',     N'Капрал',    1997, 2018,  8, N'Немає',                          N'Так', 2),
       (N'Мельник А.О.',   N'Солдат',    2001, 2021,  5, N'Немає',                          N'Ні',  1);
GO

-- ---------------------------------------------------------------------
-- 2. Весь особовий склад з номером частини, роти і видом військ
-- ---------------------------------------------------------------------
SELECT p.FullName,
       p.Position,
       c.CompanyNumber AS Company,
       u.UnitNumber    AS Unit,
       t.Name          AS MilitaryType
FROM   dbo.Personnel     AS p
JOIN   dbo.Companies     AS c ON c.ID         = p.CompanyID
JOIN   dbo.Units         AS u ON u.UnitNumber = c.UnitNumber
JOIN   dbo.MilitaryTypes AS t ON t.ID         = u.MilitaryTypeID
ORDER BY u.UnitNumber, c.CompanyNumber, p.FullName;

-- ---------------------------------------------------------------------
-- 3. Військовослужбовці та дислокація певної частини на певну дату.
--    На вказану дату в частині служать ті, хто надійшов на службу
--    не пізніше року цієї дати.
-- ---------------------------------------------------------------------
DECLARE @UnitNumber INT  = 101;
DECLARE @OnDate     DATE = '2020-01-01';

SELECT p.FullName,
       p.Position,
       p.EnrollmentYear,
       u.UnitNumber,
       l.Country,
       l.City,
       l.Address,
       @OnDate AS OnDate
FROM   dbo.Personnel AS p
JOIN   dbo.Companies AS c ON c.ID         = p.CompanyID
JOIN   dbo.Units     AS u ON u.UnitNumber = c.UnitNumber
JOIN   dbo.Locations AS l ON l.Id         = u.LocationID
WHERE  u.UnitNumber     = @UnitNumber
  AND  p.EnrollmentYear <= YEAR(@OnDate);
GO

-- 4. Діаграма БД будується в SSMS: Database Diagrams -> New Database Diagram
--    (додати всі таблиці, зв'язки підтягнуться з FOREIGN KEY).

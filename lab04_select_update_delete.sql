/* =====================================================================
   Лабораторна робота №4. Вибірки даних, редагування і видалення даних
   Варіант 3
   ===================================================================== */

USE SQLLAB;
GO

/* ---------------------------------------------------------------------
   Частина 1 (командна консоль sqlcmd): зміна трьох записів
   --------------------------------------------------------------------- */
UPDATE dbo.Locations
SET    Area = 160.00
WHERE  City = N'Київ';

UPDATE dbo.Locations
SET    Area = 210.00
WHERE  City = N'Львів';

UPDATE dbo.MilitaryTypes
SET    Name = N'Військово-Морські Сили'
WHERE  Name = N'ВМС';
GO

/* ---------------------------------------------------------------------
   Частина 2 (командна консоль sqlcmd): видалення одного запису
   (вид військ, на який не посилається жодна частина)
   --------------------------------------------------------------------- */
DELETE FROM dbo.MilitaryTypes
WHERE  Name = N'Інженерні війська';
GO

SELECT * FROM dbo.Locations;
SELECT * FROM dbo.MilitaryTypes;
GO

/* ---------------------------------------------------------------------
   Частина 3 (Azure Data Studio): запити за варіантом 3
   --------------------------------------------------------------------- */

-- 1. Вивести всі частини за певним місцем дислокації (м. Київ)
SELECT u.UnitNumber, u.MilitaryTypeID, l.City, l.Address
FROM   dbo.Units     AS u
JOIN   dbo.Locations AS l ON l.Id = u.LocationID
WHERE  l.City = N'Київ';

-- Варіант без з'єднання (тільки через WHERE + підзапит)
SELECT *
FROM   dbo.Units
WHERE  LocationID IN (SELECT Id FROM dbo.Locations WHERE City = N'Київ');

-- 2. Вивести всі роти, відсортовані за номером у зворотному порядку
SELECT *
FROM   dbo.Companies
ORDER BY CompanyNumber DESC;

-- 3. Вивести місця дислокації військ в Україні, площа яких перевищує 10 кв. км
SELECT *
FROM   dbo.Locations
WHERE  Country = N'Україна'
  AND  Area > 10;
GO

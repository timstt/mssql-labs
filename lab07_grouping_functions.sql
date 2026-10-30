/* =====================================================================
   Лабораторна робота №7. Групування. Вбудовані функції
   Варіант 3
   ===================================================================== */

USE SQLLAB;
GO

-- 1. Найменша площа дислокації частини
SELECT MIN(l.Area) AS MinArea
FROM   dbo.Locations AS l
WHERE  l.Id IN (SELECT LocationID FROM dbo.Units);

-- з виведенням, якій частині вона належить
SELECT TOP (1) WITH TIES u.UnitNumber, l.City, l.Area
FROM   dbo.Units     AS u
JOIN   dbo.Locations AS l ON l.Id = u.LocationID
ORDER BY l.Area ASC;

-- 2. Кількість частин, площа дислокації яких більша ніж 10 000 м2
SELECT COUNT(*) AS UnitsCount
FROM   dbo.Units     AS u
JOIN   dbo.Locations AS l ON l.Id = u.LocationID
WHERE  l.Area > 10000;

-- 3. Згрупувати весь особовий склад за ротами
SELECT c.CompanyNumber,
       c.UnitNumber,
       COUNT(p.ID)                     AS PersonnelCount,
       AVG(p.YearsOfService)           AS AvgYearsOfService,
       STRING_AGG(p.FullName, N', ')   AS PersonnelList
FROM   dbo.Companies AS c
LEFT JOIN dbo.Personnel AS p ON p.CompanyID = c.ID
GROUP BY c.CompanyNumber, c.UnitNumber
ORDER BY c.CompanyNumber;

-- лише роти, в яких більше 2 військовослужбовців (HAVING)
SELECT c.CompanyNumber, COUNT(*) AS PersonnelCount
FROM   dbo.Companies AS c
JOIN   dbo.Personnel AS p ON p.CompanyID = c.ID
GROUP BY c.CompanyNumber
HAVING COUNT(*) > 2;

-- 4. Особовий склад певної роти (рота №1)
SELECT p.*
FROM   dbo.Personnel AS p
JOIN   dbo.Companies AS c ON c.ID = p.CompanyID
WHERE  c.CompanyNumber = 1
ORDER BY p.FullName;
GO

-- Додатково: вбудовані символьні, числові та часові функції
SELECT UPPER(FullName)                       AS UpperName,
       LEN(FullName)                         AS NameLength,
       LEFT(FullName, CHARINDEX(N' ', FullName) - 1) AS LastName,
       YEAR(GETDATE()) - BirthYear           AS Age,
       DATEDIFF(MONTH, DATEFROMPARTS(EnrollmentYear, 1, 1), GETDATE()) AS MonthsOfService,
       FORMAT(GETDATE(), 'dd.MM.yyyy')       AS Today
FROM   dbo.Personnel;
GO

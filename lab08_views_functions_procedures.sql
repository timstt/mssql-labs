/* =====================================================================
   Лабораторна робота №8. Програмування на T-SQL. Подання
   Варіант 3. Виконувати в MS SQL Server Management Studio.
   ===================================================================== */

USE SQLLAB;
GO

/* ---------------------------------------------------------------------
   1. Подання: за видом військ — інформація про роти та їх особовий склад
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vw_CompaniesByMilitaryType
AS
SELECT t.Name          AS MilitaryType,
       u.UnitNumber,
       c.CompanyNumber,
       p.FullName,
       p.Position,
       p.YearsOfService,
       p.Awards,
       p.CombatExperience
FROM   dbo.MilitaryTypes AS t
JOIN   dbo.Units         AS u ON u.MilitaryTypeID = t.ID
JOIN   dbo.Companies     AS c ON c.UnitNumber     = u.UnitNumber
LEFT JOIN dbo.Personnel  AS p ON p.CompanyID      = c.ID;
GO

-- Перегляд подання для певного виду військ
SELECT *
FROM   dbo.vw_CompaniesByMilitaryType
WHERE  MilitaryType = N'Артилерія';
GO

/* ---------------------------------------------------------------------
   2. Скалярна функція: розв'язок квадратного рівняння A*x^2 + B*x + C = 0
   --------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fn_SolveQuadratic (@A FLOAT, @B FLOAT, @C FLOAT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Result NVARCHAR(200);
    DECLARE @D FLOAT;

    IF @A = 0
    BEGIN
        IF @B = 0
            SET @Result = CASE WHEN @C = 0 THEN N'x — будь-яке число'
                               ELSE N'Розв''язків немає' END;
        ELSE
            SET @Result = N'Лінійне рівняння: x = ' + CAST(ROUND(-@C / @B, 4) AS NVARCHAR(50));
        RETURN @Result;
    END

    SET @D = @B * @B - 4 * @A * @C;

    IF @D > 0
        SET @Result = N'D = '  + CAST(@D AS NVARCHAR(50))
                    + N'; x1 = ' + CAST(ROUND((-@B + SQRT(@D)) / (2 * @A), 4) AS NVARCHAR(50))
                    + N'; x2 = ' + CAST(ROUND((-@B - SQRT(@D)) / (2 * @A), 4) AS NVARCHAR(50));
    ELSE IF @D = 0
        SET @Result = N'D = 0; x = ' + CAST(ROUND(-@B / (2 * @A), 4) AS NVARCHAR(50));
    ELSE
        SET @Result = N'D = ' + CAST(@D AS NVARCHAR(50)) + N' < 0; дійсних коренів немає';

    RETURN @Result;
END
GO

SELECT dbo.fn_SolveQuadratic(1, -3, 2) AS TwoRoots,   -- x1 = 2, x2 = 1
       dbo.fn_SolveQuadratic(1, 2, 1)  AS OneRoot,    -- x = -1
       dbo.fn_SolveQuadratic(1, 0, 4)  AS NoRoots;
GO

/* ---------------------------------------------------------------------
   3. Табличну функцію: за роком надходження на службу повертає
      всю інформацію про особовий склад
   --------------------------------------------------------------------- */
CREATE OR ALTER FUNCTION dbo.fn_PersonnelByYear (@Year INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.ID,
           p.FullName,
           p.Position,
           p.BirthYear,
           p.EnrollmentYear,
           p.YearsOfService,
           p.Awards,
           p.CombatExperience,
           c.CompanyNumber,
           u.UnitNumber,
           t.Name AS MilitaryType
    FROM   dbo.Personnel     AS p
    JOIN   dbo.Companies     AS c ON c.ID         = p.CompanyID
    JOIN   dbo.Units         AS u ON u.UnitNumber = c.UnitNumber
    JOIN   dbo.MilitaryTypes AS t ON t.ID         = u.MilitaryTypeID
    WHERE  p.EnrollmentYear = @Year
);
GO

SELECT * FROM dbo.fn_PersonnelByYear(2019);
GO

/* ---------------------------------------------------------------------
   4. Процедура: сума всіх площ місць дислокації частин
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.sp_TotalDeploymentArea
    @TotalArea DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalArea = SUM(l.Area)
    FROM   dbo.Locations AS l
    WHERE  l.Id IN (SELECT LocationID FROM dbo.Units);
END
GO

DECLARE @Area DECIMAL(12,2);
EXEC dbo.sp_TotalDeploymentArea @TotalArea = @Area OUTPUT;
SELECT @Area AS TotalDeploymentArea;
GO

-- Видалення об'єктів (для довідки)
-- DROP VIEW dbo.vw_CompaniesByMilitaryType;
-- DROP FUNCTION dbo.fn_SolveQuadratic;
-- DROP FUNCTION dbo.fn_PersonnelByYear;
-- DROP PROCEDURE dbo.sp_TotalDeploymentArea;

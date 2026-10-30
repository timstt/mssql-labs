/* =====================================================================
   Лабораторна робота №9. Тригери. Транзакції
   Варіант 3 — Інформаційна система військового округу
   СУБД: MS SQL Server 2022, виконувати в Azure Data Studio

   Таблиці БД: MilitaryTypes, Locations, Units, Companies,
               Personnel, PersonnelLog
   ===================================================================== */


USE [SQLLAB];
GO


/* =====================================================================
   0. Таблиця журналу змін особового складу
   (створюється тільки якщо її ще немає)
   ===================================================================== */
IF OBJECT_ID(N'dbo.PersonnelLog', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PersonnelLog (
        LogID       INT IDENTITY(1,1) PRIMARY KEY,
        Action      NVARCHAR(10)  NOT NULL,          -- INSERT / UPDATE / DELETE
        PersonID    INT           NOT NULL,
        FullName    NVARCHAR(100) NULL,
        OldPosition NVARCHAR(50)  NULL,
        NewPosition NVARCHAR(50)  NULL,
        ActionDate  DATETIME      NOT NULL DEFAULT GETDATE()
    );
END
GO


/* =====================================================================
   9.1 ТРИГЕРИ
   ===================================================================== */

-- ---------------------------------------------------------------------
-- Тригер на ДОДАВАННЯ (AFTER INSERT)
-- 1) автоматично рахує вислугу років: поточний рік - рік надходження
--    (аналог прикладу 9.1, де тригер змінює щойно вставлені дані);
-- 2) записує подію в журнал PersonnelLog.
-- Дані беруться з віртуальної таблиці INSERTED.
-- ---------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Personnel_Insert
ON dbo.Personnel
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET    p.YearsOfService = YEAR(GETDATE()) - i.EnrollmentYear
    FROM   dbo.Personnel AS p
    JOIN   inserted      AS i ON i.ID = p.ID;

    INSERT INTO dbo.PersonnelLog (Action, PersonID, FullName, OldPosition, NewPosition, ActionDate)
    SELECT N'INSERT', i.ID, i.FullName, NULL, i.Position, GETDATE()
    FROM   inserted AS i;
END
GO

-- ---------------------------------------------------------------------
-- Тригер на РЕДАГУВАННЯ (AFTER UPDATE)
-- 1) якщо змінили рік надходження — перераховує вислугу;
-- 2) якщо змінилась посада (підвищення/пониження) — пише в журнал
--    стару посаду (DELETED) і нову посаду (INSERTED).
-- ---------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Personnel_Update
ON dbo.Personnel
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(EnrollmentYear)
    BEGIN
        UPDATE p
        SET    p.YearsOfService = YEAR(GETDATE()) - i.EnrollmentYear
        FROM   dbo.Personnel AS p
        JOIN   inserted      AS i ON i.ID = p.ID;
    END

    INSERT INTO dbo.PersonnelLog (Action, PersonID, FullName, OldPosition, NewPosition, ActionDate)
    SELECT N'UPDATE', i.ID, i.FullName, d.Position, i.Position, GETDATE()
    FROM   inserted AS i
    JOIN   deleted  AS d ON d.ID = i.ID
    WHERE  ISNULL(d.Position, N'') <> ISNULL(i.Position, N'');
END
GO

-- ---------------------------------------------------------------------
-- Тригер на ВИДАЛЕННЯ (AFTER DELETE)
-- Зберігає в журналі, кого саме видалили (дані з таблиці DELETED),
-- щоб інформація про звільненого військовослужбовця не зникла.
-- ---------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Personnel_Delete
ON dbo.Personnel
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.PersonnelLog (Action, PersonID, FullName, OldPosition, NewPosition, ActionDate)
    SELECT N'DELETE', d.ID, d.FullName, d.Position, NULL, GETDATE()
    FROM   deleted AS d;
END
GO

-- ---------------------------------------------------------------------
-- Перевірка роботи тригерів
-- ---------------------------------------------------------------------
-- INSERT: вислугу передаємо 0 — тригер сам її порахує
INSERT INTO dbo.Personnel
       (FullName, Position, BirthYear, EnrollmentYear, YearsOfService, Awards, CombatExperience, CompanyID)
VALUES (N'Гончаренко Д.С.', N'Солдат', 2002, 2022, 0, N'Немає', N'Ні', 3);

-- UPDATE: підвищення в посаді
UPDATE dbo.Personnel
SET    Position = N'Молодший сержант'
WHERE  FullName = N'Гончаренко Д.С.';

-- DELETE: звільнення зі служби
DELETE FROM dbo.Personnel
WHERE  FullName = N'Гончаренко Д.С.';

SELECT * FROM dbo.Personnel;
SELECT * FROM dbo.PersonnelLog ORDER BY LogID;
GO

-- ---------------------------------------------------------------------
-- Керування тригерами: вимкнення / увімкнення / видалення
-- ---------------------------------------------------------------------
DISABLE TRIGGER dbo.trg_Personnel_Delete ON dbo.Personnel;
ENABLE  TRIGGER dbo.trg_Personnel_Delete ON dbo.Personnel;

-- Список тригерів таблиці Personnel та їх стан
SELECT name, is_disabled, create_date
FROM   sys.triggers
WHERE  parent_id = OBJECT_ID(N'dbo.Personnel');

-- Видалення (не виконувати, якщо тригер ще потрібен):
-- DROP TRIGGER dbo.trg_Personnel_Delete;
GO


/* =====================================================================
   9.2 ТРАНЗАКЦІЇ
   ===================================================================== */

-- ---------------------------------------------------------------------
-- Приклад 9.2. Очищення таблиці в транзакції і відкат
-- До відкату таблиця Personnel порожня, після ROLLBACK дані відновлюються.
-- Записи, які тригер на видалення додав у PersonnelLog, теж відкочуються.
-- ---------------------------------------------------------------------
-- Починаємо транзакцію
BEGIN TRANSACTION;

-- Очищаємо таблицю особового складу
DELETE FROM dbo.Personnel;

SELECT * FROM dbo.Personnel;      -- порожньо
SELECT * FROM dbo.PersonnelLog;   -- тут видно записи DELETE від тригера

ROLLBACK TRANSACTION;

SELECT * FROM dbo.Personnel;      -- дані повернулися
SELECT * FROM dbo.PersonnelLog;   -- записи DELETE зникли
GO

-- ---------------------------------------------------------------------
-- Приклад 9.3. Дві послідовні транзакції
-- Перша: додає військовослужбовця і змінює його посаду -> COMMIT.
-- Друга: ще раз змінює посаду -> ROLLBACK (зміна скасовується).
-- ---------------------------------------------------------------------
-- Починаємо транзакцію
BEGIN TRANSACTION;

-- Вставляємо рядок даних у таблицю особового складу
INSERT INTO dbo.Personnel
       (FullName, Position, BirthYear, EnrollmentYear, YearsOfService, Awards, CombatExperience, CompanyID)
VALUES (N'Савченко Р.В.', N'Солдат', 2000, 2020, 0, N'Немає', N'Так', 2);

-- Оновлюємо дані в останньому рядку
UPDATE dbo.Personnel
SET    Position = N'Старший солдат'
WHERE  FullName = N'Савченко Р.В.';

COMMIT TRANSACTION;

BEGIN TRANSACTION;
-- Оновлюємо дані в останньому рядку
UPDATE dbo.Personnel
SET    Position = N'Капрал'
WHERE  FullName = N'Савченко Р.В.';

-- Відкочуємо транзакцію
ROLLBACK TRANSACTION;

-- Вибираємо всі дані з таблиці (посада залишиться «Старший солдат»)
SELECT * FROM dbo.Personnel;
SELECT * FROM dbo.PersonnelLog ORDER BY LogID;
GO

-- ---------------------------------------------------------------------
-- Приклад 9.4. Вкладені транзакції
-- !!! Зверніть увагу: YearsOfService передаємо 0, але в результаті
-- буде 2 (2026 - 2024), бо спрацьовує тригер на вставку.
-- ---------------------------------------------------------------------
BEGIN TRANSACTION T1;

-- Вставляємо рядок даних у таблицю особового складу
INSERT INTO dbo.Personnel
       (FullName, Position, BirthYear, EnrollmentYear, YearsOfService, Awards, CombatExperience, CompanyID)
VALUES (N'Литвиненко О.І.', N'Солдат', 2004, 2024, 0, N'Немає', N'Ні', 1);

SELECT @@TRANCOUNT AS TranCount_T1;   -- 1

-- Починаємо транзакцію 2
BEGIN TRANSACTION T2;

-- Оновлюємо дані в останньому рядку
UPDATE dbo.Personnel
SET    Awards = N'За оборону України'
WHERE  FullName = N'Литвиненко О.І.';

SELECT @@TRANCOUNT AS TranCount_T2;   -- 2

COMMIT TRANSACTION T2;

-- Запам'ятовуємо зміни
COMMIT TRANSACTION T1;

-- Вибираємо всі дані з таблиці
SELECT * FROM dbo.Personnel;
GO

-- ---------------------------------------------------------------------
-- Приклад 9.5. Відкат до точки збереження (SAVE TRANSACTION)
-- Вставка зберігається, а зміна посади після точки збереження скасовується.
-- !!! Вислуга знову порахована тригером на вставку.
-- ---------------------------------------------------------------------
-- Починаємо транзакцію
BEGIN TRANSACTION T1;

-- Вставляємо рядок даних у таблицю особового складу
INSERT INTO dbo.Personnel
       (FullName, Position, BirthYear, EnrollmentYear, YearsOfService, Awards, CombatExperience, CompanyID)
VALUES (N'Кравчук А.М.', N'Солдат', 1998, 2017, 0, N'Немає', N'Так', 3);

-- Зберігаємо транзакцію (точка збереження)
SAVE TRANSACTION ins_complete;

-- Оновлюємо дані в останньому рядку
UPDATE dbo.Personnel
SET    Position = N'Сержант'
WHERE  FullName = N'Кравчук А.М.';

-- Відкочуємо транзакцію до точки збереження
ROLLBACK TRANSACTION ins_complete;

-- Запам'ятовуємо зміни
COMMIT TRANSACTION T1;

-- Вибираємо всі дані з таблиці (Кравчук А.М. — «Солдат», не «Сержант»)
SELECT * FROM dbo.Personnel;
SELECT * FROM dbo.PersonnelLog ORDER BY LogID;
GO


/* =====================================================================
   Очищення тестових даних (розкоментувати, щоб повторно запускати скрипт)
   ===================================================================== */
-- DELETE FROM dbo.Personnel
-- WHERE FullName IN (N'Савченко Р.В.', N'Литвиненко О.І.', N'Кравчук А.М.');
-- TRUNCATE TABLE dbo.PersonnelLog;

# SQL — лабораторні роботи 1–9 (MS SQL Server)

Лабораторні роботи з дисципліни «SQL» (КНУ ім. Тараса Шевченка, ФІТ, спеціальність 121 «Інженерія програмного забезпечення»).
**Варіант 3 — інформаційна система військового округу.**

## Структура БД `SQLLAB`

| Таблиця | Призначення | Ключові поля |
|---|---|---|
| `MilitaryTypes` | вид військ | `ID`, `Name` |
| `Locations` | місця дислокації | `Id`, `Country`, `City`, `Address`, `Area` |
| `Units` | військові частини | `UnitNumber` → `MilitaryTypes`, `Locations` |
| `Companies` | роти | `ID`, `CompanyNumber`, `UnitNumber` → `Units` |
| `Personnel` | особовий склад | `ID`, `FullName`, `Position`, …, `CompanyID` → `Companies` |
| `PersonnelLog` | журнал змін особового складу (заповнюють тригери) | `LogID`, `Action`, `PersonID`, `OldPosition`, `NewPosition`, `ActionDate` |

```
MilitaryTypes ─┐
               ├─< Units ─< Companies ─< Personnel ··· PersonnelLog (тригери)
Locations ─────┘
```

## Лабораторні

| № | Тема | Файл |
|---|---|---|
| 1 | SQL Server і командний рядок (sqlcmd) | [`lab01_sqlcmd.sql`](lab01_sqlcmd.sql) |
| 2 | Створення БД і таблиць | [`lab02_create_db_tables.sql`](lab02_create_db_tables.sql) |
| 3 | Azure Data Studio, додавання даних, таблиці частин і рот | [`lab03_insert_units_companies.sql`](lab03_insert_units_companies.sql) |
| 4 | SELECT, ORDER BY, WHERE, UPDATE, DELETE | [`lab04_select_update_delete.sql`](lab04_select_update_delete.sql) |
| 5 | З'єднання таблиць (CROSS / LEFT / RIGHT JOIN), особовий склад | [`lab05_joins_personnel.sql`](lab05_joins_personnel.sql) |
| 6 | Облікові записи, користувачі, ролі | [`lab06_logins_users_roles.sql`](lab06_logins_users_roles.sql) |
| 7 | Групування, агрегатні та вбудовані функції | [`lab07_grouping_functions.sql`](lab07_grouping_functions.sql) |
| 8 | Подання, функції, збережені процедури | [`lab08_views_functions_procedures.sql`](lab08_views_functions_procedures.sql) |
| 9 | Тригери, транзакції | [`lab09_triggers_transactions.sql`](lab09_triggers_transactions.sql) |

## Як запустити

Скрипти виконуються **по черзі на чистому сервері** (02 створює базу, кожен наступний спирається на попередній):

```bash
sqlcmd -S localhost -E -i lab02_create_db_tables.sql
sqlcmd -S localhost -E -i lab03_insert_units_companies.sql
# ... і так до lab09
```

Або відкрити файли в Azure Data Studio / SSMS і виконати по порядку.

> Паролі в `lab06` шаблонні: заміни їх перед запуском.

## Технології

MS SQL Server 2022 · T-SQL · SSMS · Azure Data Studio · sqlcmd

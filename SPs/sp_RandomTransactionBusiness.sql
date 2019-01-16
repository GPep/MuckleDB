USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_RandomTransactionBusiness') IS NULL
  EXEC ('CREATE PROCEDURE sp_RandomTransactionBusiness AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_RandomTransactionBusiness] @count int
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create new random online transactions for Business accounts
-- Used to simulate database activity.
-- =============================================

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT
DECLARE @Upper INT;
DECLARE @Lower INT;

DECLARE @Counter INT 

DECLARE @Random_acc_id INT
DECLARE @Random_Amount DECIMAL (20,2)
DECLARE @Random_emp_id int

SET @Counter = 0

WHILE @Counter < @Count
BEGIN

--generate random account number
SET @Lower = (SELECT MIN(account_id) FROM dbo.Account WHERE PRODUCT_ID IN (3)) ---- The lowest random number
SET @Upper = (SELECT MAX(Account_id) FROM dbo.Account WHERE PRODUCT_ID IN (3)) ---- The highest random number
SELECT @Random_acc_id = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

--generate random ammount (currently set to be no greater than £1000 debit or credit
SET @lower = -5000.00
SET @upper = 10000.00
SELECT @Random_amount = ((@Upper - @Lower - 1) * RAND() + @Lower)

-- Generate Random Employee
SET @Lower = (SELECT MIN(emp_id) FROM dbo.Employee WHERE Title IN ('Teller', 'Head Teller')) ---- The lowest random number
SET @Upper = (SELECT MAX(emp_id) FROM dbo.Employee WHERE Title IN ('Teller', 'Head Teller')) ---- The highest random number
SELECT @Random_emp_id = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

--Now generate random transaction



EXECUTE sp_NewTransaction @account_id = @random_acc_id, @amount = @random_amount, @emp_id = @random_emp_id


SET @Counter = @Counter + 1

END

END



-- EXECUTE sp_RandomTransactionBusiness @count = 100
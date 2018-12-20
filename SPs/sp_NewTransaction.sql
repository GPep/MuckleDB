USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_NewTransaction') IS NULL
  EXEC ('CREATE PROCEDURE sp_NewTransaction AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_NewTransaction] @account_id int , @amount DECIMAL(20,2), @emp_id int
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create new transactions 
-- =============================================

SET XACT_ABORT ON

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT
DECLARE @txn_type_cd char(3)
DECLARE @branch_id int
DECLARE @currentbalance decimal(20,2)

BEGIN TRY;
BEGIN TRANSACTION;

IF (@amount < 0)
BEGIN
SET @txn_type_cd = 'DBT' -- Debit
END
ELSE 
BEGIN
SET @txn_type_cd = 'CDT' -- Credit
END

SET @branch_id = (select assigned_branch_id from EMPLOYEE where EMP_ID = @emp_id)

--Check current balance - if less than zero, do not allow debit to complete.

SET @Currentbalance = (SELECT dbo.fn_AccountBalance(@account_id))

IF (@currentbalance + @amount < 0)
BEGIN
PRINT 'Not enough Funds available for this debit'
COMMIT TRANSACTION;
RETURN
END

ELSE
BEGIN
INSERT INTO ACC_TRANSACTION(Amount, TXN_TYPE_CD, ACCOUNT_ID, EXECUTION_BRANCH_ID, TELLER_EMP_ID)
VALUES (@amount, @txn_type_cd, @Account_id, @branch_id, @Emp_id)
END


COMMIT TRANSACTION;

END TRY


BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
raiserror ('SP_NewTransaction Failed: %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH


END


--EXECUTE SP_Newtransaction @account_id = 5000000, @amount = '1322565.00', @emp_id = 12
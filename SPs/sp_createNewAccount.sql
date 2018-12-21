USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_createNewAccount') IS NULL
  EXEC ('CREATE PROCEDURE sp_createNewAccount AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_createNewAccount] @cust_id int, @product_id int, @branch_id int = 1, @Emp_id int = 12
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create new accounts. 
-- all new accounts  must be opened with a balance of £100
-- =============================================


--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT
DECLARE @Account_id int

SET @Account_id = (NEXT VALUE FOR dbo.account_id)


BEGIN TRY;
BEGIN TRANSACTION;

INSERT INTO ACCOUNT(account_id, Last_activity_Date, Status, Cust_id, OPEN_BRANCH_ID, OPEN_EMP_ID, PRODUCT_ID)
VALUES(@Account_id, getdate(), 'ACTIVE', @cust_id, @branch_id, @emp_id, @Product_id)

INSERT INTO ACC_TRANSACTION(Amount, TXN_TYPE_CD, ACCOUNT_ID, EXECUTION_BRANCH_ID, TELLER_EMP_ID)
VALUES ('100.00', 'CDT', @Account_id, @branch_id, @Emp_id)

COMMIT TRANSACTION;

END TRY


BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
raiserror ('SP_CreateNewAccount Failed: %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH


END


--EXECUTE sp_createNewAccount @cust_id = '7000001', @product_id = 1, @branch_id = 1, @Emp_id = 12

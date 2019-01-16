USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_CreateOverdraft') IS NULL
  EXEC ('CREATE PROCEDURE sp_CreateOverdraft AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_CreateOverdraft] @account_id int , @overdraft DECIMAL(20,2), @emp_id int
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create an overdraft for an account 
-- =============================================

SET XACT_ABORT ON

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT
DECLARE @txn_type_cd char(3)
DECLARE @branch_id int
DECLARE @currentbalance decimal(20,2)
DECLARE @status varchar(10)

BEGIN TRY;
BEGIN TRANSACTION;

SET @branch_id = (select assigned_branch_id from EMPLOYEE where EMP_ID = @emp_id)

--Check if Account is active
SET @status = (SELECT status from dbo.ACCOUNT Where ACCOUNT_ID = @account_id)
IF @status <> 'Active'
BEGIN
Print 'Account is ' + @Status
COMMIT TRANSACTION
RETURN
END


ELSE
BEGIN
UPDATE dbo.ACCOUNT
SET Overdraft = @Overdraft,
LAST_ACTIVITY_DATE = GETDATE(),
Last_Amended_By = @emp_id
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

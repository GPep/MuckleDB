USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_CloseAccount') IS NULL
  EXEC ('CREATE PROCEDURE sp_CloseAccount AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_CloseAccount] @account_id int, @emp_id int
AS
BEGIN
SET NOCOUNT ON;

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will close accounts
-- =============================================

SET XACT_ABORT ON

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT
DECLARE @txn_type_cd char(3)
DECLARE @branch_id int
DECLARE @currentbalance decimal(20,2)

BEGIN TRY;
BEGIN TRANSACTION;

UPDATE ACCOUNT
SET Close_date = getdate(), last_activity_date = getdate(), STATUS = 'Close'
WHERE ACCOUNT_ID = @account_id

COMMIT TRANSACTION;

END TRY


BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
raiserror ('SP_CloseAccount Failed: %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH


END
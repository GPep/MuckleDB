IF OBJECT_ID('dbo.fn_LastActiveDate') IS NOT NULL
DROP FUNCTION dbo.fn_LastActiveDate;
GO

CREATE FUNCTION dbo.fn_LastActiveDate(@AccID INT)
RETURNS datetime
AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2016-06-12
-- Version 1.0
-- Description:	This function calculates last active date for all accounts
-- =============================================
DECLARE @date datetime


SELECT @date = Max(TXN_DATE) FROM ACC_TRANSACTION
WHERE ACCOUNT_ID = @AccID
RETURN @date
END
GO
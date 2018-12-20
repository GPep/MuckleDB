IF OBJECT_ID('dbo.fn_PendingBalance') IS NOT NULL
DROP FUNCTION dbo.fn_PendingBalance;
GO

CREATE FUNCTION dbo.fn_PendingBalance(@AccID INT)
RETURNS DECIMAL(20,2)
AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2016-06-12
-- Version 1.0
-- Description:	This function calculates Pending Account Balance
-- =============================================
DECLARE @balance DECIMAL(20,2)


SELECT @balance = SUM(AMOUNT) FROM ACC_TRANSACTION
WHERE ACCOUNT_ID = @AccID
AND FUNDS_AVAIL_DATE > getdate()
RETURN @balance
END
GO

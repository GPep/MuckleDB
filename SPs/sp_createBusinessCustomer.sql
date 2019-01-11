USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_createBusinessCustomer') IS NULL
  EXEC ('CREATE PROCEDURE sp_createBusinessCustomer AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_createBusinessCustomer] @count int = 1
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create new Business customer details
-- =============================================



EXECUTE mockdata.dbo.usp_createBusinessCustomer @Count = @count
EXECUTE mockdata.dbo.USP_GenerateAddress @count = @count

--Create temp table to hold staging data from MockData
IF OBJECT_ID('tempdb.dbo.#BusinessCustomer','u') IS NOT NULL
BEGIN
DROP TABLE #BusinessCustomer 
END

CREATE TABLE #BusinessCustomer(
Cust_id int,
ID INT,
Name varchar(50),
Address1 Varchar(100),
Town VARCHAR(50),
County VARCHAR(50),
Country VARCHAR(50),
Post_Code Varchar(7),
PhoneNumber char(10)
)

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT



BEGIN TRY;
BEGIN TRANSACTION;


INSERT INTO #BusinessCustomer (cust_id, ID, name, Address1, Town, County, country, Post_Code, PhoneNumber)
SELECT (NEXT VALUE FOR dbo.cust_id), Business.ID, business.name, addr.Address1, addr.Town, addr.County, addr.country, addr.Post_Code, pn.PhoneNumber
FROM MockData.data.Business AS Business
INNER JOIN MockData.data.Address AS addr
ON Business.id = addr.ID
INNER JOIN MockData.data.PhoneNumber as pn
ON business.id = pn.id

---------------------
INSERT INTO customer (Cust_id, cust_type_cd, address, Town, COUNTY, post_code, Country)
SELECT cust_id, 'B', Address1, Town, County, Post_code, Country
FROM #BusinessCustomer

--------------------
INSERT INTO Business(Business_ID, Name, phoneNumber, Cust_ID)
SELECT (NEXT VALUE FOR dbo.Business_id),Name, phoneNumber, cust_id
FROM #BusinessCustomer	

COMMIT TRANSACTION;

END TRY


BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
raiserror ('SP_CreateBusinessCustomer Failed: %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH

DROP TABLE #BusinessCustomer

END

--EXECUTE sp_createBusinessCustomer @count = 10
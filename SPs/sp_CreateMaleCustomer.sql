USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_createMaleCustomer') IS NULL
  EXEC ('CREATE PROCEDURE sp_createMaleCustomer AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_createMaleCustomer] @count int = 1
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create new customer details
-- =============================================




EXECUTE mockdata.dbo.USP_CreateMaleIndividual @Count = @count
EXECUTE mockdata.dbo.usp_randomBirthDate @count = @count
EXECUTE mockdata.dbo.usp_GeneratePhoneNumber @count = @count
EXECUTE mockdata.dbo.USP_GenerateAddress @count = @count

--Create temp table to hold staging data from MockData
IF OBJECT_ID('tempdb.dbo.#MaleCustomer','u') IS NOT NULL
BEGIN
DROP TABLE #MaleCustomer 
END

CREATE TABLE #MaleCustomer(
Cust_id int,
ID INT,
First_Name varchar(50),
Last_name Varchar(50),
Title Varchar(50),
Email_address varchar(50),
Address1 Varchar(100),
Town VARCHAR(50),
County VARCHAR(50),
Country VARCHAR(50),
Post_Code Varchar(7),
Birth_Date date,
PhoneNumber char(10)
)

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT



BEGIN TRY;
BEGIN TRANSACTION;


INSERT INTO #MaleCustomer (cust_id, ID, First_Name, Last_name, Title, Email_address, Address1, Town, County, country, Post_Code, Birth_date, PhoneNumber)
SELECT (NEXT VALUE FOR dbo.cust_id), male.ID, male.First_Name, male.Last_name, male.Title, male.Emailaddress, addr.Address1, addr.Town, addr.County, addr.country,addr.Post_Code, bd.Birth_Date, pn.PhoneNumber
FROM MockData.data.MaleIndividual AS male
INNER JOIN MockData.data.Address AS addr
ON male.id = addr.ID
INNER JOIN MockData.data.Birth_Date as bd
ON  male.id = bd.id
INNER JOIN MockData.data.PhoneNumber as pn
ON male.id = pn.id

---------------------
INSERT INTO customer (Cust_id, cust_type_cd, address, Town, COUNTY, post_code, Country)
SELECT cust_id, 'I', Address1, Town, County, Post_code, Country
FROM #MaleCustomer

--------------------
INSERT INTO individual (Title, First_Name, Last_Name, birth_date, EmailAddress, phoneNumber, Cust_ID)
SELECT Title, First_name, Last_name, Birth_date, Email_address, phoneNumber, cust_id
FROM #MaleCustomer	

COMMIT TRANSACTION;

END TRY


BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
raiserror ('SP_CreateMaleCustomer Failed: %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH

DROP TABLE #MaleCustomer

END

--EXECUTE sp_createMaleCustomer @count = 1000
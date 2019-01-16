USE [MuckleDB]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_createFemaleCustomer') IS NULL
  EXEC ('CREATE PROCEDURE sp_createFemaleCustomer AS RETURN 0;')
GO

ALTER PROCEDURE [dbo].[sp_createFemaleCustomer] @count int = 1
AS
BEGIN
SET NOCOUNT ON;
-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-11-16
-- Version: 1.0
-- Description:	This Stored Procedure will create new female customer details
-- =============================================

EXECUTE mockdata.dbo.USP_CreateFemaleIndividual @Count = @count
EXECUTE mockdata.dbo.usp_randomBirthDate @count = @count
EXECUTE mockdata.dbo.usp_GeneratePhoneNumber @count = @count
EXECUTE mockdata.dbo.USP_GenerateAddress @count = @count

--Create temp table to hold staging data from MockData
IF OBJECT_ID('tempdb.dbo.#FemaleCustomer','u') IS NOT NULL
BEGIN
DROP TABLE #FemaleCustomer 
END

CREATE TABLE #FemaleCustomer(
Cust_id int,
ID INT,
First_Name varchar(50),
Last_name Varchar(50),
Title Varchar(50),
Email_address varchar(50),
Address1 Varchar(100),
Town VARCHAR(50),
County VARCHAR(50),
Country VARCHAR(25),
Post_Code Varchar(7),
Birth_Date date,
PhoneNumber char(10),
Created_By int
)

--declare variables for any error reporting
DECLARE @ErrorNumber AS INT, @ErrorMessage AS NVarchar(1000), @error_severity AS INT



BEGIN TRY;
BEGIN TRANSACTION;

INSERT INTO #FemaleCustomer (cust_Id, ID, First_Name, Last_name, Title, Email_address, Address1, Town, County, country, Post_Code, Birth_date, PhoneNumber, created_By)
SELECT (NEXT VALUE FOR dbo.cust_id), female.ID, female.First_Name, female.Last_name, female.Title, female.Emailaddress, addr.Address1, addr.Town, addr.County, addr.country,addr.Post_Code, bd.Birth_Date, pn.PhoneNumber, 100
FROM MockData.data.FemaleIndividual AS female
INNER JOIN MockData.data.Address AS addr
ON female.id = addr.ID
INNER JOIN MockData.data.Birth_Date as bd
ON  female.id = bd.id
INNER JOIN MockData.data.PhoneNumber as pn
ON female.id = pn.id
  

---------------------
INSERT INTO customer (cust_id, cust_type_cd, address, Town, COUNTY, post_code, Country, Created_By)
SELECT cust_id, 'I', Address1, Town, County, Post_code, Country, Created_By
FROM #femaleCustomer

--------------------
INSERT INTO individual (Title, First_Name, Last_Name, birth_date, EmailAddress, phoneNumber, Cust_ID, Created_By)
SELECT Title, First_name, Last_name, Birth_date, Email_address, phoneNumber, cust_id, Created_By
FROM #femaleCustomer	

COMMIT TRANSACTION;

END TRY


BEGIN CATCH
IF @@Trancount > 0 
ROLLBACK TRANSACTION;
SELECT @errornumber = ERROR_NUMBER(), @errormessage = ERROR_MESSAGE(),
@error_severity = ERROR_SEVERITY();
raiserror ('SP_CreateFemaleCustomer Failed: %d: %s', 16, 1, @errornumber, @errormessage);
END CATCH

Drop Table #femaleCustomer

END

--EXECUTE sp_createfemaleCustomer @count = 1000
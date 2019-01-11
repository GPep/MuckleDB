USE MuckleDB
GO


EXECUTE dbo.sp_createfemaleCustomer @count = 1000


EXECUTE dbo.sp_createMaleCustomer @count = 1000


EXECUTE dbo.sp_createBusinessCustomer @Count = 500


--Create New Current Account and opening balance of £100 for all accounts

DECLARE @name INT

DECLARE Account_cursor CURSOR FOR
 SELECT Cust_ID from dbo.Customer
 WHERE CUST_TYPE_CD = 'I'

 OPEN Account_cursor
 FETCH NEXT FROM Account_cursor INTO @name
 
 WHILE @@FETCH_STATUS = 0
 BEGIN
 EXECUTE sp_createNewAccount @cust_id = @name, @product_id = 1, @branch_id = 5, @Emp_id = 200

FETCH NEXT FROM Account_cursor INTO @name

END

CLOSE Account_cursor

DEALLOCATE Account_cursor

--Create New Business Accounts and opening balance of £1000 for all accounts

DECLARE @business INT

DECLARE BAccount_cursor CURSOR FOR
SELECT Cust_ID from dbo.Customer
WHERE CUST_TYPE_CD = 'B'

OPEN BAccount_cursor
FETCH NEXT FROM BAccount_cursor INTO @Business
 
WHILE @@FETCH_STATUS = 0
BEGIN
EXECUTE sp_createNewAccount @cust_id = @Business, @product_id = 3, @branch_id = 5, @amount = '1000', @Emp_id = 200

FETCH NEXT FROM BAccount_cursor INTO @Business

END

CLOSE BAccount_cursor

DEALLOCATE BAccount_cursor


--Create New Savings account for 500 customer with a opening balance of £500 for all accounts
DECLARE @Counter INT 
DECLARE @Random INT
DECLARE @Random_Cust_id INT;
DECLARE @Upper INT;
DECLARE @Lower INT;
DECLARE @count INT = 500
SET @Counter = 0


IF Object_ID('tempdb.dbo.#RandomCustomers','u') IS NOT NULL
BEGIN
DROP TABLE #RandomCustomer
END

CREATE TABLE #RandomCustomer
(Cust_ID int NOT NULL
)

INSERT INTO #RandomCustomer (Cust_ID)
SELECT Cust_id FROM CUSTOMER
WHERE CUST_TYPE_CD = 'I'

WHILE @Counter < @Count
BEGIN

SET @Lower = (SELECT MIN(Cust_id) FROM #RandomCustomer) ---- The lowest random number
SET @Upper = (SELECT MAX(Cust_id) FROM #RandomCustomer) ---- The highest random number
SELECT @Random_cust_id = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

EXECUTE sp_createNewAccount @cust_id = @Random_cust_id, @product_id = 2, @branch_id = 1, @Emp_id = 200, @amount = '500.00'

SET @Counter = @Counter + 1

END


DROP TABLE #RandomCustomer
USE MuckleDB
GO


EXECUTE dbo.sp_createfemaleCustomer @count = 1000


EXECUTE dbo.sp_createMaleCustomer @count = 1000


--Create New Current Account and opening balance of £100 for all accounts

DECLARE @name INT

DECLARE Account_cursor CURSOR FOR
 SELECT Cust_ID from dbo.Customer 

 OPEN Account_cursor
 FETCH NEXT FROM Account_cursor INTO @name
 
 WHILE @@FETCH_STATUS = 0
 BEGIN
 EXECUTE sp_createNewAccount @cust_id = @name, @product_id = 1, @branch_id = 1, @Emp_id = 19

FETCH NEXT FROM Account_cursor INTO @name

END

CLOSE Account_cursor

DEALLOCATE Account_cursor

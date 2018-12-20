
-- Create Random account customer id

DECLARE @Random_account INT;
DECLARE @Upper INT;
DECLARE @Lower INT
 
---- This will create a random number between 1 and 999
SET @Lower = (SELECT MIN(account_id) FROM account) ---- The lowest random number
SET @Upper = (SELECT MAX(account_id) FROM account) ---- The highest random number
SELECT @Random_account = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)



DECLARE @Random_customer INT;
DECLARE @Upper_cust INT;
DECLARE @Lower_cust INT
 
---- This will create a random number between 1 and 999
SET @Lower_cust = (SELECT MIN(cust_id) FROM customer) ---- The lowest random number
SET @Upper_cust = (SELECT MAX(cust_id) FROM Customer) ---- The highest random number
SELECT @Random_customer = ROUND(((@Upper_cust - @Lower_cust -1) * RAND() + @Lower_cust), 0)


--Customer Details

SELECT acc.account_id, cust.cust_id, COALESCE(prod.name, 'No Accounts Held') AS Product_Name, indiv.First_name, indiv.last_name, indiv.Birth_date, 
COALESCE(acc.Avail_balance, 0) AS Available_Balance, COALESCE(acc.pending_balance, 0) AS Pending_Balance, COALESCE(acc.Status, 'No Accounts Held') AS 'Status'
FROM  Customer as cust
LEFT JOIN Account as acc
ON cust.cust_id = acc.CUST_ID
LEFT JOIN Product as prod
ON acc.PRODUCT_CD = prod.PRODUCT_CD
LEFT JOIN INDIVIDUAL as indiv
ON indiv.CUST_ID = acc.CUST_ID
WHERE cust.Cust_id = @Random_customer


--Check Single Account
SELECT acc.account_id, cust.cust_id, prod.name, indiv.First_name, indiv.last_name, indiv.Birth_date, 
acc.Avail_balance, acc.pending_balance, acc.Status
FROM  Customer as cust
INNER JOIN Account as acc
ON cust.cust_id = acc.CUST_ID
INNER JOIN Product as prod
ON acc.PRODUCT_CD = prod.PRODUCT_CD
INNER JOIN INDIVIDUAL as indiv
ON indiv.CUST_ID = acc.CUST_ID
WHERE acc.account_id = @Random_account


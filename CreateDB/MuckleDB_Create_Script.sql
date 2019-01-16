USE MASTER
GO



IF EXISTS (SELECT name FROM sys.databases
WHERE NAME = 'MuckleDB'
)
BEGIN
ALTER DATABASE MUCKLEDB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE MuckleDB
END


CREATE DATABASE [MuckleDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MuckleDB', FILENAME = N'E:\MSSQL\DATA\MuckleDB.mdf' , SIZE = 5120KB , FILEGROWTH = 202400KB )
 LOG ON 
( NAME = N'MuckleDB_log', FILENAME = N'L:\MSSQL\LOGS\MuckleDB_log.ldf' , SIZE = 1024KB , FILEGROWTH = 151200KB )
GO
ALTER DATABASE [MuckleDB] SET RECOVERY FULL 
GO
ALTER DATABASE [MuckleDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

USE MuckleDB

CREATE SEQUENCE [dbo].[Cust_ID] 
 AS [int]
 START WITH 7000000
 INCREMENT BY 1

GO

CREATE SEQUENCE [dbo].[Account_ID] 
 AS [int]
 START WITH 5000000
 INCREMENT BY 1

GO

CREATE SEQUENCE [dbo].[Business_ID] 
 AS [int]
 START WITH 8000000
 INCREMENT BY 1


IF OBJECT_ID('dbo.fn_AccountBalance') IS NOT NULL
DROP FUNCTION dbo.fn_AccountBalance;
GO

CREATE FUNCTION dbo.fn_AccountBalance(@AccID INT)
RETURNS DECIMAL(20,2)
AS
BEGIN

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2016-06-12
-- Version 1.0
-- Description:	This function calculates Account Balance
-- =============================================
DECLARE @balance DECIMAL(20,2)


SELECT @balance = SUM(AMOUNT) FROM ACC_TRANSACTION
WHERE ACCOUNT_ID = @AccID
AND FUNDS_AVAIL_DATE <= getdate()
RETURN @balance
END
GO

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



--Create Tables
IF OBJECT_ID('Account','u') IS  NOT NULL
BEGIN
DROP TABLE ACCOUNT

END

    CREATE TABLE ACCOUNT (
        ACCOUNT_ID INT not null PRIMARY KEY,
        AVAIL_BALANCE AS (dbo.fn_accountBalance(Account_id)),
		OVERDRAFT DECIMAL(20,2) NOT NULL
		CONSTRAINT df_odamount DEFAULT 0
		CONSTRAINT ck_odamount CHECK (overdraft <= 0),
        CLOSE_DATE datetime,
        LAST_ACTIVITY_DATE datetime,
        OPEN_DATE datetime not null
		CONSTRAINT df_open_date DEFAULT (sysdatetime()),
        PENDING_BALANCE AS (dbo.fn_PendingBalance(Account_id)),
        STATUS varchar(10),
        CUST_ID int NOT NULL,
        OPEN_BRANCH_ID int not null,
        OPEN_EMP_ID int not null,
        PRODUCT_id INT not null,
		Last_Amended_By int
    );


IF OBJECT_ID('BRANCH','u') IS NOT NULL
BEGIN
DROP TABLE BRANCH
END

    CREATE TABLE BRANCH (
        BRANCH_ID int identity (1,1) not null PRIMARY KEY,
        ADDRESS varchar(30),
        CITY varchar(20),
        NAME varchar(20) not null,
        COUNTY varchar(20),
        POST_CODE varchar(10),
		CREATE_DATE datetime
		CONSTRAINT df_branchCreateDate DEFAULT (getdate())
    );

IF OBJECT_ID('TRANSACTION_TYPE','u') IS NOT NULL
BEGIN
DROP TABLE TRANSACTION_TYPE
END

CREATE TABLE TRANSACTION_TYPE
(ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
TXN_TYPE CHAR(3) NOT NULL UNIQUE,
DESCRIPTION VARCHAR(20) NOT NULL)

IF OBJECT_ID('ACC_TRANSACTION','u') IS NOT NULL
BEGIN
DROP TABLE ACC_TRANSACTION
END

    CREATE TABLE ACC_TRANSACTION (
        TXN_ID INT identity(1,1) not null PRIMARY KEY,
        AMOUNT DECIMAL(20,2) not null,
        FUNDS_AVAIL_DATE datetime not null
		CONSTRAINT df_fundsDate DEFAULT (getdate()),
        TXN_DATE datetime not null
		CONSTRAINT df_txnDate DEFAULT (getdate()),
        TXN_TYPE_CD CHAR(3) FOREIGN KEY REFERENCES TRANSACTION_TYPE(TXN_TYPE),
        ACCOUNT_ID int,
        EXECUTION_BRANCH_ID int,
        TELLER_EMP_ID int
    );

 

IF OBJECT_ID('CUSTOMER','u') IS NOT NULL
BEGIN
DROP TABLE CUSTOMER
END

    CREATE TABLE CUSTOMER (
        CUST_ID int not null PRIMARY KEY,
		CUST_TYPE_CD varchar(1) not null,
        ADDRESS varchar(100),
        Town varchar(50),
        COUNTY varchar(50),
		POST_CODE varchar(7),
		Country Varchar(25),
		CREATE_DATE datetime NOT NULL
		CONSTRAINT df_customerCreateDate DEFAULT (getdate()),
		Created_By int NOT NULL,
		Last_amended_date datetime,
		Last_amended_by int
    );

IF OBJECT_ID('BUSINESS','u') IS NOT NULL
BEGIN
DROP TABLE BUSINESS
END

    CREATE TABLE BUSINESS (
        BUSINESS_ID INT NOT NULL PRIMARY KEY,
        NAME varchar(255) not null,
        CUST_ID int not null,
		CREATE_DATE datetime NOT NULL
		CONSTRAINT df_businessCreateDate DEFAULT (getdate()),
		Created_By int NOT NULL,
		Last_amended_date datetime,
		Last_amended_by int,
		PhoneNumber Char(10) NULL
    );


IF OBJECT_ID('DEPARTMENT','u') IS NOT NULL
BEGIN
DROP TABLE DEPARTMENT
END
   
    CREATE TABLE DEPARTMENT (
        DEPT_ID int identity(1,1) not null PRIMARY KEY,
        NAME varchar(20) not null,
    );

IF OBJECT_ID('EMPLOYEE','u') IS NOT NULL
BEGIN
DROP TABLE EMPLOYEE
END

    CREATE TABLE EMPLOYEE (
        EMP_ID int identity(1,1) not null PRIMARY KEY,
        END_DATE datetime,
        FIRST_NAME varchar(20) not null,
        LAST_NAME varchar(20) not null,
        START_DATE datetime not null,
        TITLE varchar(20),
        ASSIGNED_BRANCH_ID int,
        DEPT_ID int,
        SUPERIOR_EMP_ID int,
		CREATE_DATE datetime NOT NULL
		CONSTRAINT df_EMPCreateDate DEFAULT (getdate())
    );

IF OBJECT_ID('INDIVIDUAL','u') IS NOT NULL
BEGIN
DROP TABLE INDIVIDUAL
END

    CREATE TABLE INDIVIDUAL (
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Title Char(4),
		FIRST_NAME varchar(30) not null,
        LAST_NAME varchar(30) not null,
        BIRTH_DATE date
		CONSTRAINT ck_birth_date CHECK (Birth_date < sysdatetime()),
		EmailAddress varchar(50),
	    PhoneNumber Char(10),
        CUST_ID int not null,
		Create_Date datetime NOT NULL
		CONSTRAINT DF_IndivCreateDate DEFAULT (getdate()),
		Created_By int NOT NULL,
		Last_amended_date datetime,
		Last_amended_by int
    );

IF OBJECT_ID('PRODUCT_TYPE','u') IS NOT NULL
BEGIN
DROP TABLE PRODUCT_TYPE
END

    CREATE TABLE PRODUCT_TYPE (
        PRODUCT_TYPE_CD varchar(10) not null PRIMARY KEY,
        NAME varchar(50) NOT NULL
    );

IF OBJECT_ID('PRODUCT','u') IS NOT NULL
BEGIN
DROP TABLE PRODUCT

END

    CREATE TABLE PRODUCT (
		ID INT IDENTITY NOT NULL PRIMARY KEY,
        PRODUCT_CD varchar(10) not null  UNIQUE,
        DATE_OFFERED datetime
		CONSTRAINT df_prod_dateOffered DEFAULT (getdate()),
        DATE_RETIRED datetime,
        NAME varchar(50) not null,
        PRODUCT_TYPE_CD VARCHAR(10) NOT NULL
    );




--FOREIGN KEY


    ALTER TABLE ACCOUNT 
        ADD CONSTRAINT FK_ACCOUNT_CUSTOMER
        FOREIGN KEY (CUST_ID) 
        REFERENCES CUSTOMER;

    ALTER TABLE ACCOUNT 
        ADD CONSTRAINT FK_ACCOUNT_BRANCH 
        FOREIGN KEY (OPEN_BRANCH_ID) 
        REFERENCES BRANCH;

    ALTER TABLE ACCOUNT 
        ADD CONSTRAINT FK_ACCOUNT_EMPLOYEE
        FOREIGN KEY (OPEN_EMP_ID) 
        REFERENCES EMPLOYEE;

    ALTER TABLE ACCOUNT
		ADD CONSTRAINT FK_ACCOUNT_EMPLOYEE_AMENDED_BY
		FOREIGN KEY (Last_amended_by)
		REFERENCES EMPLOYEE;

    ALTER TABLE ACCOUNT 
        ADD CONSTRAINT FK_ACCOUNT_PRODUCT
        FOREIGN KEY (PRODUCT_ID) 
        REFERENCES PRODUCT;
 
   ALTER TABLE ACC_TRANSACTION 
        ADD CONSTRAINT FK_ACC_TRANSACTION_ACCOUNT
        FOREIGN KEY (ACCOUNT_ID) 
        REFERENCES ACCOUNT;

    ALTER TABLE ACC_TRANSACTION 
        ADD CONSTRAINT FK_ACC_TRANSACTION_BRANCH 
        FOREIGN KEY (EXECUTION_BRANCH_ID) 
        REFERENCES BRANCH;

    ALTER TABLE ACC_TRANSACTION 
        ADD CONSTRAINT FK_ACC_TRANSACTION_EMPLOYEE
        FOREIGN KEY (TELLER_EMP_ID) 
        REFERENCES EMPLOYEE;

    ALTER TABLE BUSINESS 
        ADD CONSTRAINT FK_BUSINESS_EMPLOYEE
        FOREIGN KEY (CUST_ID) 
        REFERENCES CUSTOMER;

	ALTER TABLE BUSINESS
		ADD CONSTRAINT FK_BUSINESS_EMPLOYEE_CREATED_BY
		FOREIGN KEY (CREATED_by)
		REFERENCES EMPLOYEE;

	ALTER TABLE CUSTOMER
		ADD CONSTRAINT FK_CUSTOMER_EMPLOYEE_AMENDED_BY
		FOREIGN KEY (Last_amended_by)
		REFERENCES EMPLOYEE;

	ALTER TABLE INDIVIDUAL
		ADD CONSTRAINT FK_INDIVIDUAL_EMPLOYEE_AMENDED_BY
		FOREIGN KEY (Last_amended_by)
		REFERENCES EMPLOYEE;

	ALTER TABLE INDIVIDUAL
		ADD CONSTRAINT FK_INDIVIDUAL_EMPLOYEE_CREATED_BY
		FOREIGN KEY (Created_by)
		REFERENCES EMPLOYEE;

    ALTER TABLE EMPLOYEE 
        ADD CONSTRAINT FK_EMPLOYEE_BRANCH
        FOREIGN KEY (ASSIGNED_BRANCH_ID) 
        REFERENCES BRANCH;

    ALTER TABLE EMPLOYEE 
        ADD CONSTRAINT FK_EMPLOYEE_DEPARTMENT
        FOREIGN KEY (DEPT_ID) 
        REFERENCES DEPARTMENT;

    ALTER TABLE EMPLOYEE 
        ADD CONSTRAINT FK_EMPLOYEE_EMPLOYEE
        FOREIGN KEY (SUPERIOR_EMP_ID) 
        REFERENCES EMPLOYEE;

    ALTER TABLE PRODUCT 
        ADD CONSTRAINT FK_PRODUCT_PRODUCT_TYPE
        FOREIGN KEY (PRODUCT_TYPE_CD) 
        REFERENCES PRODUCT_TYPE;


-- ======================================================================== 
-- ========================================================================
-- ========================================================================
 

/* begin data population */

SET IDENTITY_INSERT department  ON;
---------------------
INSERT INTO department (dept_id, name)
VALUES (1, 'Operations');
---------------------
INSERT INTO department (dept_id, name)
VALUES (2, 'Loans');
---------------------
INSERT INTO department (dept_id, name)
VALUES (3, 'Administration');

INSERT INTO department (dept_id, name)
VALUES (4, 'IT');

INSERT INTO DEPARTMENT (DEPT_ID,name)
VALUES(5,'HR')


-- Enable
SET IDENTITY_INSERT department  OFF;

-- branch data 

SET IDENTITY_INSERT branch  ON;

---------------------
INSERT INTO branch (branch_id, name, address, city, COUNTY, post_Code)
VALUES (1, 'Headquarters', '3882 High St.', 'Waltham', 'Essex', 'WT1 8HW');
---------------------
INSERT INTO branch (branch_id, name, address, city, County, Post_Code)
VALUES (2, 'Croydon Branch', '422 Maple St.', 'Croydon', 'Surrey', 'CR15 TNN');
---------------------
INSERT INTO branch (branch_id, name, address, city, COUNTY, Post_Code)
VALUES (3, 'Hastings Branch', '125 Presidential Way', 'Hastings', 'Sussex', 'TN37 JJR');
---------------------
INSERT INTO branch (branch_id, name, address, city, COUNTY, Post_Code)
VALUES (4, 'Manchester Branch', '378 Maynard Ln.', 'Manchester', 'Lancashire', 'MN1 4AH');

INSERT INTO branch (branch_id, name, address, city, COUNTY, Post_Code)
VALUES (5, 'Online', 'MuckleDB.COM', 'Waltham', 'Essex', 'WT1 8HW');

SET IDENTITY_INSERT branch  OFF;


-- employee data  

SET IDENTITY_INSERT employee  ON;
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (1, 'Michael', 'Smith', Convert(Datetime,'2001-06-22',120), 
  (SELECT dept_id FROM department WHERE name = 'Administration'), 
  'President', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (2, 'Susan', 'Barker',Convert(Datetime, '2002-09-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Administration'), 
  'Vice President', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (3, 'Bill', 'Oddie',Convert(Datetime, '2000-02-09',120),
  (SELECT dept_id FROM department WHERE name = 'Administration'), 
  'Treasurer', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (4, 'Bill', 'Oddie',Convert(Datetime, '2014-10-22',120),
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Head of Operations', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------

INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (5, 'Fiona', 'Hawthorne',Convert(Datetime, '2002-04-24',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Branch Manager', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (6, 'Barry', 'Goodhall',Convert(Datetime, '2003-11-14',120), 
  (SELECT dept_id FROM department WHERE name = 'Loans'), 
  'Loan Manager', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (7, 'Beryl', 'Braintree',Convert(Datetime, '2008-11-14',120), 
  (SELECT dept_id FROM department WHERE name = 'IT'), 
  'Head of IT', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------

INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (8, 'Sarah', 'Fortinbras',Convert(Datetime, '2004-03-17',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Head Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (9, 'John', 'Fowler',Convert(Datetime, '2004-09-15',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (10, 'Jane', 'Murray',Convert(Datetime, '2002-12-02',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (11, 'Lloyd', 'Grossman',Convert(Datetime, '2002-05-03',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (12, 'Daniel', 'Danielson',Convert(Datetime, '2002-07-27',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Head Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Croydon Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (13, 'Brent', 'Zimmler',Convert(Datetime, '2000-10-23',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Croydon Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (14, 'Sabu', 'Sondenheit',Convert(Datetime, '2003-01-08',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Croydon Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (15, 'Chris', 'Towers',Convert(Datetime, '2000-05-11',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Head Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Hastings Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (16, 'Jim', 'Waters',Convert(Datetime, '2002-08-09',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Hastings Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (17, 'Natalie', 'Bucket',Convert(Datetime, '2003-04-01',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Hastings Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (18, 'Anna', 'Montague-Jones',Convert(Datetime, '2017-03-15',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Branch Manager', 
  (SELECT branch_id FROM branch WHERE name = 'Manchester Branch'));
---------------------
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (19, 'Jeremy', 'Mayday',Convert(Datetime, '2001-03-15',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Head Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Manchester Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (20, 'Biff', 'Nichols',Convert(Datetime, '2002-06-29',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Manchester Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (21, 'Caroline', 'Escobar',Convert(Datetime, '2002-12-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Manchester Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (22, 'Sara', 'Banders',Convert(Datetime, '2002-04-24',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Branch Manager', 
  (SELECT branch_id FROM branch WHERE name = 'Croydon Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (23, 'Jimmy', 'Nail',Convert(Datetime, '2002-12-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Branch Manager', 
  (SELECT branch_id FROM branch WHERE name = 'Hastings Branch'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (24, 'Marie', 'Burns',Convert(Datetime, '2002-12-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Operations Manager', 
  (SELECT branch_id FROM branch WHERE name = 'Online'));
---------------------
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (25, 'Jackie', 'Pantaloons',Convert(Datetime, '2002-12-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Teller', 
  (SELECT branch_id FROM branch WHERE name = 'Online'));


--Create Automatic Emp_id for automatic popluation
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (100, 'Automatic', 'Creation',Convert(Datetime, '2002-12-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Auto', 
  (SELECT branch_id FROM branch WHERE name = 'Headquarters'));
--Create Automatic Emp_id for automatic popluation
INSERT INTO employee (emp_id, First_Name, Last_Name, start_date, 
  dept_id, title, assigned_branch_id)
VALUES (200, 'Online', 'Online',Convert(Datetime, '2002-12-12',120), 
  (SELECT dept_id FROM department WHERE name = 'Operations'), 
  'Auto', 
  (SELECT branch_id FROM branch WHERE name = 'Online'));


  
SET IDENTITY_INSERT employee  OFF;  
  

-- create data for self-referencing FOREIGN KEY 'superior_emp_id' 

IF OBJECT_ID('tempdb.dbo.#emp_tmp','u') IS NOT NULL
BEGIN
DROP TABLE #emp_tmp
END
 
SELECT emp_id, Title, DEPT_ID
INTO  #emp_tmp
FROM EMPLOYEE


---------------------
UPDATE employee SET superior_emp_id =
 (SELECT emp_id FROM #emp_tmp WHERE Title = 'President')
WHERE ((Title = 'Vice President')
  or (Title = 'Treasurer')
  or (Title = 'Online')
  or (Title = 'Automatic')
  or (Title = 'Head of IT')
  or (Title = 'Head of Operations'));
---------------------
UPDATE employee SET superior_emp_id =
 (SELECT emp_id FROM #emp_tmp WHERE Title = 'Head of Operations')
WHERE Title = 'Branch Manager';
---------------------
UPDATE employee
SET superior_emp_id = emp.emp_id
FROM #emp_tmp emp
WHERE emp.TITLE = 'Branch Manager'
and  employee.Title = 'Head Teller'
and employee.dept_id = emp.DEPT_ID ; 
---------------------
---------------------
UPDATE employee
SET superior_emp_id = emp.emp_id
FROM #emp_tmp emp
WHERE emp.TITLE = 'Head Teller'
and  employee.Title = 'Teller'
and employee.dept_id = emp.DEPT_ID ; 
---------------------
UPDATE employee 
SET superior_emp_id = emp.emp_id
FROM #emp_tmp emp
WHERE emp.TITLE = 'Head of IT'
and  employee.Title = 'Online'; 

drop table #emp_tmp;

--transaction_type

INSERT INTO TRANSACTION_TYPE (TXN_TYPE, DESCRIPTION)
VALUES ('CDT','CREDIT');
INSERT INTO TRANSACTION_TYPE (TXN_TYPE, DESCRIPTION)
VALUES ('DBT','DEBIT');
INSERT INTO TRANSACTION_TYPE (TXN_TYPE, DESCRIPTION)
VALUES ('LOA','LOAN CREDIT');
INSERT INTO TRANSACTION_TYPE (TXN_TYPE, DESCRIPTION)
VALUES ('LPT','Loan Repayment');
INSERT INTO TRANSACTION_TYPE (TXN_TYPE, DESCRIPTION)
VALUES ('INT','Interest');
INSERT INTO TRANSACTION_TYPE (TXN_TYPE, DESCRIPTION)
VALUES ('OVD','Overdraft Interest');

-- product type data 
---------------------
INSERT INTO product_type (product_type_cd, name)
VALUES ('ACCOUNT','Customer Accounts');
---------------------
INSERT INTO product_type (product_type_cd, name)
VALUES ('LOAN','Individual and Business Loans');
---------------------
INSERT INTO product_type (product_type_cd, name)
VALUES ('INSURANCE','Insurance Offerings');

-- product data  
---------------------
INSERT INTO product (product_cd, name, product_type_cd, date_offered)
VALUES ('CUR','Current Account','ACCOUNT',Convert(Datetime,'2000-01-01',120));
---------------------
INSERT INTO product (product_cd, name, product_type_cd, date_offered)
VALUES ('SAV','Savings Account','ACCOUNT',Convert(Datetime,'2000-01-01',120));
---------------------
INSERT INTO product (product_cd, name, product_type_cd, date_offered)
VALUES ('BUS','Business Account','ACCOUNT',Convert(Datetime,'2000-01-01',120));
---------------------
INSERT INTO product (product_cd, name, product_type_cd, date_offered)
VALUES ('AUT','Loan','LOAN',Convert(Datetime,'2000-01-01',120));
---------------------
INSERT INTO product (product_cd, name, product_type_cd, date_offered)
VALUES ('SBL','Small Business Loan','LOAN',Convert(Datetime,'2000-01-01',120));

 

USE NQS;
GO

SELECT @@VERSION

/*

**************************************************
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**************************************************
**** SQL Server and R Solution
**** 
****  Test of Data types for R and SQL Server 2016
**** 
**** Author: Tomaz Kastrun
**** Contact: tomaz.kastrun@gmail.com
**** Date Craeted: June 11, 2016
**** Last Update: June 11, 2016
**** The solution is free
**************************************************
*****~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**************************************************

Restrictions on data types (MSDN);  (link, June 11, 2016)
https://msdn.microsoft.com/en-us/library/mt604368.aspx

*/


--- 1. Let's see the behaviour of n-varchar data type
	
DECLARE @RScript NVARCHAR(MAX)
SET @RScript = N'OutputDataSet <- InputDataSet;'


DECLARE @SQLScript NVARCHAR(MAX)
SET @SQLScript = N'
 SELECT top 10
		 sod.[OrderQty] AS OrderQty
		,so.[DiscountPct] AS Discount
		,CAST(pc.name aS NVARCHAR(4000)) AS name
		,pc.name as name2
		,''ČŽŠ'' AS More_spec_chars
		,CAST(''ČŽŠ'' AS VARCHAR(400)) AS More_spec_chars2
		,CONVERT(VARCHAR(10), ''ČŽŠ'') AS More_spec_chars3


	FROM  Adventureworks.[Sales].[SalesOrderDetail] sod
	INNER JOIN Adventureworks.[Sales].[SpecialOffer] so
	ON so.[SpecialOfferID] = sod.[SpecialOfferID]
	INNER JOIN Adventureworks.[Production].[Product] p
	ON p.[ProductID] = sod.[ProductID]
	INNER JOIN Adventureworks.[Production].[ProductSubcategory] ps
	ON ps.[ProductSubcategoryID] = p.ProductSubcategoryID
	INNER JOIN Adventureworks.[Production].[ProductCategory] pc
	ON pc.ProductCategoryID = ps.ProductCategoryID'
						

EXEC sp_execute_external_script 
				@language = N'R'
				, @script = @RScript
				, @input_data_1 = @SQLScript
				, @input_data_1_name = N''
WITH result SETS ( (
					 OrderQty INT
					,Discount DECIMAL(10,2)
					,name NVARCHAR(MAX)
					,name2 VARCHAR(200)
					,more_spec_chars NVARCHAR(200)
					,more_spec_chars2 VARCHAR(200)
					,More_spec_chars3 VARCHAR(200)
					) );



--- 2. let's do simple statistics

-- Data preparation
DECLARE @RScript NVARCHAR(MAX)
SET @RScript = N'OutputDataSet <- InputDataSet;'


DECLARE @SQLScript NVARCHAR(MAX)
SET @SQLScript = N'
		  SELECT 1 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 2 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''A'' AS GROUPs
UNION ALL SELECT 1 AS Nof, ''B'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''B'' AS GROUPs
UNION ALL SELECT 4 AS Nof, ''C'' AS GROUPs'
						
EXEC sp_execute_external_script 
				@language = N'R'
				, @script = @RScript
				, @input_data_1 = @SQLScript
				, @input_data_1_name = N''
WITH result SETS ( (
					 Nof INT
					 ,GROUPs CHAR(2)
					) );


-- doing simple group by 
-- without interfeering with data type
DECLARE @RScript NVARCHAR(MAX)
SET @RScript = N'
InputDataSet <- cust.data
mytable <- with(cust.data, table(Nof,GROUPs))
OutputDataSet <- data.frame(margin.table(mytable,2));'


DECLARE @SQLScript NVARCHAR(MAX)
SET @SQLScript = N'
		  SELECT 1 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 2 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''A'' AS GROUPs
UNION ALL SELECT 1 AS Nof, ''B'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''B'' AS GROUPs
UNION ALL SELECT 4 AS Nof, ''C'' AS GROUPs'
						
EXEC sp_execute_external_script 
				@language = N'R'
				, @script = @RScript
				, @input_data_1 = @SQLScript
				, @input_data_1_name = N'cust.data'
WITH result SETS ( (
					  GROUPs CHAR(2)
					 ,Freq INT
					) );



-- doing simple group by 
-- now we add a special character
DECLARE @RScript NVARCHAR(MAX)
SET @RScript = N'
InputDataSet <- cust.data
mytable <- with(cust.data, table(Nof,GROUPs))
OutputDataSet <- data.frame(margin.table(mytable,2));'


DECLARE @SQLScript NVARCHAR(MAX)
SET @SQLScript = N'
		  SELECT 1 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 2 AS Nof, ''A'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''A'' AS GROUPs
UNION ALL SELECT 1 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''Č'' AS GROUPs
UNION ALL SELECT 4 AS Nof, ''Č'' AS GROUPs'
						
EXEC sp_execute_external_script 
				@language = N'R'
				, @script = @RScript
				, @input_data_1 = @SQLScript
				, @input_data_1_name = N'cust.data'
WITH result SETS ( (
					  GROUPs CHAR(2)
					 ,Freq INT
					) );

/*
Error in sort.list(y) : invalid input 'È' in 'utf8towcs'
Calls: as.data.frame ... as.data.frame -> as.data.frame.character -> factor -> sort.list
*/


-- Available collations
SELECT name, description   FROM fn_helpcollations();  
SELECT  'Č'  COLLATE Slovenian_100_CI_AI_KS_WS AS l 

-- doing simple group by 
-- now we add a special character
-- and now we want to hack this issue

DECLARE @RScript NVARCHAR(MAX)
SET @RScript = N'InputDataSet <- cust.data
#for (i in 1:length(cust.data)) { Encoding(cust.data[[i]])="UTF-8" }
#InputDataSet <- data.frame(lapply(cust.data, as.character), stringsAsFactors=TRUE)
mytable <- with(cust.data, table(Nof,GROUPs))
OutputDataSet <- data.frame(margin.table(mytable,2));'


DECLARE @SQLScript NVARCHAR(MAX)
SET @SQLScript = N'
		  SELECT 1 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 2 AS Nof, ''A'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''A'' AS GROUPs
UNION ALL SELECT 1 AS Nof, ''D'' AS GROUPs
UNION ALL SELECT 3 AS Nof, ''C'' AS GROUPs
UNION ALL SELECT 4 AS Nof, ''Č'' COLLATE SQL_Latin1_General_CP1250_CI_AS AS GROUPs'
					

EXEC sp_execute_external_script 
				 @language = N'R'
				,@script = @RScript
				,@input_data_1 = @SQLScript
				,@input_data_1_name = N'cust.data'
WITH result SETS ( (
					  GROUPs NVARCHAR(2)
					 ,Freq INT
					) );

-- Error
--- U010D




-- DROP TABLE chartest
IF EXISTS (SELECT * FROM sys.objects WHERE [name] = 'chartest')
DROP TABLE dbo.chartest;


CREATE TABLE dbo.chartest 
(
	Nof INT
	,GROUPs NVARCHAR(10)
)

INSERT INTO dbo.chartest
		  SELECT 1 AS Nof, 'D' AS GROUPs
UNION ALL SELECT 2 AS Nof, 'A' AS GROUPs
UNION ALL SELECT 3 AS Nof, 'A' AS GROUPs
UNION ALL SELECT 1 AS Nof, 'D' AS GROUPs
UNION ALL SELECT 3 AS Nof, 'Č' AS GROUPs
UNION ALL SELECT 4 AS Nof, 'Č' AS GROUPs
UNION ALL SELECT 6 AS Nof, 'C' AS GROUPs


-- Same set of R Code
-- With this presentation NVARCHAR is working with no problems

DECLARE @RScript NVARCHAR(MAX)
SET @RScript = N'InputDataSet <- cust.data
mytable <- with(cust.data, table(Nof,GROUPs))
OutputDataSet <- data.frame(margin.table(mytable,2));'


DECLARE @SQLScript NVARCHAR(MAX)
SET @SQLScript = N'SELECT * FROM chartest'
					
EXEC sp_execute_external_script 
				 @language = N'R'
				,@script = @RScript
				,@input_data_1 = @SQLScript
				,@input_data_1_name = N'cust.data'

WITH result SETS ( (
					  GROUPs NVARCHAR(2)
					 ,Freq INT
					) );

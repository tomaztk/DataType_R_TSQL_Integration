#~~~~~~~~~~~~~~~~~~~~~~~
# Test of special characters using RODBC library
# Author: Tomaz Kastrun (tomaz.kastrun@gmail.com)
# Date: June 11, 2016
#~~~~~~~~~~~~~~~~~~~~~~~

library(RODBC)

myconn <-odbcDriverConnect("driver={SQL Server};Server=SICN-00031\\SQLSERVER2016RC3;database=Adventureworks;trusted_connection=true")


cust.data <- sqlQuery(myconn, "SELECT 1 AS Nof, 'D' AS GROUPs
                     UNION ALL SELECT 2 AS Nof, 'A' AS GROUPs
                     UNION ALL SELECT 3 AS Nof, 'A' AS GROUPs
                     UNION ALL SELECT 1 AS Nof, 'D' AS GROUPs
                     UNION ALL SELECT 3 AS Nof, 'È' AS GROUPs
                     UNION ALL SELECT 4 AS Nof, 'È' AS GROUPs")

cust.data2 <- sqlQuery(myconn, "SELECT 1 AS Nof, 'D' AS GROUPs
                      UNION ALL SELECT 2 AS Nof, 'A' AS GROUPs
                      UNION ALL SELECT 3 AS Nof, 'A' AS GROUPs
                      UNION ALL SELECT 1 AS Nof, 'D' AS GROUPs
                      UNION ALL SELECT 3 AS Nof, 'È' AS GROUPs
                      UNION ALL SELECT 4 AS Nof, 'È' AS GROUPs
                      UNION ALL SELECT 6 AS Nof, 'C' AS GROUPs")
close(myconn) 


mytable <- with(cust.data, table(Nof,GROUPs))
df <- data.frame(margin.table(mytable,2))
df

mytable2 <- with(cust.data2, table(Nof,GROUPs))
df2 <- data.frame(margin.table(mytable2,2))
df2

df
df2

# Without ROBC Library
# Using only R
# In this case it functions Natively OK
cust.data3 <- data.frame(Nof=c(1,2,3,1,3,4,6), GROUPs=c('D','A','A','D','È','È','C'))

mytable3 <- with(cust.data3, table(Nof,GROUPs))
df3 <- data.frame(margin.table(mytable3,2))
df3

# Adding CharSet=utf8 to ROBDBC
# no success

sessionInfo()

rm(cust.data, myconn)

library(RODBC)
#myconn <-odbcDriverConnect("driver={SQL Server};Server=SICN-00031\\SQLSERVER2016RC3;database=Adventureworks;trusted_connection=true;DBMSencoding=utf8")
myconn <-odbcDriverConnect("driver={SQL Server};Server=SICN-00031\\SQLSERVER2016RC3;database=Adventureworks;trusted_connection=true")

###|||||||||||||||||
### I have created a table in SQL Server and stored data in table

### CREATE TABLE chartest (Nof INT,GROUPs NVARCHAR(10))
### INSERT INTO chartest
### SELECT 1 AS Nof, 'D' AS GROUPs
### UNION ALL SELECT 2 AS Nof, 'A' AS GROUPs
### UNION ALL SELECT 3 AS Nof, 'A' AS GROUPs
### UNION ALL SELECT 1 AS Nof, 'D' AS GROUPs
### UNION ALL SELECT 3 AS Nof, 'È' AS GROUPs
### UNION ALL SELECT 4 AS Nof, 'È' AS GROUPs
###||||||||||||||||

cust.data <- sqlQuery(myconn, "SELECT * FROM NQS.dbo.chartest")

close(myconn) 

#with no special definition of DBMSencoding, I see special characters
cust.data


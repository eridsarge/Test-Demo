#Specify your own working directory
setwd('C:/Users/ESargent/Desktop/R-3.5.1.')

#set up the library paths to use for package installation
myPaths<-.libPaths()
myPaths<- c(myPaths,'C:/Users/ESargent/Desktop/R-3.5.1.')
.libPaths(myPaths)


#must specify library and repository downloading from
#DPLYR Pacakge for Data Manipulation
install.packages("dplyr", lib="C:/Users/ESargent/Desktop/R-3.5.1.",repos = "http://cran.us.r-project.org")
library("dplyr",lib.loc = "C:/Users/ESargent/Desktop/R-3.5.1.")


#Connecting to the Production Warehouse
install.packages("RODBC", lib="C:/Users/ESargent/Desktop/R-3.5.1.",repos = "http://cran.us.r-project.org")
library("RODBC",lib= "C:/Users/ESargent/Desktop/R-3.5.1.")
myConn<-odbcDriverConnect(connection = "Driver={SQL Server Native Client 11.0};server=RALDBPc01-SQL1\\PROD2012;database=WAREHOUSE;trusted_connection=yes;")



#Sample SQL query for a seperate Project
SqlTest<-sqlQuery(myConn, "select B.ALU_Name,
			                              D.TPLU_Year as Accounting_Date,
			                              E.ASLLU_CodeDesc as Annual_Statement_Line,
			                              Sum(A.PF_YTDWP) as YTD_WrittenPremium,
			                              Sum(A.PF_YTDEP) as YTD_EarnedPremium
                            from WAREHOUSE.dbo.PremiumFact A
                            inner Join [WAREHOUSE].[dbo].[AgentLkUp] B
                              on A.ALU_ID=B.ALU_ID
                            inner Join [WAREHOUSE].[dbo].[ProgramCodeLkUp] C
                              on A.PGMLU_ID=C.PGMLU_ID
                            inner Join Warehouse.dbo.TimePeriodLkUp D
                              on A.TPLU_ID=D.TPLU_ID
                            inner Join WAREHOUSE.dbo.AnnualStmtLineLkUp E
                              on A.ASLLU_ID=E.ASLLU_ID
                            where B.ALU_Code in ('0000223','0000299')
                            and A.BTLU_ID in (1,3)
                            and A.TPLU_ID in (132,144,156,168,180)
                            group by ALU_Name,
	                                    D.TPLU_Year,
		                                  E.ASLLU_CodeDesc
                            order by 2,3")



#Sample DPLYR Transformation
SqlTestTRFM<-SqlTest%>%
              group_by(ALU_Name,Annual_Statement_Line)%>%
              summarize(YTD_EarnedPremium=sum(YTD_EarnedPremium),
                        YTD_WrittenPremium=sum(YTD_WrittenPremium))%>%
              mutate(YTD_WPEP=(YTD_EarnedPremium/YTD_WrittenPremium)*100)



#Below here is for export not for power BI
###########################################################################
View(SqlTestTRFM)


#Get Working Directory for where files saved
directory<-getwd()
directory


#Send Excel Output to Working Directory
write.csv(SqlTestTRFM,file="export_test.csv",row.names = FALSE)






SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [UCSF.].[DBOptimize]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @DBName varchar (20)
	SELECT @DBName=DB_NAME()
	EXECUTE AdminDB.dbo.IndexOptimize
		@Databases = @DBName,
		@FragmentationLow = NULL,
		@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
		@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
		@FragmentationLevel1 = 5,
		@FragmentationLevel2 = 30,
		@UpdateStatistics = 'ALL',
		@OnlyModifiedStatistics = 'Y',
		@LogToTable = 'Y'		
END
GO

insert into [Framework.].[JobGroup] 
values (99,'DbOptimization','HelperJob','Update Statistic and Reindex DB')

insert into [Framework.].[Job] 
(JobId,Jobgroup,Step,IsActive,Script)
values (55,99,1,1,'EXEC [UCSF.].[DBOptimize]'),
(56,4,5,1,'EXEC [Framework.].[RunJobGroup] @JobGroup = 99')
SELECT *  FROM [Framework.].[Job]
order by jobgroup,step


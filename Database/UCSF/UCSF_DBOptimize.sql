USE [profiles_ucsd]
GO

/****** Object:  StoredProcedure [UCSF.].[DBOptimize]    Script Date: 5/12/2017 7:56:28 AM ******/
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


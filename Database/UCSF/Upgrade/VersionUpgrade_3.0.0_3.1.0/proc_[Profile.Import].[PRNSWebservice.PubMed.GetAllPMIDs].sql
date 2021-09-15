SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [Profile.Import].[PRNSWebservice.PubMed.GetAllPMIDs]
	@Job varchar(55),
	@BatchID varchar(100)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE  @baseURI NVARCHAR(max),
			@URL varchar(500),
			@logLevel int, 
			@rowsCount int

select @URL = URL, @logLevel = logLevel from [Profile.Import].[PRNSWebservice.Options] where job = @Job


	DECLARE @GetOnlyNewXML BIT
	DECLARE @Refresh BIT
	DECLARE @Debug BIT
	select @GetOnlyNewXML = case when options = 'GetOnlyNewXML=True' then 1 else 0 end from [Profile.Import].[PRNSWebservice.Options] where job = @Job
	select @Refresh = case when options = 'Refresh=True' then 1 else 0 end from [Profile.Import].[PRNSWebservice.Options] where job = @Job
	select @Debug = case when options = 'DEBUG' then 1 else 0 end from [Profile.Import].[PRNSWebservice.Options] where job = @Job

	CREATE TABLE #tmp (LogID INT, BatchID VARCHAR(100), RowID INT, HttpMethod VARCHAR(10), URL VARCHAR(500), PostData VARCHAR(MAX)) 

	
	IF @GetOnlyNewXML = 1 
	-- ONLY GET XML FOR NEW Publications
		BEGIN
			INSERT INTO #tmp(RowID) 
			SELECT distinct pmid
				FROM [Profile.Data].[Publication.PubMed.Disambiguation]
				WHERE pmid NOT IN(SELECT PMID FROM [Profile.Data].[Publication.PubMed.General])
				AND pmid IS NOT NULL AND pmid not in (select pmid from [Profile.Data].[Publication.PubMed.DisambiguationExclude])
		END
	ELSE IF @Refresh = 1
	-- UCSF "Partial Full" REFRESH
		BEGIN
			DECLARE @MonthsOld int = 2
			DECLARE @cutoffDate datetime = dateadd(Month, -@MonthsOld, GETDATE())
			INSERT INTO #tmp(RowID) --SELECT 24509520
				-- UCSF alteration begin
				SELECT DISTINCT TOP 100000 pmid FROM  (
				-- UCSF alteration ended
				SELECT d.pmid
				  FROM [Profile.Data].[Publication.PubMed.Disambiguation] d JOIN [Profile.Data].[Publication.PubMed.AllXML] x on d.pmid = x.pmid
				 WHERE d.pmid IS NOT NULL AND x.ParseDT IS NOT NULL AND x.ParseDT < @cutoffDate
				 UNION   
				SELECT i.pmid
				  FROM [Profile.Data].[Publication.Person.Include] i JOIN [Profile.Data].[Publication.PubMed.AllXML] x on i.pmid = x.pmid
				 WHERE i.pmid IS NOT NULL AND x.ParseDT IS NOT NULL AND x.ParseDT < @cutoffDate) t
		END 
	ELSE IF @Debug = 1
		BEGIN
			-- Whatever we want here
			INSERT INTO #tmp(RowID) 
				SELECT 24509520
		END
	ELSE
	-- FULL REFRESH
		BEGIN
			INSERT INTO #tmp(RowID) --SELECT 24509520
			SELECT distinct pmid
				FROM [Profile.Data].[Publication.PubMed.Disambiguation]
				WHERE pmid IS NOT NULL AND pmid not in (select pmid from [Profile.Data].[Publication.PubMed.DisambiguationExclude]) 
				UNION   
			SELECT distinct pmid
				FROM [Profile.Data].[Publication.Person.Include]
				WHERE pmid IS NOT NULL AND pmid not in (select pmid from [Profile.Data].[Publication.PubMed.DisambiguationExclude]) 
		END 


	UPDATE t SET
		t.LogID = -1,
		t.BatchID = @BatchID, 
		t.HttpMethod = 'POST',
		t.URL = o.url,
		t.PostData = '<PMID>' + cast(RowID as varchar(100)) + '</PMID>'
			FROM #tmp t
			JOIN [Profile.Import].[PRNSWebservice.Options] o ON o.job = 'GetPubMedXML'
	select @rowsCount = @@ROWCOUNT

	Update [Profile.Import].[PRNSWebservice.Log.Summary]  set RecordsCount = @rowsCount, RowsCount = @rowsCount where BatchID = @BatchID

	DECLARE @LogIDTable TABLE (LogID int, RowID int)
	IF @logLevel = 1
	BEGIN
		INSERT INTO [Profile.Import].[PRNSWebservice.Log] (Job, BatchID, RowID, HttpMethod, URL)
		OUTPUT inserted.LogID, Inserted.RowID into @LogIDTable
		SELECT @Job, @BatchID, RowID, 'POST', @URL FROM #tmp
		UPDATE t SET t.LogID = l.LogID FROM #tmp t JOIN @LogIDTable l ON t.RowID = l.RowID
	END
	ELSE IF @logLevel = 2
	BEGIN
		INSERT INTO [Profile.Import].[PRNSWebservice.Log] (Job, BatchID, RowID, HttpMethod, URL, PostData)
		OUTPUT inserted.LogID, Inserted.RowID into @LogIDTable
		SELECT @Job, @BatchID, RowID, 'POST', @URL, cast(PostData as varchar(max)) FROM #tmp
		UPDATE t SET t.LogID = l.LogID FROM #tmp t JOIN @LogIDTable l ON t.RowID = l.RowID
	END

	SELECT * FROM #tmp
END

GO
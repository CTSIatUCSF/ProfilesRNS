CREATE SCHEMA [UCSF.CTSASearch]
GO

/****** Object:  Table [UCSF.CTSASearch].[Publication.PubMed.Author]    Script Date: 12/16/2015 10:51:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.CTSASearch].[Publication.PubMed.Author](
	[PmPubsAuthorID] [int] NOT NULL,
	[URI] [varchar](2000) NULL,
	[URL] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED 
(
	[PmPubsAuthorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [UCSF.CTSASearch].[Publication.PubMed.Author]  WITH CHECK ADD FOREIGN KEY([PmPubsAuthorID])
REFERENCES [Profile.Data].[Publication.PubMed.Author] ([PmPubsAuthorID])
ON DELETE CASCADE
GO

/****** Object:  Table [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML]    Script Date: 12/16/2015 10:52:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML](
	[PMID] [int] NOT NULL,
	[X] [xml] NULL,
	[ParseDT] [datetime] NULL,
	[AuthorXML] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[PMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

/****** Object:  StoredProcedure [UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML]    Script Date: 12/16/2015 10:52:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure  [UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML] ( 					 @pmid INT,
																			   @coauthorxml XML)
AS
BEGIN
	SET NOCOUNT ON;	
	 
	-- Parse Load Publication XML
	BEGIN TRY 	 
	
		BEGIN TRAN
			-- Remove existing pmid record
			DELETE FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] WHERE pmid = @pmid
		
			-- Add CoAuthor XML	
			INSERT INTO [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML](pmid,X) VALUES(@pmid,CAST(@coauthorxml AS XML))		
			
			-- Parse CoAuthor XML
			EXEC  [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML] 	 @pmid		
		 
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML] FAILED WITH : ' + ERROR_MESSAGE() + ' for PMID=' + cast(@pmid as varchar),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH				
END




GO

/****** Object:  StoredProcedure [UCSF.CTSASearch].[Publication.PubMed.GetAllPMIDs]    Script Date: 12/16/2015 10:52:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Stored Procedure

CREATE PROCEDURE [UCSF.CTSASearch].[Publication.PubMed.GetAllPMIDs] (@GetOnlyNewXML BIT=0 )
AS
BEGIN
	SET NOCOUNT ON;	


	BEGIN TRY
		IF @GetOnlyNewXML = 1 
		-- ONLY GET XML FOR NEW Publications
			BEGIN
				--SELECT DISTINCT pmid
				--  FROM  [Profile.Data].[Publication.PubMed.General]
				-- WHERE pmid NOT IN(SELECT PMID FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML])
				--   AND pmid IS NOT NULL 
				SELECT DISTINCT pmid
				  FROM  [Profile.Data].[Publication.PubMed.General]
				 WHERE pmid IS NOT NULL AND PMID NOT IN (SELECT PMID FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] WHERE AuthorXML IS NOT NULL)
			END
		ELSE 
			BEGIN
				SELECT DISTINCT pmid
				  FROM  [Profile.Data].[Publication.PubMed.General]
				 WHERE pmid IS NOT NULL 
			END 
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK

		-- Raise an error with the details of the exception
		SELECT @ErrMsg = 'FAILED WITH : ' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)

	END CATCH				
END


GO

/****** Object:  StoredProcedure [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML]    Script Date: 12/16/2015 10:53:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML]
	@pmid int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FirstName VARCHAR(100)
	DECLARE @LastName VARCHAR(100)
	DECLARE @URI VARCHAR(2000)
	DECLARE @PmPubsAuthorID  int
	DECLARE @baseURI varchar(200)
	DECLARE @RowsToProcess   int
	DECLARE @CurrentRow      int
	DECLARE @SelectCol1      int

	SELECT @baseURI = Value FROM [Framework.].[Parameter] WHERE ParameterID = 'baseURI'

	--*** coauthor  links from CTSASearch***
	declare @c as table (
		RowID int not null primary key identity(1,1),
		firstname varchar(100),
		lastname varchar(100),
		uri nvarchar(2000)
	)

	insert into @c (firstName, lastName, uri)
		select 
			nref.value('firstName[1]','varchar(max)') FirstName, 
			nref.value('lastName[1]','varchar(max)') LastName,
			nref.value('uri[1]','varchar(max)') URI
		from [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] cross apply x.nodes('//publicationList/publication/authorList/author') as R(nref)
		where pmid = @pmid and X is not null

	SET @RowsToProcess=@@ROWCOUNT

	SET @CurrentRow=0
	WHILE @CurrentRow<@RowsToProcess
	BEGIN
		SET @CurrentRow=@CurrentRow+1
		SELECT 
			@FirstName=firstName, @LastName = lastName, @URI=LTRIM(RTRIM(uri))
			FROM @c
			WHERE RowID=@CurrentRow

		--do your thing here--
		SET @PmPubsAuthorID  = NULL

		-- tight match
		SELECT @PmPubsAuthorID = PmPubsAuthorID FROM [Profile.Data].[Publication.PubMed.Author] 
			WHERE PMID = @pmid AND LastName = @LastName and ForeName = @FirstName 

		-- last name only
		IF (@PmPubsAuthorID IS NULL) 
			SELECT @PmPubsAuthorID = PmPubsAuthorID FROM [Profile.Data].[Publication.PubMed.Author] 
				WHERE PMID = @pmid AND LastName = @LastName 
 
		-- mangled but matching
		IF (@PmPubsAuthorID IS NULL) 
			SELECT @PmPubsAuthorID = PmPubsAuthorID FROM [Profile.Data].[Publication.PubMed.Author] 
				WHERE PMID = @pmid AND (CHARINDEX(LastName, @FirstName + ' ' + @LastName) > 0 OR  CHARINDEX(FirstName, @FirstName + ' ' + @LastName) > 0) 

		-- do not clobber authors that are in our own system, those have been accuratley set by [Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]
		IF (@PmPubsAuthorID IS NOT NULL AND NOT EXISTS (SELECT * FROM [UCSF.CTSASearch].[Publication.PubMed.Author] WHERE 
			PmPubsAuthorID = @PmPubsAuthorID AND URI LIKE @baseURI + '%') ) 
		BEGIN
			DELETE [UCSF.CTSASearch].[Publication.PubMed.Author] WHERE PmPubsAuthorID = @PmPubsAuthorID
			INSERT [UCSF.CTSASearch].[Publication.PubMed.Author] (PmPubsAuthorID, URI, URL) VALUES
				(@PmPubsAuthorID, @URI, [UCSF.CTSASearch].[fn_UrlFromURI](@URI))
		END
	END

	-- authors, both local and those from CTSASearch
	declare @a as table (
		i int identity(0,1) primary key,
		lastname varchar(100),
		initials varchar(20),
		url varchar(2000)
	)

	insert into @a (lastname, initials, url)
		select a.lastname, a.initials, c.url
		from [Profile.Data].[Publication.PubMed.Author] a left outer join [UCSF.CTSASearch].[Publication.PubMed.Author] c on a.PmPubsAuthorID = c.PmPubsAuthorID
		where a.pmid = @pmid
		order by a.PmPubsAuthorID

	--coauthor links, set display xml and build legacy authors list in PubMed general
	DECLARE @CurrentAuthor varchar(200)
	DECLARE @CurrentURL varchar(200)
	DECLARE @VisibleAuthorLen int
	DECLARE @VisibleAuthorXML varchar(max)
	DECLARE @AllAuthorsVisible bit

	SELECT @CurrentRow = min(i) FROM @a
	SELECT @RowsToProcess = max(i) FROM @a
	SET @VisibleAuthorLen = 0
	SET @VisibleAuthorXML = '<authors>'
	SET @AllAuthorsVisible = 1

	WHILE @CurrentRow<=@RowsToProcess
	BEGIN
		SELECT @CurrentAuthor = lastname+' '+initials, @CurrentURL = url 
			FROM @a	WHERE i=@CurrentRow

		SET @CurrentRow=@CurrentRow+1

		-- check size of visible authors, this is based on logic in [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
		IF (coalesce(@CurrentAuthor, '') = '')
			BEGIN
				CONTINUE
			END
		ELSE IF (@VisibleAuthorLen + 2 + len(@CurrentAuthor) < 3990) 
			BEGIN
				SET @VisibleAuthorLen = @VisibleAuthorLen + 2 + len(@CurrentAuthor)
				SET @VisibleAuthorXML = @VisibleAuthorXML + '<author><display>'+@CurrentAuthor+'</display>' + 
						coalesce('<url>'+@CurrentURL+'</url>', '') + '</author>'
			END
		ELSE
			BEGIN
				SET @AllAuthorsVisible = 0
				BREAK
			END
	END
	
	IF (@AllAuthorsVisible = 1) 
		SELECT @AllAuthorsVisible = CASE WHEN AuthorListCompleteYN = 'Y' THEN 1 ELSE 0 END FROM 
			[Profile.Data].[Publication.PubMed.General] WHERE PMID = @pmid

	IF (@AllAuthorsVisible = 1) 
		SET @VisibleAuthorXML = @VisibleAuthorXML + '</authors>'
	ELSE
		SET @VisibleAuthorXML = @VisibleAuthorXML + '<author><display>et al</display></author></authors>'

	-- now set the authorXML
	IF EXISTS (SELECT * FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] WHERE pmid = @pmid)
		UPDATE [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] set ParseDT = GetDate(), AuthorXML=@VisibleAuthorXML where pmid = @pmid
	ELSE
		INSERT [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] (PMID, ParseDT, AuthorXML) VALUES (@pmid, GetDate(),@VisibleAuthorXML)


END

/**************************************
*
*
*
*
*
*
**************************************/

GO

/****** Object:  UserDefinedFunction [UCSF.CTSASearch].[fn_UrlFromURI]    Script Date: 12/16/2015 10:53:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [UCSF.CTSASearch].[fn_UrlFromURI]
(
	@s varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- go from  http://vivo.experts.scival.com/indiana/individual/n955 to http://www.experts.scival.com/indiana/expert.asp?u_id=955
	-- and from http://vivo.scholars.northwestern.edu/individual/n4023 to http://www.scholars.northwestern.edu/expert.asp?u_id=4023
	DECLARE @str varchar(255)
	DECLARE @localBaseURI varchar(255)
	SET @str = @s
	SELECT @localBaseURI = Value FROM [Framework.].[Parameter] WHERE ParameterID = 'BaseURI'

 	IF CHARINDEX('vivo.experts.scival.com', @s) > 0 
		SET @str = REPLACE(REPLACE(@s, 'vivo.experts.scival.com', 'www.experts.scival.com'), 'individual/n', 'expert.asp?u_id=')
 	ELSE IF CHARINDEX('vivo.scholars.northwestern.edu', @s) > 0 
		SET @str = REPLACE(REPLACE(@s, 'vivo.scholars.northwestern.edu', 'www.scholars.northwestern.edu'), 'individual/n', 'expert.asp?u_id=')
	ELSE IF CHARINDEX(@localBaseURI, @s) = 1
	BEGIN
		-- Nick, you'll need to add your own logic here!
		SELECT @str = Value + '/' FROM [Framework.].[Parameter] WHERE ParameterID = 'BasePath'
		SELECT @str = @str + na.UrlName FROM [UCSF.].[NameAdditions] na JOIN [Profile.Data].[Person] p on 
			na.InternalUserName = p.InternalUserName JOIN [RDF.Stage].[InternalNodeMap] n on n.internalid = p.personId
			and n.[class] = 'http://xmlns.com/foaf/0.1/Person' 
			WHERE n.nodeid = CAST(SUBSTRING(@s, LEN(@localBaseURI) + 1, LEN(@s) - LEN(@localBaseURI)) as bigint)
	END
	RETURN @str

END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference]	(
	@pmid int,
	@ArticleDay varchar(10),
	@ArticleMonth varchar(10),
	@ArticleYear varchar(10),
	@ArticleTitle varchar(4000),
	@Issue varchar(255),
	@JournalDay varchar(50),
	@JournalMonth varchar(50),
	@JournalYear varchar(50),
	@MedlineDate varchar(255),
	@MedlinePgn varchar(255),
	@MedlineTA varchar(1000),
	@Volume varchar(255),
	@encode_html bit=0
)

RETURNS NVARCHAR(MAX) 
AS 
BEGIN

	DECLARE @Reference NVARCHAR(MAX)

	SET @Reference = --(case when right(@Authors,5) = 'et al' then @Authors+'. '
					 --			when @AuthorListCompleteYN = 'N' then @Authors+', et al. '
					 --			when @Authors <> '' then @Authors+'. '
					 --			else '' end) +
					 CASE WHEN @encode_html=1 THEN '<a href="'+'http'+'://www.ncbi.nlm.nih.gov/pubmed/'+cast(@pmid as varchar(50))+'" target="_blank">'+coalesce(@ArticleTitle,'')+'</a>' + ' '
								 ELSE coalesce(@ArticleTitle,'') + ' '
						END
					+ coalesce(@MedlineTA,'') + '. '
					+ (case when @JournalYear is not null then rtrim(@JournalYear + ' ' + coalesce(@JournalMonth,'') + ' ' + coalesce(@JournalDay,''))
							when @MedlineDate is not null then @MedlineDate
							when @ArticleYear is not null then rtrim(@ArticleYear + ' ' + coalesce(@ArticleMonth,'') + ' ' + coalesce(@ArticleDay,''))
						else '' end)
					+ (case when coalesce(@JournalYear,@MedlineDate,@ArticleYear) is not null
								and (coalesce(@Volume,'')+coalesce(@Issue,'')+coalesce(@MedlinePgn,'') <> '')
							then '; ' else '' end)
					+ coalesce(@Volume,'')
					+ (case when coalesce(@Issue,'') <> '' then '('+@Issue+')' else '' end)
					+ (case when (coalesce(@MedlinePgn,'') <> '') and (coalesce(@Volume,'')+coalesce(@Issue,'') <> '') then ':' else '' end)
					+ coalesce(@MedlinePgn,'')
					+ '.'

	RETURN @Reference

END

GO





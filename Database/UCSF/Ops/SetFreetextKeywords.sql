USE [profilesRNS]
GO

/****** Object:  StoredProcedure [UCSF.].[SetORCID]    Script Date: 1/28/2020 11:18:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [UCSF.].[ReplaceKeywords]
@SubjectURL varchar(255) =NULL,
@Keywords varchar(max)=NULL

 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;
       
	   DECLARE @BasePath nvarchar(50)
       DECLARE @SubjectID bigint
       DECLARE @PredicateID bigint
	   

--declare @SubjectURL varchar(255) ='eric.meeks'
	   SELECT @BasePath = BasePath FROM [UCSF.].Brand WHERE Theme = 'UCSF';       
	   SELECT @SubjectID = NodeID FROM [UCSF.].[vwPerson] where PrettyURL = @BasePath + '/' + @SubjectURL
       SELECT @PredicateID = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#freetextKeyword');
--select  @BasePath, @SubjectID, @PredicateID        

		IF @SubjectID IS NULL
			RETURN			         

		-- DELETE OLD ONES
		DECLARE @ObjectID bigint
		WHILE EXISTS (SELECT * FROM  [RDF.].[Triple] WHERE Subject=@SubjectID and predicate=@PredicateID )
		BEGIN
			SELECT TOP 1 @ObjectID = [Object] FROM  [RDF.].[Triple] WHERE Subject=@SubjectID and predicate=@PredicateID
			EXEC [RDF.].[DeleteTriple] @SubjectID=@SubjectID, @PredicateID=@PredicateID, @ObjectID=@ObjectID
--SELECT @ObjectID
		END

		-- ADD NEW ONES
		DECLARE @ndx int = 1
		DECLARE @Keyword nvarchar(255)
--DECLARE @ObjectID bigint
--declare @Keywords  varchar(max) = '"creating a high value health care system","utilization and cost-effectiveness of care","women''s reproductive health","systematic literature review","cancer","health economics","quantitative preference measurement","policy analysis","cost-effectiveness analysis","personalized/precision medicine","coverage/reimbursement policies","secondary dataset analysis","population screening","Health services research","comparative effectiveness research","value of diagnostics","big data","precision medicine","Insurer coverage","Economic evaluation","Policy analysis"'
		WHILE (LEN(@Keywords) > 0)
		BEGIN
			IF CHARINDEX('","',@Keywords) > 0
				SELECT @Keyword = REPLACE(SUBSTRING(@Keywords, 1, CHARINDEX('","',@Keywords)),'"', '')
			ELSE
				SELECT @Keyword = REPLACE(@Keywords,'"', '')
--select @Keyword, @Keywords
			--SELECT @Keywords = REPLACE(@Keywords, '"' + @Keyword + '"', '')
			SELECT @Keywords = SUBSTRING(@Keywords, LEN('"' + @Keyword + '"')+1, LEN(@Keywords))
			IF CHARINDEX(',', @Keywords) = 1
				SELECT @Keywords = SUBSTRING(@Keywords, 2, LEN(@Keywords))

			EXEC [RDF.].GetStoreNode @Value=@Keyword, @Language=null, @DataType=null, @NodeID=@ObjectID OUTPUT
--SELECT @ObjectID
			EXEC [RDF.].GetStoreTriple @SubjectID=@SubjectID, @PredicateID=@PredicateID, @ObjectID=@OBjectID, @SortOrder=@ndx
			SELECT @ndx = @ndx +1
		END
END


GO



USE [profiles_ucsf_29]
GO

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromOntology]    Script Date: 10/13/2016 2:25:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[RemoveAppFromOntology](@appId INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
		DECLARE @Name NVARCHAR(255)
		DECLARE @PropertyURI NVARCHAR(255)
		DECLARE @SubjectNode BIGINT
		DECLARE @ObjectNode BIGINT
		
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE appId = @appId 
		SET @PropertyURI = 'http://orng.info/ontology/orng#has' + @Name				
			
		IF (@PropertyURI IS NOT NULL)
		BEGIN	
			DELETE FROM [Ontology.].[ClassProperty]	WHERE Property = @PropertyURI
			DELETE FROM [Ontology.].[PropertyGroupProperty] WHERE PropertyURI = @PropertyURI
			-- get this data from the Import table
			SELECT @SubjectNode = _SubjectNode, @ObjectNode = _ObjectNode FROM [Ontology.Import].[Triple]
				WHERE Subject = @PropertyURI AND Predicate = 'http://www.w3.org/2000/01/rdf-schema#label'
			-- now remove items from the Import table
			DELETE FROM [Ontology.Import].[Triple] WHERE Subject = @PropertyURI
			-- and remove from stage
			DELETE FROM [RDF.Stage].[Triple] WHERE sURI = @PropertyURI
		END

		DECLARE @PropertyNode BIGINT
		SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] WHERE
			Class = 'http://orng.info/ontology/orng#Application' AND 
			Property = 'http://orng.info/ontology/orng#applicationId' --_PropertyNode
		SELECT @NodeID = t.[Subject] FROM [RDF.].Triple t JOIN
			[RDF.].Node n ON t.[Object] = n.nodeid 
			WHERE t.Predicate = @PropertyNode AND n.[Value] = CAST(@appId AS VARCHAR)
		
		IF (@NodeID IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @NodeID, @DeleteType = 0								   
		END	

		IF (@SubjectNode IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @SubjectNode, @DeleteType = 0								   
		END	

		IF (@ObjectNode IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @ObjectNode, @DeleteType = 0								   
		END	
		-- 
END



GO


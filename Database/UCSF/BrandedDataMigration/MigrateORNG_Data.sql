/********** ORNG Make sure that ORNG..Apps Name field matches [Ontology.].[ClassProperty] _PropertyLabel !!!!!
Also check that App Names match
****************************************************************************************/

DECLARE @Institution VARCHAR(50) = 'UCSD'
DECLARE @SourceDB VARCHAR(50) = 'profiles_ucsd' 

DECLARE @SQL NVARCHAR(MAX)
DECLARE @AppID int

/****************
To move the data itself 
***********************/

SELECT @SQL = N'
SELECT d.NodeID, n.AppID INTO tmpOrng FROM [' + @SourceDB + '].[RDF.].Triple t JOIN [' + @SourceDB + '].[Ontology.].ClassProperty c on t.Predicate = c._PropertyNode 
JOIN [' + @SourceDB + '].[ORNG.].Apps a on a.Name = c._PropertyLabel JOIN [ORNG.].[Apps] n on a.Name = n.Name JOIN [' + @SourceDB + '].[UCSF.].vwPerson s on t.Subject = s.NodeID JOIN 
[UCSF.].vwPerson d ON d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, ''' + @Institution + ''')'
--SELECT @SQL
EXEC dbo.sp_executesql @SQL


DECLARE @NodeID bigint 

WHILE EXISTS (SELECT * FROM tmpOrng)
BEGIN 
	SELECT TOP 1 @NodeID = NodeID, @AppID = AppID FROM tmpOrng

	EXEC [ORNG.].[AddAppToPerson] @SubjectID = @NodeID, @AppID = @AppID

	DELETE FROM tmpOrng WHERE NodeID = @NodeID AND AppID = @AppID 
END
DROP TABLE tmpOrng

SELECT @SQL = N'
INSERT INTO [ORNG.].[AppData]
           ([NodeID]
           ,[AppID]
           ,[Keyname]
		   ,[Value]
		   ,[CreatedDT]
		   ,[UpdatedDT])
SELECT d.NodeID, n.AppID, a.Keyname, a.Value, a.CreatedDT, a.UpdatedDT FROM [UCSF.].[vwPerson] d join [' + @SourceDB + '].[UCSF.].[vwPerson] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, ''' + @Institution + ''')
JOIN [' + @SourceDB + '].[ORNG.].[AppData] a on a.NodeID = s.NodeID JOIN [' + @SourceDB + '].[ORNG.].[Apps] sa on sa.AppID = a.AppID JOIN [ORNG.].[Apps] n on n.Name = sa.Name'

--SELECT @SQL
EXEC dbo.sp_executesql @SQL

/************** FOR AFTER THE ADD IF FILTERS WERE ADDED LATER
SELECT s.NodeID, a.AppID INTO tmpOrng FROM [RDF.].Triple t JOIN [Ontology.].ClassProperty c on t.Predicate = c._PropertyNode 
JOIN [ORNG.].Apps a on a.Name = c._PropertyLabel JOIN [UCSF.].vwPerson s on t.Subject = s.NodeID

--select * from tmpOrng
DECLARE @NodeID bigint 
DECLARE @AppID int

WHILE EXISTS (SELECT * FROM tmpOrng)
BEGIN 
	SELECT TOP 1 @NodeID = NodeID, @AppID = AppID FROM tmpOrng

	EXEC [ORNG.].[AddAppToPerson] @SubjectID = @NodeID, @AppID = @AppID

	DELETE FROM tmpOrng WHERE NodeID = @NodeID AND AppID = @AppID 
END
DROP TABLE tmpOrng
*****************/
-- =CONCATENATE("exec [UCSF.].RemoveBadWebLink @PrettyURL='", A1, "', @BadLinkURL='", C1,"';")
/****** Object:  StoredProcedure [UCSF.].[RemoveBadWebLink]    Script Date: 2/6/2020 10:30:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [UCSF.].[RemoveBadWebLink]
@PrettyURL varchar(255),
@BadLinkURL varchar(255)

 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;
       
	   DECLARE @AppID int
	   DECLARE @SubjectID BIGINT
	   DECLARE @ndx int=0
	   DECLARE @ReadURL varchar(255)

	   SELECT @AppID=AppID FROM [ORNG.].[Apps] WHERE [Name] = 'Websites';
	   SELECT @SubjectID=NodeID FROM [UCSF.].[vwPerson] WHERE PrettyURL = @PrettyURL

	   IF @SubjectID IS NULL
		  RETURN


	   -- to remove new style
	   DECLARE @Keyname varchar(25)=NULL
	   SELECT @Keyname=Keyname FROM [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and Keyname like 'link[_]%' and VALUE like '%' + @BadLinkURL + '%'
	   IF @Keyname IS NOT NULL
	   BEGIN
			SELECT @ndx=cast(REPLACE(@Keyname, 'link_', '') as int)
			DECLARE @Count int
			SELECT @Count=cast([Value] as int) FROM [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and Keyname = 'links_count'
			IF (@count = 1) 
			BEGIN
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID	
				RETURN
			END
			-- remove bad entry
			DELETE FROM [ORNG.].[AppData] WHERE AppID=@AppID and NodeID=@SubjectID and Keyname = 'link_' + cast(@ndx as varchar)
			-- update count
			UPDATE [ORNG.].[AppData] SET [VALUE] = cast((@Count-1) as varchar) WHERE AppID=@AppID and NodeID=@SubjectID and Keyname = 'links_count';
			-- update keynames of remaing higher index links
			UPDATE [ORNG.].[AppData] set Keyname = 'link-' + cast((cast(REPLACE(Keyname, 'link_', '') as int)-1) as varchar) WHERE AppID=@AppID and NodeID=@SubjectID 
				and Keyname like 'link[_]%' and cast(REPLACE(Keyname, 'link_', '') as int) > @ndx
	   END

	    -- to remove old, try ten times
		SELECT @ReadURL=JSON_VALUE([Value],'$[0]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[0]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[1]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[1]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[2]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[2]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[3]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[3]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[4]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[4]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[5]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[5]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[6]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[6]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[7]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[7]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[8]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[8]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[9]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[9]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END

		SELECT @ReadURL=JSON_VALUE([Value],'$[10]."link_url"') 
			from [ORNG.].[AppData] where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links'
		IF (@ReadURL=@BadLinkURL)
		BEGIN
			UPDATE [ORNG.].[AppData] SET [Value] = REPLACE(REPLACE(JSON_MODIFY([Value],'$[10]',NULL),'null,',''),',null','')
				where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' 

			-- check new value size, if it is too small then remove the aapp
			IF EXISTS (SELECT * FROM [ORNG.].[AppData] Where AppID=@AppID and NodeID=@SubjectID and KeyName = 'links' and len([value]) < 10)
				EXEC [ORNG.].RemoveAppFromAgent @SubjectID=@SubjectID, @AppID=@AppID			
					
			RETURN	  
	   END
	END




GO


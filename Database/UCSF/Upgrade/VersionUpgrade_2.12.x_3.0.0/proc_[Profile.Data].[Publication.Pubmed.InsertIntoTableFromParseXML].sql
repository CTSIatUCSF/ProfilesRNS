USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML]    Script Date: 5/20/2021 11:20:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Moisey Gruzman
-- Create date: 3/23/2021
-- Description:	This procedure adjust values from XML to match result table fields
-- =============================================
ALTER PROCEDURE [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML]
	-- Add the parameters for the stored procedure here
	@sourcetable varchar(100),@resultTable varchar(max),@keyUpdate varchar(100)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @source_schema varchar(max)=REPLACE(REPLACE(substring(@sourceTable,1,CHARINDEX('].[',@sourceTable)),'[',''),']','')
	declare @source_table varchar(max)=REPLACE(substring(@sourceTable,CHARINDEX('].[',@sourceTable)+3,100),']','')
	declare @target_schema varchar(max)=REPLACE(REPLACE(substring(@resultTable,1,CHARINDEX('].[',@resultTable)),'[',''),']','')
	declare @target_table varchar(max)=REPLACE(substring(@resultTable,CHARINDEX('].[',@resultTable)+3,100),']','')



	declare @tblComp table
		(ColumnName varchar(50), DataType varchar(50),dataLen int,xmlname varchar(50), xmltype varchar(50))
	insert into @tblComp
	select *  from	
	(
		select * from  (
			SELECT 
			column_name ColumnName, data_type DataType,
			character_maximum_length DataLen
			FROM information_schema.columns
			WHERE table_schema=@target_schema --='Profile.Data' 
			and table_name=@target_table -- = 'Publication.PubMed.General.Stage'
		)a
		join (
			SELECT column_name xmlname,data_type xmltype
			FROM information_schema.columns
			WHERE table_schema=@source_schema --'Profile.Data' 
			and table_name = @source_table --'Publication.PubMed.General.fromXML'
		)b on xmlname=ColumnName 
	)c
	select * from @tblComp


	declare @sql nvarchar(max)='set '
	select 
		@sql=@sql+ CHAR(13)+CHAR(10)+ColumnName+'='+adjcol+','
		from
		(
			select ColumnName,
			case
			 when xmltype=DataType and xmltype like '%varchar' then 'substring('+ColumnName+',1,'+cast(DataLen as varchar)+')'
			 when xmltype !=DataType and DataType ='nvarchar' then 'substring('+ColumnName+',1,'+cast(DataLen as varchar)+')'
			 --when xmltype !=DataType and DataType='text' then 'cast('+ColumnName+' as text)'
			 when xmltype=DataType and xmltype not like '%varchar' then ColumnName
			end adjcol 
			from @tblComp
			where (ColumnName !='pmid' or DataType='text')
		)a
		where adjcol is not NULL

	--print @sql
	set @sql=substring(@sql,1,LEN(@sql)-1)


	set @sql='update '+@sourceTable+' '+ @sql
	--print @sql
	exec sp_executesql @sql

	declare @processSQL nvarchar(max)
	declare @colList nvarchar(max)=''
	select @colList=@colList+ColumnName+','
	from (
		select * from @tblComp 
		where DataType !='text'
	)a
		--print @colList
	set @collist=substring(@collist,1,LEN(@collist)-1)
	set @processSQL='insert into '+@resultTable+ '('+@collist+')'+ CHAR(13)+CHAR(10)+' select '+@collist+' from '+@sourceTable
	--print @processSQL
	exec sp_executesql @processSQL
	
END

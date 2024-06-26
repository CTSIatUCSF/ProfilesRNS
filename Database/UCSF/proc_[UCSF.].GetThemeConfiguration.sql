USE [ProfilesRNS_Dev]
GO
/****** Object:  StoredProcedure [UCSF.].[GetThemeConfiguration]    Script Date: 3/2/2021 2:32:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [UCSF.].[GetThemeConfiguration] 
	@themeName varchar(20)
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @result varchar(max)=NULL;
declare @cnt int=0
IF OBJECT_ID('tempdb..#tmpGroups') IS NOT NULL  drop table #tmpGroups
select x.XmlCol.value('fn:local-name(.)', 'nvarchar(max)') as [Group]
into #tmpGroups
from [UCSF.].[Brand]
CROSS APPLY ThemeConfiguration.nodes('//root/*') x(XmlCol)
where theme =@themeName;

select 'for theme='+@themeName+' xml='+[Group] from #tmpGroups

-- set cursor
select @cnt=count(*) from #tmpGroups
if @cnt>0
	BEGIN
		declare @group varchar(max);
		declare @sql nvarchar(max)='set @defSettings='''';select @defSettings=@defSettings';
		DECLARE add_cursor CURSOR FOR
		select XmlCol.value('fn:local-name(.)', 'nvarchar(max)') as [Group]
		from [UCSF.].[Brand]
			CROSS APPLY ThemeConfiguration.nodes('//root/*') x(XmlCol)
		where theme in ('Default')
			and XmlCol.value('fn:local-name(.)', 'nvarchar(max)') not in (
				select * from #tmpGroups
			)
		OPEN add_cursor;
		FETCH NEXT FROM add_cursor INTO @group;
		WHILE (@@FETCH_STATUS <> -1 )
		BEGIN
			print @sql +' before select'
			SELECT @sql= @sql+'+cast(ThemeConfiguration.query(''/root/'+@group+''') as varchar(max))'
			PRINT @sql +'before fetch'
			FETCH NEXT FROM add_cursor INTO @group
		END
    print (@sql)
		declare @line varchar(max);
		set @sql=@sql+' from [UCSF.].[Brand] where Theme=''Default'';'
		print @sql+'before exec'
		execute  sp_executesql @sql, N'@DefSettings varchar(max) out', @line output
		CLOSE add_cursor;
		DEALLOCATE add_cursor;
		select @result=REPLACE(cast(ThemeConfiguration as varchar(max)),'</root>',@line+'</root>')
		from [UCSF.].[Brand]
		where theme =@themeName;
	END
	select ISNULL(@result,'NULL') as config;
END

USE [profiles_ucsd]
GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]    Script Date: 3/9/2017 3:11:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]
	@NodeID BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DescriptorName NVARCHAR(255)
 	SELECT @DescriptorName = d.DescriptorName
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n,
			[Profile.Data].[Concept.Mesh.Descriptor] d
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
			AND m.InternalID = d.DescriptorUI

    -- Insert statements for procedure here
	declare @gc varchar(max)

	declare @y table (
		y int,
		A int,
		B int
	)

	insert into @y (y,A,B)
		select n.n y, coalesce(t.A,0) A, coalesce(t.B,0) B
		from [Utility.Math].[N] left outer join (
			select (case when y < 1970 then 1970 else y end) y,
				sum(A) A,
				sum(B) B
			from (
				select pmid, pubyear y, (case when w = 1 then 1 else 0 end) A, (case when w < 1 then 1 else 0 end) B
				from (
					select distinct pmid, pubyear, topicweight w
					from [Profile.Cache].[Concept.Mesh.PersonPublication]
					where meshheader = @DescriptorName
				) t
			) t
			group by y
		) t on n.n = t.y
		where n.n between 1980 and year(getdate())

	declare @x int

	select @x = max(A+B)
		from @y

	if coalesce(@x,0) > 0
	begin
		declare @v varchar(1000)
		declare @z int
		declare @k int
		declare @i int

		set @z = power(10,floor(log(@x)/log(10)))
		set @k = floor(@x/@z)
		if @x > @z*@k
			select @k = @k + 1
		if @k > 5
			select @k = floor(@k/2.0+0.5), @z = @z*2

		set @v = ''
		set @i = 0
		while @i <= @k
		begin
			set @v = @v + '|' + cast(@z*@i as varchar(50))
			set @i = @i + 1
		end
		set @v = '|0|'+cast(@x as varchar(50))
		--set @v = '|0|50|100'

		declare @h varchar(1000)
		set @h = ''
		select @h = @h + '|' + (case when y % 2 = 1 then '' else ''''+right(cast(y as varchar(50)),2) end)
			from @y
			order by y 

		declare @w float
		--set @w = @k*@z
		set @w = @x

		declare @d varchar(max)
		set @d = ''
		select @d = @d + cast(floor(0.5 + 100*A/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1) + '|'
		select @d = @d + cast(floor(0.5 + 100*B/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1)

		declare @c varchar(50)
		set @c = 'b23f45,b4b9bF'
		--set @c = 'FB8072,B3DE69,80B1D3'
		--set @c = 'F96452,a8dc4f,68a4cc'
		--set @c = 'fea643,76cbbd,b56cb5'

		--select @v, @h, @d

		--set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=First+Author|Middle or Unkown|Last+Author&chco='+@c+'&chbh=10'
		set @gc = '//chart.googleapis.com/chart?chs=620x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=Major+Topic|Minor+Topic&chco='+@c+'&chbh=9'


		declare @asText varchar(max)
		set @asText = '<table style="width:592px"><tr><th>Year</th><th>Major Topic</th><th>Minor Topic</th><th>Total</th></tr>'
		select @asText = @asText + '<tr><td>' + cast(y as varchar(50)) + '</td><td>' + cast(A as varchar(50)) + '</td><td>' + cast(B as varchar(50)) + '</td><td>' + cast(A + B as varchar(50)) + '</td></tr>'
			from @y
			where A + B > 0
			order by y 
		select @asText = @asText + '</table>'

		declare @alt varchar(max)
		select @alt = 'Bar chart showing ' + cast(sum(A + B) as varchar(50))+ ' publications over ' + cast(count(*) as varchar(50)) + ' distinct years, with a maximum of ' + cast(@x as varchar(50)) + ' publications in ' from @y where A + B > 0
		select @alt = @alt + cast(y as varchar(50)) + ' and '
			from @y
			where A + B = @x
			order by y 
		select @alt = left(@alt, len(@alt) - 4)

		select @gc gc, @alt alt, @asText asText --, @w w

		--select * from @y order by y

	end

END

GO



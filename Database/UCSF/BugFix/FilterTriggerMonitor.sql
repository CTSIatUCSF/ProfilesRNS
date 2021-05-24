
/****** Object:  Table [Profile.Data].[Person.FilterRelationship]    Script Date: 9/10/2020 9:27:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [UCSF.].[MonitorPersonFilter](
	[action] [nvarchar](200) NOT NULL,
	[PersonID] [int] NOT NULL,
	[PersonFilterid] [int] NOT NULL,
    [created_at] DATETIME NOT NULL
                DEFAULT CURRENT_TIMESTAMP
) ON [PRIMARY]

GO

CREATE TRIGGER [Profile.Data].[UCSFMonitorPersonFilterTriggerDelete]
    ON [Profile.Data].[Person.FilterRelationship]
    AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [UCSF.].[MonitorPersonFilter](
        [action], 
        [PersonID],
        [PersonFilterid]
    )
    SELECT
		'INSERT', 
        i.[PersonID],
        i.[PersonFilterid]
    FROM
        inserted i
    UNION ALL
    SELECT
		'DELETE', 
        d.[PersonID],
        d.[PersonFilterid]
    FROM
        deleted d;
END
GO


--exec [ORNG.].AddAppToAgent @SubjectID=225751, @AppID=132

--select * from [UCSF.].[MonitorPersonFilter]

--exec [ORNG.].RemoveAppFromAgent @SubjectID=225751, @AppID=132

--select * from [UCSF.].vwPerson where LastName = 'meeks';
-- primary
select count(*), PersonFilterid from [Profile.Data].[Person.FilterRelationship]  group by PersonFilterid;
select count(*), personfilter from [Profile.Import].[PersonFilterFlag] group by personfilter; --16, 1008 

select count(*), internalusername from [Profile.Import].[PersonFilterFlag] where personfilter = 'Academic Senate Committees' group by internalusername order by count(*) desc

select 'exec [ORNG.].AddAppToAgent @SubjectID=' + cast(p.nodeid as varchar)+ ', @AppID =' + cast(a.AppId as varchar) + ';' from [ORNG.].Apps a join [Profile.Data].[Person.Filter] f on a.PersonFilterID = f.PersonFilterID
join [Ontology.].[ClassProperty] c on c.Property = 'http://orng.info/ontology/orng#has' + [ORNG.].[fn_AppNameFromAppID](a.AppID)
join [RDF.].Triple t on t.Predicate = c._PropertyNode and t.ViewSecurityGroup = -1 join [UCSF.].vwPerson p on p.nodeid = t.Subject -- 9159 



-- clean up
select count(*), internalusername, personfilter from [Profile.Import].[PersonFilterFlag] group by internalusername, personfilter order by count(*) desc;

delete from  [Profile.Import].[PersonFilterFlag] where PersonFilter in (select f.PersonFilter  from [ORNG.].Apps a join [Profile.Data].[Person.Filter] f on a.PersonFilterID = f.PersonFilterID);

select distinct 'insert [Profile.Import].[PersonFilterFlag] VALUES (''' + p.InternalUsername + ''', ''' + f.PersonFilter + ''');' from [ORNG.].Apps a join [Profile.Data].[Person.Filter] f on a.PersonFilterID = f.PersonFilterID
join [Ontology.].[ClassProperty] c on c.Property = 'http://orng.info/ontology/orng#has' + [ORNG.].[fn_AppNameFromAppID](a.AppID)
join [RDF.].Triple t on t.Predicate = c._PropertyNode and t.ViewSecurityGroup = -1 join [UCSF.].vwPerson p on p.nodeid = t.Subject -- 9159

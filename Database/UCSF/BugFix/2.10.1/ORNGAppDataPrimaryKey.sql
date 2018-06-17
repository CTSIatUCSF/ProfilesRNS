
-- look for bad data. Fix it however you can
select nodeid, appid, keyname, count(*) from [ORNG.].[AppData] group by nodeid, appid, keyname having count(*) > 1

-- save data fist!
select * into #tmpOrngAppData FROM  [ORNG.].[AppData]

/****** Object:  Table [ORNG.].[AppData]    Script Date: 6/3/2018 10:56:35 AM ******/
DROP TABLE [ORNG.].[AppData]
GO

-- build new one
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ORNG.].[AppData](
	[NodeID] [bigint] NOT NULL,
	[AppID] [int] NOT NULL,
	[Keyname] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](4000) NULL,
	[CreatedDT] [datetime] NULL,
	[UpdatedDT] [datetime] NULL,
 CONSTRAINT [PK__AppData] PRIMARY KEY CLUSTERED 
(
	[NodeID] ASC, [AppID] ASC, [Keyname]
)
) ON [PRIMARY]

GO

ALTER TABLE [ORNG.].[AppData] ADD  CONSTRAINT [DF_orng_appdata_createdDT]  DEFAULT (getdate()) FOR [CreatedDT]
GO

ALTER TABLE [ORNG.].[AppData] ADD  CONSTRAINT [DF_orng_appdata_updatedDT]  DEFAULT (getdate()) FOR [UpdatedDT]
GO

/****** Object:  Index [IDX_PersonApp]    Script Date: 05/17/2013 13:27:31 ******/
/**
Check if this index is needed! 
***/
--CREATE NONCLUSTERED INDEX [IDX_PersonApp] ON [ORNG.].[AppData] 
--(
--	[NodeID] ASC,
--	[AppID] ASC
--)
--INCLUDE ( [Keyname],
--[Value]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--GO
--DROP INDEX [IDX_PersonApp] ON [ORNG.].[AppData] 

-- new stuff
ALTER TABLE [ORNG.].[AppData]  WITH CHECK ADD  CONSTRAINT [FK_orng_app_data_apps] FOREIGN KEY([AppID])
REFERENCES [ORNG.].[Apps] ([AppID])
GO

ALTER TABLE [ORNG.].[AppData] CHECK CONSTRAINT [FK_orng_app_data_apps]
GO

ALTER TABLE [ORNG.].[AppData]  WITH CHECK ADD  CONSTRAINT [FK_orng_app_data_node] FOREIGN KEY([NodeID])
REFERENCES [RDF.].[Node] ([NodeID])
GO

ALTER TABLE [ORNG.].[AppData] CHECK CONSTRAINT [FK_orng_app_data_node]
GO

-----
insert [ORNG.].[AppData] select * from #tmpOrngAppData where AppID in (select appid from [ORNG.].[Apps]) meekse	

--drop table #tmpOrngAppData
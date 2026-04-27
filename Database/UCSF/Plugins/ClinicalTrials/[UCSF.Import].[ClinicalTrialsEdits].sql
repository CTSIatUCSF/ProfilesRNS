
/****** Object:  Table [UCSF.Import].[ClinicalTrialsEdits]    Script Date: 4/3/2026 9:08:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE SCHEMA [UCSF.Import]
GO

CREATE TABLE [UCSF.Import].[ClinicalTrialsEdits](
	[NodeID] [bigint] NOT NULL,
	[Add] [nvarchar](500) NULL,
	[Remove] [nvarchar](500) NULL,
	[CreatedDT] [datetime] NULL,
	[UpdatedDT] [datetime] NULL,
 CONSTRAINT [PK__AppData] PRIMARY KEY CLUSTERED 
(
	[NodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [UCSF.Import].[ClinicalTrialsEdits] ADD  CONSTRAINT [DF_ucsf_impport_clinicaltrialsedits_createdDT]  DEFAULT (getdate()) FOR [CreatedDT]
GO

ALTER TABLE [UCSF.Import].[ClinicalTrialsEdits] ADD  CONSTRAINT [DF_ucsf_impport_clinicaltrialsedits_updatedDT]  DEFAULT (getdate()) FOR [UpdatedDT]
GO

ALTER TABLE [UCSF.Import].[ClinicalTrialsEdits]  WITH CHECK ADD  CONSTRAINT [FK_ucsf_import_clinicaltrialsedits_node] FOREIGN KEY([NodeID])
REFERENCES [RDF.].[Node] ([NodeID])
GO

ALTER TABLE [UCSF.Import].[ClinicalTrialsEdits] CHECK CONSTRAINT [FK_ucsf_import_clinicaltrialsedits_node]
GO

ALTER TABLE [UCSF.Import].[ClinicalTrialsEdits]  WITH CHECK ADD  CONSTRAINT [FK_ucsf_impport_clinicaltrialsedits_node] FOREIGN KEY([NodeID])
REFERENCES [RDF.].[Node] ([NodeID])
GO

ALTER TABLE [UCSF.Import].[ClinicalTrialsEdits] CHECK CONSTRAINT [FK_ucsf_impport_clinicaltrialsedits_node]
GO



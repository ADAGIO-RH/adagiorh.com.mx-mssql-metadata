USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AzureCognitiveServices].[tblPersonsGroups](
	[PersonGroupId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TotalPersons] [int] NULL,
	[CreationTime] [datetime] NULL,
 CONSTRAINT [Pk_AzureCognitiveServicesTblPersonsGroups_PersonGroupId] PRIMARY KEY CLUSTERED 
(
	[PersonGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [AzureCognitiveServices].[tblPersonsGroups] ADD  CONSTRAINT [D_AzureCognitiveServicesTblPersonsGroups_TotalPersons]  DEFAULT ((0)) FOR [TotalPersons]
GO
ALTER TABLE [AzureCognitiveServices].[tblPersonsGroups] ADD  CONSTRAINT [D_AzureCognitiveServicesTblPersonsGroups_CreationTime]  DEFAULT (getdate()) FOR [CreationTime]
GO

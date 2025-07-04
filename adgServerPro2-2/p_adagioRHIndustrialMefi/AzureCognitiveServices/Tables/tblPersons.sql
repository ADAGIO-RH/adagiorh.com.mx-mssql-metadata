USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AzureCognitiveServices].[tblPersons](
	[PersonId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PersonGroupId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[UserData] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpleado] [int] NOT NULL,
 CONSTRAINT [Pk_AzureCognitiveServicesTblPersons_PersonId] PRIMARY KEY CLUSTERED 
(
	[PersonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [AzureCognitiveServices].[tblPersons]  WITH CHECK ADD  CONSTRAINT [Fk_AzureCognitiveServicesTblPersons_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [AzureCognitiveServices].[tblPersons] CHECK CONSTRAINT [Fk_AzureCognitiveServicesTblPersons_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [AzureCognitiveServices].[tblPersons]  WITH CHECK ADD  CONSTRAINT [Fk_AzureCognitiveServicesTblPersons_TblPersonsGroups_PersonGroupId] FOREIGN KEY([PersonGroupId])
REFERENCES [AzureCognitiveServices].[tblPersonsGroups] ([PersonGroupId])
ON DELETE CASCADE
GO
ALTER TABLE [AzureCognitiveServices].[tblPersons] CHECK CONSTRAINT [Fk_AzureCognitiveServicesTblPersons_TblPersonsGroups_PersonGroupId]
GO

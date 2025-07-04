USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [AzureCognitiveServices].[tblPersonsFaces](
	[PersonFaceId] [int] IDENTITY(1,1) NOT NULL,
	[PersonId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FaceId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaHoraCreacion] [datetime] NULL,
 CONSTRAINT [Pk_AzureCognitiveServicesTblPersonsFaces_PersonFaceId] PRIMARY KEY CLUSTERED 
(
	[PersonFaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [AzureCognitiveServices].[tblPersonsFaces] ADD  CONSTRAINT [D_AzureCognitiveServicesTblPersonsFaces_FechaHoraCreacion]  DEFAULT (getdate()) FOR [FechaHoraCreacion]
GO
ALTER TABLE [AzureCognitiveServices].[tblPersonsFaces]  WITH CHECK ADD  CONSTRAINT [Fk_AzureCognitiveServicesTblPersons_AzureCognitiveServicesTblPersonsFaces_PersonId] FOREIGN KEY([PersonId])
REFERENCES [AzureCognitiveServices].[tblPersons] ([PersonId])
ON DELETE CASCADE
GO
ALTER TABLE [AzureCognitiveServices].[tblPersonsFaces] CHECK CONSTRAINT [Fk_AzureCognitiveServicesTblPersons_AzureCognitiveServicesTblPersonsFaces_PersonId]
GO

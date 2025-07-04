USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatInputsTypes](
	[IDInputType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoDato] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ConfiguracionSizeInput] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_AppTblCatInputsTypes_IDInputType] PRIMARY KEY CLUSTERED 
(
	[IDInputType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatInputsTypes]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatInputsTypes_AppTblCatTiposDatos_TipoDato] FOREIGN KEY([TipoDato])
REFERENCES [App].[tblCatTiposDatos] ([TipoDato])
GO
ALTER TABLE [App].[tblCatInputsTypes] CHECK CONSTRAINT [Fk_AppTblCatInputsTypes_AppTblCatTiposDatos_TipoDato]
GO
ALTER TABLE [App].[tblCatInputsTypes]  WITH CHECK ADD  CONSTRAINT [Chk_AppTblCatInputsTypes_ConfiguracionSizeInput] CHECK  ((isjson([ConfiguracionSizeInput])>(0)))
GO
ALTER TABLE [App].[tblCatInputsTypes] CHECK CONSTRAINT [Chk_AppTblCatInputsTypes_ConfiguracionSizeInput]
GO
ALTER TABLE [App].[tblCatInputsTypes]  WITH CHECK ADD  CONSTRAINT [Chk_AppTblCatInputsTypes_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [App].[tblCatInputsTypes] CHECK CONSTRAINT [Chk_AppTblCatInputsTypes_Traduccion]
GO

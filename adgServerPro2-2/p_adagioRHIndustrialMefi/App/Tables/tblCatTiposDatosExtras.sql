USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatTiposDatosExtras](
	[IDTipoDatoExtra] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [Pk_AppTblCatTiposDatosExtras_IDTipoDatoExtra] PRIMARY KEY CLUSTERED 
(
	[IDTipoDatoExtra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatTiposDatosExtras]  WITH CHECK ADD  CONSTRAINT [Chk_AppTblCatTiposDatosExtras_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [App].[tblCatTiposDatosExtras] CHECK CONSTRAINT [Chk_AppTblCatTiposDatosExtras_Traduccion]
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatTiposDatos](
	[TipoDato] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Primario] [bit] NULL,
	[Descripcion] [App].[MDDescription] NULL,
 CONSTRAINT [Pk_AppTblCatTiposDatos_TipoDato] PRIMARY KEY CLUSTERED 
(
	[TipoDato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatTiposDatos] ADD  CONSTRAINT [D_AppTblCatTiposDatos_Primario]  DEFAULT ((0)) FOR [Primario]
GO

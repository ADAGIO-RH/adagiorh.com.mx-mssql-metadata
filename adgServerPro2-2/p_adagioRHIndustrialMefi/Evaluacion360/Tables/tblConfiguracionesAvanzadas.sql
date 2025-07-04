USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblConfiguracionesAvanzadas](
	[IDConfiguracionAvanzada] [int] NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoDato] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTemplate] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Activa] [bit] NULL,
	[Info] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360TblConfiguracionesAvanzadas_IDConfiguracionAvanzada] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionAvanzada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionesAvanzadas] ADD  DEFAULT ((1)) FOR [Activa]
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionesAvanzadas]  WITH CHECK ADD  CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_AppTblCatTiposDatos_TipoDato] FOREIGN KEY([TipoDato])
REFERENCES [App].[tblCatTiposDatos] ([TipoDato])
GO
ALTER TABLE [Evaluacion360].[tblConfiguracionesAvanzadas] CHECK CONSTRAINT [Fk_Evaluacion360TblConfiguracionesAvanzadas_AppTblCatTiposDatos_TipoDato]
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblConfiguracionesGenerales](
	[IDConfiguracion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Valor] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoValor] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoConfiguracionGeneral] [int] NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
PRIMARY KEY CLUSTERED 
(
	[IDConfiguracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblConfiguracionesGenerales]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblConfiguracionesGenerales_IDTipoConfiguracionGeneral] FOREIGN KEY([IDTipoConfiguracionGeneral])
REFERENCES [App].[tblTipoConfiguracionGeneral] ([IDTipoConfiguracionGeneral])
GO
ALTER TABLE [App].[tblConfiguracionesGenerales] CHECK CONSTRAINT [Fk_AppTblConfiguracionesGenerales_IDTipoConfiguracionGeneral]
GO

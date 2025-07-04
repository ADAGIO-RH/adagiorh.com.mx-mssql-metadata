USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblIdiomas](
	[IDIdioma] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Idioma] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[SQL] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [PK_tblIdiomas_IDIdioma] PRIMARY KEY CLUSTERED 
(
	[IDIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblIdiomas] ADD  CONSTRAINT [D_AppTblIdiomas_Orden]  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [App].[tblIdiomas] ADD  CONSTRAINT [D_AppTblIdiomas_Activo]  DEFAULT ((1)) FOR [Activo]
GO

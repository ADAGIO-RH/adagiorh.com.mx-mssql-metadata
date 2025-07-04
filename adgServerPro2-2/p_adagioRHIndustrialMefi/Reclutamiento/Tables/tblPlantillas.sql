USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblPlantillas](
	[IDPlantilla] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Contenido] [text] COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Asunto] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Idioma] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_Reclutamiento.tblPlantillas] PRIMARY KEY CLUSTERED 
(
	[IDPlantilla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblPlantillas] ADD  DEFAULT ('es-MX') FOR [Idioma]
GO

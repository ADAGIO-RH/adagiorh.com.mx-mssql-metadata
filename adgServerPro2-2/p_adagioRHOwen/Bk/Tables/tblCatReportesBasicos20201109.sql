USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatReportesBasicos20201109](
	[IDReporteBasico] [int] NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreReporte] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfiguracionFiltros] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Grupos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreProcedure] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Personalizado] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatAplicaciones02nov2023](
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[Icon] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Url] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TraduccionCustom] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SoloEmpleados] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatIncidencias_2024_08_19](
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EsAusentismo] [bit] NOT NULL,
	[GoceSueldo] [bit] NOT NULL,
	[PermiteChecar] [bit] NOT NULL,
	[AfectaSUA] [bit] NOT NULL,
	[TiempoIncidencia] [bit] NOT NULL,
	[Color] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Autorizar] [bit] NOT NULL,
	[GenerarIncidencias] [bit] NULL,
	[Intranet] [bit] NULL,
	[AdministrarSaldos] [bit] NOT NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ReportePapeleta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreProcedure] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

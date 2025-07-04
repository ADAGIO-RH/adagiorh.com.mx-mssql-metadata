USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblCatIncidencias](
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
	[NombreProcedure] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_AsistenciaTblCatIncidencias_IDIncidencia] PRIMARY KEY CLUSTERED 
(
	[IDIncidencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [DF_AsistenciaTblCatIncidencias_EsAusentismo]  DEFAULT ((0)) FOR [EsAusentismo]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [DF_AsistenciaTblCatIncidencias_GoceSueldo]  DEFAULT ((0)) FOR [GoceSueldo]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [DF_AsistenciaTblCatIncidencias_PermiteChecar]  DEFAULT ((0)) FOR [PermiteChecar]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [DF_AsistenciaTblCatIncidencias_AfectaSUA]  DEFAULT ((0)) FOR [AfectaSUA]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [D_AsistenciatblCatIncidencias_TiempoIncidencia]  DEFAULT ((0)) FOR [TiempoIncidencia]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [DF_AsistenciaTempCatIncidencias_Autorizar]  DEFAULT ((0)) FOR [Autorizar]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  CONSTRAINT [D_AsistenciaTblCatIncidencias_GenerarIncidencias]  DEFAULT ((0)) FOR [GenerarIncidencias]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] ADD  DEFAULT ((0)) FOR [Intranet]
GO
ALTER TABLE [Asistencia].[tblCatIncidencias]  WITH CHECK ADD  CONSTRAINT [NoSpaces_AsistenciaTblCatIncidencias_IDIncidencia] CHECK  ((NOT [IDIncidencia] like '% %'))
GO
ALTER TABLE [Asistencia].[tblCatIncidencias] CHECK CONSTRAINT [NoSpaces_AsistenciaTblCatIncidencias_IDIncidencia]
GO

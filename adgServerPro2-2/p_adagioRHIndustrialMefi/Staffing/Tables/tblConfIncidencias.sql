USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Staffing].[tblConfIncidencias](
	[IDConf] [int] IDENTITY(1,1) NOT NULL,
	[IDIncidencia] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[AliasColumna] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [Pk_StaffingtblConfIncidencia_IDConf] PRIMARY KEY CLUSTERED 
(
	[IDConf] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Staffing].[tblConfIncidencias]  WITH CHECK ADD  CONSTRAINT [FK_StaffingtblConfIncidencias_AsistenciatblCatIncidencias_IDIncidencia] FOREIGN KEY([IDIncidencia])
REFERENCES [Asistencia].[tblCatIncidencias] ([IDIncidencia])
ON DELETE CASCADE
GO
ALTER TABLE [Staffing].[tblConfIncidencias] CHECK CONSTRAINT [FK_StaffingtblConfIncidencias_AsistenciatblCatIncidencias_IDIncidencia]
GO

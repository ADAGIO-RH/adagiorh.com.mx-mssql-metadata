USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblExperienciaLaboral](
	[IDExperienciaLaboral] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[NombreEmpresa] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Cargo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Descripcion] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Logros] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Proyectos] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Habilidades] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPais] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[TrabajoActual] [bit] NULL,
	[IDTipoTrabajo] [int] NULL,
	[IDModalidadTrabajo] [int] NULL,
 CONSTRAINT [PK_ReclutamientoExperienciaLaboral_tblExperienciaLaboral] PRIMARY KEY CLUSTERED 
(
	[IDExperienciaLaboral] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

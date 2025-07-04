USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblProyectosFinalizados](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[NombreProyecto] [App].[MDName] NULL,
	[DescripcionProyecto] [App].[MDDescription] NULL,
	[FechaCreacionProyecto] [datetime] NULL,
	[FechaInicioProyecto] [date] NULL,
	[FechaFinProyecto] [date] NULL,
	[NombreContactoProyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailContactoProyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEditor] [int] NULL,
	[NombreEditor] [App].[MDName] NULL,
	[BotonResultadoEditor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ListaEvaluadores] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailValid] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360tblProyectosFinalizados_IDProyectoFinalizado] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

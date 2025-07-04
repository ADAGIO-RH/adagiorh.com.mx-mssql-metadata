USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblProyectosClonados](
	[IDClon] [int] IDENTITY(1,1) NOT NULL,
	[IDProyectoOriginal] [int] NOT NULL,
	[NombreProyectoOriginal] [App].[MDName] NULL,
	[FechaInicioProyectoOriginal] [date] NULL,
	[FechaFinProyectoOriginal] [date] NULL,
	[IDProyectoClon] [int] NOT NULL,
	[NombreProyectoClon] [App].[MDName] NULL,
	[FechaCreacionClon] [date] NULL,
	[NombreContactoProyectoClon] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailContactoProyectoClon] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEditor] [int] NULL,
	[NombreEditor] [App].[MDName] NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailValid] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360tblProyectosClonados_IDClon] PRIMARY KEY CLUSTERED 
(
	[IDClon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

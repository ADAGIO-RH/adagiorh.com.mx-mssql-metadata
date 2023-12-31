USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblPreguntas5To4_2](
	[IDProyecto] [int] NOT NULL,
	[Proyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDGrupo] [int] NOT NULL,
	[IDTipoGrupo] [int] NOT NULL,
	[Grupo] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[ClaveEvaluado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Evaluado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoDepartamento] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Departamento] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoSucursal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sucursal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoPuesto] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Puesto] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoNivel] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nivel] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClaveEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Evaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoDepartamentoEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DepartamentoEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoSucursalEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SucursalEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoPuestoEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PuestoEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoNivelEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NivelEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[GeneroEvaluador] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Antiguedad] [int] NULL,
	[FechaNacimiento] [date] NULL,
	[TotalPreguntas] [decimal](10, 1) NOT NULL,
	[MaximaCalificacionPosible] [decimal](10, 1) NOT NULL,
	[CalificacionObtenida] [decimal](10, 1) NOT NULL,
	[CalificacionMinimaObtenida] [decimal](10, 1) NOT NULL,
	[CalificacionMaxinaObtenida] [decimal](10, 1) NOT NULL,
	[Promedio] [decimal](10, 2) NOT NULL,
	[Porcentaje] [decimal](10, 2) NOT NULL,
	[IDPregunta] [int] NOT NULL,
	[IDTipoPregunta] [int] NOT NULL,
	[Pregunta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Respuesta] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorFinal] [decimal](18, 2) NOT NULL,
	[Indicador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

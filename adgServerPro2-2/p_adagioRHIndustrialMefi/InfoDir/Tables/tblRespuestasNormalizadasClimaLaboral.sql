USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblRespuestasNormalizadasClimaLaboral](
	[FechaNormalizacion] [date] NULL,
	[IDProyecto] [int] NULL,
	[IDGrupo] [int] NULL,
	[IDTipoGrupo] [int] NULL,
	[IDTipoPreguntaGrupo] [int] NULL,
	[IDEvaluacionEmpleado] [int] NULL,
	[IDEmpleado] [int] NULL,
	[FechaNacimiento] [date] NULL,
	[TotalPreguntas] [decimal](18, 2) NULL,
	[MaximaCalificacionPosible] [decimal](18, 2) NULL,
	[CalificacionObtenida] [decimal](18, 2) NULL,
	[CalificacionMinimaObtenida] [decimal](18, 2) NULL,
	[CalificacionMaxinaObtenida] [decimal](18, 2) NULL,
	[Promedio] [decimal](10, 2) NULL,
	[Porcentaje] [decimal](10, 2) NULL,
	[IDPregunta] [int] NULL,
	[Respuesta] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorFinal] [decimal](18, 2) NULL,
	[IDIndicador] [int] NULL,
	[IDGenero] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Antiguedad] [int] NULL,
	[IDRango] [int] NULL,
	[IDGeneracion] [int] NULL,
	[IDCliente] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[IDRegPatronal] [int] NULL,
	[IDCentroCosto] [int] NULL,
	[IDDepartamento] [int] NULL,
	[IDArea] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDTipoPrestacion] [int] NULL,
	[IDSucursal] [int] NULL,
	[IDDivision] [int] NULL,
	[IDRegion] [int] NULL,
	[IDClasificacionCorporativa] [int] NULL,
	[IDNivelEmpresarial] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

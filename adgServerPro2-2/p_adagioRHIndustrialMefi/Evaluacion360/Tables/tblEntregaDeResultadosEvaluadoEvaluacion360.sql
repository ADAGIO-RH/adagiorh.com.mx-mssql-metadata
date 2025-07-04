USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacion360](
	[IDEntregaDeResultado] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[NombreProyecto] [App].[MDName] NULL,
	[DescripcionProyecto] [App].[MDDescription] NULL,
	[FechaCreacionProyecto] [datetime] NULL,
	[FechaInicioProyecto] [date] NULL,
	[FechaFinProyecto] [date] NULL,
	[NombreContactoProyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailContactoProyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEvaluado] [int] NOT NULL,
	[ClaveEvaluado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RFCEvaluado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURPEvaluado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMSSEvaluado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreEvaluado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PaternoEvaluado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaternoEvaluado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRECOMPLETOEvaluado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LocalidadNacimientoEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MunicipioNacimientoEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EstadoNacimientoEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PaisNacimientoEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimientoEvaluado] [date] NULL,
	[EstadoCivilEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SexoEvaluado] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EscolaridadEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionEscolaridadEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[InstitucionEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ProbatorioEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIngresoEvaluado] [date] NULL,
	[FechaAntiguedadEvaluado] [date] NULL,
	[JornadaLaboralEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoRegimenEvaluado] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DepartamentoEvaluado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SucursalEvaluado] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PuestoEvaluado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClienteEvaluado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmpresaEvaluado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CentroCostoEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AreaEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DivisionEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegionEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClasificacionCorporativaEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegPatronalEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoNominaEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RazonSocialEvaluado] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AforeEvaluado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIniContratoEvaluado] [date] NULL,
	[FechaFinContratoEvaluado] [date] NULL,
	[TiposPrestacionEvaluado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoTrabajadorEmpleadoEvaluado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDAdgFile] [int] NOT NULL,
	[LinkDescarga] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailValid] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EnviarResultadoAColaborador] [bit] NOT NULL,
 CONSTRAINT [Pk_Evaluacion360tblEntregaDeResultadosEvaluacion360_IDEntregaDeResultado] PRIMARY KEY CLUSTERED 
(
	[IDEntregaDeResultado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

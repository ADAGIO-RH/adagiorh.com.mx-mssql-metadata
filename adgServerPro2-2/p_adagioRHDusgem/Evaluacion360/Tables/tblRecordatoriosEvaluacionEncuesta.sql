USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Evaluacion360].[tblRecordatoriosEvaluacionEncuesta](
	[IDRecordatorio] [int] IDENTITY(1,1) NOT NULL,
	[IDProyecto] [int] NOT NULL,
	[IDEvaluacionEmpleado] [int] NOT NULL,
	[NombreProyecto] [App].[MDName] NULL,
	[DescripcionProyecto] [App].[MDDescription] NULL,
	[FechaCreacionProyecto] [datetime] NULL,
	[FechaInicioProyecto] [date] NULL,
	[FechaFinProyecto] [date] NULL,
	[NombreContactoProyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmailContactoProyecto] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEvaluador] [int] NOT NULL,
	[ClaveEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RFCEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURPEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMSSEvaluador] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PaternoEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaternoEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRECOMPLETOEvaluador] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LocalidadNacimientoEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MunicipioNacimientoEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EstadoNacimientoEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PaisNacimientoEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimientoEvaluador] [date] NULL,
	[EstadoCivilEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SexoEvaluador] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EscolaridadEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionEscolaridadEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[InstitucionEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ProbatorioEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIngresoEvaluador] [date] NULL,
	[FechaAntiguedadEvaluador] [date] NULL,
	[JornadaLaboralEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoRegimenEvaluador] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DepartamentoEvaluador] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SucursalEvaluador] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PuestoEvaluador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClienteEvaluador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EmpresaEvaluador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CentroCostoEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AreaEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DivisionEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegionEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ClasificacionCorporativaEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegPatronalEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoNominaEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RazonSocialEvaluador] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AforeEvaluador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIniContratoEvaluador] [date] NULL,
	[FechaFinContratoEvaluador] [date] NULL,
	[TiposPrestacionEvaluador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoTrabajadorEmpleadoEvaluador] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Evaluacion360tblRecordatoriosEvaluacionEncuesta_IDRecordatorio] PRIMARY KEY CLUSTERED 
(
	[IDRecordatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

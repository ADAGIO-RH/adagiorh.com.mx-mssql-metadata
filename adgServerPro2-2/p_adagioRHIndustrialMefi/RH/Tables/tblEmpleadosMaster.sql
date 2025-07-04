USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEmpleadosMaster](
	[IDEmpleado] [int] NULL,
	[ClaveEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NOMBRECOMPLETO] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDLocalidadNacimiento] [int] NULL,
	[LocalidadNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMunicipioNacimiento] [int] NULL,
	[MunicipioNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstadoNacimiento] [int] NULL,
	[EstadoNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPaisNacimiento] [int] NULL,
	[PaisNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaNacimiento] [date] NULL,
	[IDEstadoCiviL] [int] NULL,
	[EstadoCivil] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sexo] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEscolaridad] [int] NULL,
	[Escolaridad] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionEscolaridad] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDInstitucion] [int] NULL,
	[Institucion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDProbatorio] [int] NULL,
	[Probatorio] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaPrimerIngreso] [date] NULL,
	[FechaIngreso] [date] NULL,
	[FechaAntiguedad] [date] NULL,
	[Sindicalizado] [bit] NULL,
	[IDJornadaLaboral] [int] NULL,
	[JornadaLaboral] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UMF] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaContable] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoRegimen] [int] NULL,
	[TipoRegimen] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPreferencia] [int] NULL,
	[IDDepartamento] [int] NULL,
	[Departamento] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDSucursal] [int] NULL,
	[Sucursal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPuesto] [int] NULL,
	[Puesto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCliente] [int] NULL,
	[Cliente] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEmpresa] [int] NULL,
	[Empresa] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCentroCosto] [int] NULL,
	[CentroCosto] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDArea] [int] NULL,
	[Area] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDDivision] [int] NULL,
	[Division] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegion] [int] NULL,
	[Region] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDClasificacionCorporativa] [int] NULL,
	[ClasificacionCorporativa] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegPatronal] [int] NULL,
	[RegPatronal] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoNomina] [int] NULL,
	[TipoNomina] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[IDTipoPrestacion] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[RazonSocial] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDAfore] [int] NULL,
	[Afore] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Vigente] [bit] NULL,
	[RowNumber] [int] NULL,
	[ClaveNombreCompleto] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PermiteChecar] [bit] NULL,
	[RequiereChecar] [bit] NULL,
	[PagarTiempoExtra] [bit] NULL,
	[PagarPrimaDominical] [bit] NULL,
	[PagarDescansoLaborado] [bit] NULL,
	[PagarFestivoLaborado] [bit] NULL,
	[IDDocumento] [int] NULL,
	[Documento] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoContrato] [int] NULL,
	[TipoContrato] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaIniContrato] [date] NULL,
	[FechaFinContrato] [date] NULL,
	[TiposPrestacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[tipoTrabajadorEmpleado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [U_RHTblEmpleadosMaster_ClaveEmpleado] UNIQUE NONCLUSTERED 
(
	[ClaveNombreCompleto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHTblEmpleadosMaster_VigenteWithInclude] ON [RH].[tblEmpleadosMaster]
(
	[Vigente] ASC
)
INCLUDE([IDEmpleado],[ClaveEmpleado],[Nombre],[SegundoNombre],[Paterno],[Materno],[NOMBRECOMPLETO],[IDDepartamento],[IDSucursal],[IDPuesto],[IDCliente],[IDEmpresa],[IDCentroCosto],[IDArea],[IDDivision],[IDRegion],[IDClasificacionCorporativa],[IDRegPatronal],[IDTipoNomina],[IDTipoPrestacion],[IDTipoContrato]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_RHtblEmpleadosMaster_ClaveEmpleado] ON [RH].[tblEmpleadosMaster]
(
	[ClaveEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_RHtblEmpleadosMaster_ClaveNombreCompleto] ON [RH].[tblEmpleadosMaster]
(
	[ClaveNombreCompleto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RHtblEmpleadosMaster_IDEmpleado] ON [RH].[tblEmpleadosMaster]
(
	[IDEmpleado] ASC
)
INCLUDE([ClaveEmpleado],[RFC],[CURP],[IMSS],[Nombre],[SegundoNombre],[Paterno],[Materno],[NOMBRECOMPLETO],[IDLocalidadNacimiento],[LocalidadNacimiento],[IDMunicipioNacimiento],[MunicipioNacimiento],[IDEstadoNacimiento],[EstadoNacimiento],[IDPaisNacimiento],[PaisNacimiento],[FechaNacimiento],[IDEstadoCiviL],[EstadoCivil],[Sexo],[IDEscolaridad],[Escolaridad],[DescripcionEscolaridad],[IDInstitucion],[Institucion],[IDProbatorio],[Probatorio],[FechaPrimerIngreso],[FechaIngreso],[FechaAntiguedad],[Sindicalizado],[IDJornadaLaboral],[JornadaLaboral],[UMF],[CuentaContable],[IDTipoRegimen],[TipoRegimen],[IDPreferencia],[IDDepartamento],[Departamento],[IDSucursal],[Sucursal],[IDPuesto],[Puesto],[IDCliente],[Cliente],[IDEmpresa],[Empresa],[IDCentroCosto],[CentroCosto],[IDArea],[Area],[IDDivision],[Division],[IDRegion],[Region],[IDClasificacionCorporativa],[ClasificacionCorporativa],[IDRegPatronal],[RegPatronal],[IDTipoNomina],[TipoNomina],[SalarioDiario],[SalarioDiarioReal],[SalarioIntegrado],[SalarioVariable],[IDTipoPrestacion],[IDRazonSocial],[RazonSocial],[IDAfore],[Afore],[Vigente],[RowNumber],[ClaveNombreCompleto],[PermiteChecar],[RequiereChecar],[PagarTiempoExtra],[PagarPrimaDominical],[PagarDescansoLaborado],[PagarFestivoLaborado],[IDDocumento],[Documento],[IDTipoContrato],[TipoContrato],[FechaIniContrato],[FechaFinContrato],[TiposPrestacion],[tipoTrabajadorEmpleado]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

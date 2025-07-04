USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlBonosObjetivos](
	[IDControlBonosObjetivos] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDTipoNomina] [int] NOT NULL,
	[FechaReferencia] [date] NOT NULL,
	[FechaInformacionColaboradores] [date] NOT NULL,
	[DiasCriterioMes] [decimal](18, 2) NOT NULL,
	[DiasAnio] [decimal](18, 2) NOT NULL,
	[AfectarSalarioDiarioReal] [bit] NULL,
	[AplicaMatrizPagoBono] [bit] NOT NULL,
	[DescuentaIncapacidad] [bit] NOT NULL,
	[TiposIncapacidadDescontar] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescuentaAusentismos] [bit] NOT NULL,
	[AusentismosDescontar] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaInicioIncidenciaIncapacidad] [date] NULL,
	[FechaFinIncidenciaIncapacidad] [date] NULL,
	[PesoEvaluacionJefe] [decimal](18, 2) NULL,
	[PesoEvaluacionOtros] [decimal](18, 2) NULL,
	[TopeCumplimientoObjetivos] [decimal](18, 2) NOT NULL,
	[PresupuestoUtilidadBruta] [decimal](18, 2) NOT NULL,
	[ResultadoEjercicio] [decimal](18, 2) NOT NULL,
	[PorcentajeUtilidadMinima] [decimal](18, 4) NOT NULL,
	[TopeFactorUtilidad] [decimal](18, 4) NOT NULL,
	[PresupuestoObjetivosPersonales] [decimal](18, 2) NOT NULL,
	[ResultadoMinimoBono] [decimal](18, 2) NOT NULL,
	[TopeFactorObjetivos] [decimal](18, 2) NOT NULL,
	[Complemento] [decimal](18, 2) NOT NULL,
	[IDConceptoComplemento] [int] NULL,
	[IDPeriodoComplemento] [int] NULL,
	[IDConceptoBono] [int] NULL,
	[IDPeriodoBono] [int] NULL,
	[IDTabuladorNivelSalarialBonosObjetivos] [int] NULL,
	[IDTabuladorRelacionEvaluacionesObjetivos] [int] NULL,
	[FiltrosAsignacionEmpleados] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDReporteBasico] [int] NULL,
	[Aplicado] [bit] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_TblControlBonosObjetivos_IDControlBonosObjetivos] PRIMARY KEY CLUSTERED 
(
	[IDControlBonosObjetivos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] ADD  CONSTRAINT [DF_NominatblControlBonosObjetivos_FechaReferencia]  DEFAULT (getdate()) FOR [FechaReferencia]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] ADD  CONSTRAINT [DF_NominatblControlBonosObjetivos_FechaInformacionColaboradores]  DEFAULT (getdate()) FOR [FechaInformacionColaboradores]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] ADD  CONSTRAINT [DF_NominatblControlBonosObjetivos_AplicaMatrizPagoBono]  DEFAULT ((0)) FOR [AplicaMatrizPagoBono]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] ADD  CONSTRAINT [DF_NominatblControlBonosObjetivos_DescuentaIncapacidad]  DEFAULT ((0)) FOR [DescuentaIncapacidad]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] ADD  CONSTRAINT [DF_NominatblControlBonosObjetivos_DescuentaAusentismos]  DEFAULT ((0)) FOR [DescuentaAusentismos]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] ADD  CONSTRAINT [DF_NominatblControlBonosObjetivos_Aplicado]  DEFAULT ((0)) FOR [Aplicado]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatConceptos_Bono] FOREIGN KEY([IDConceptoBono])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatConceptos_Bono]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatConceptos_Complemento] FOREIGN KEY([IDConceptoComplemento])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatConceptos_Complemento]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatPeriodos_Bono] FOREIGN KEY([IDPeriodoBono])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatPeriodos_Bono]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatPeriodos_Complemento] FOREIGN KEY([IDPeriodoComplemento])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatPeriodos_Complemento]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatTipoNomina] FOREIGN KEY([IDTipoNomina])
REFERENCES [Nomina].[tblCatTipoNomina] ([IDTipoNomina])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblCatTipoNomina]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblTabuladorNivelSalarialBonosObjetivos] FOREIGN KEY([IDTabuladorNivelSalarialBonosObjetivos])
REFERENCES [Nomina].[tblTabuladorNivelSalarialBonosObjetivos] ([IDTabuladorNivelSalarialBonosObjetivos])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblTabuladorNivelSalarialBonosObjetivos]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblTabuladorRelacionEvaluacionesObjetivos] FOREIGN KEY([IDTabuladorRelacionEvaluacionesObjetivos])
REFERENCES [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] ([IDTabuladorRelacionEvaluacionesObjetivos])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivos_NominatblTabuladorRelacionEvaluacionesObjetivos]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlBonosObjetivos_ReportesTblCatReportesBasicos_IDReporteBasico] FOREIGN KEY([IDReporteBasico])
REFERENCES [Reportes].[tblCatReportesBasicos] ([IDReporteBasico])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivos] CHECK CONSTRAINT [FK_NominaTblControlBonosObjetivos_ReportesTblCatReportesBasicos_IDReporteBasico]
GO

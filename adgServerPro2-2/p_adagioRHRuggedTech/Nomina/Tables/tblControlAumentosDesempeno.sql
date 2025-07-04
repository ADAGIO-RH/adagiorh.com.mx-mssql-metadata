USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlAumentosDesempeno](
	[IDControlAumentosDesempeno] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[FechaReferencia] [date] NOT NULL,
	[FechaMovAfiliatorio] [date] NOT NULL,
	[FechaInformacionColaboradores] [date] NOT NULL,
	[IDRazonMovimiento] [int] NULL,
	[FiltrosAsignacionEmpleados] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DiasSueldoMensual] [decimal](18, 4) NOT NULL,
	[TopeCumplimientoObjetivo] [decimal](18, 2) NOT NULL,
	[PesoEvaluacionJefe] [decimal](18, 2) NOT NULL,
	[PesoEvaluacionOtros] [decimal](18, 2) NOT NULL,
	[PesoObjetivos] [decimal](18, 2) NOT NULL,
	[PesoEvaluaciones] [decimal](18, 2) NOT NULL,
	[IDTabuladorDesempeno] [int] NULL,
	[IDTabuladorNivelSalarialAumentosDesempeno] [int] NULL,
	[IDTabuladorResultadoDesempeno] [int] NULL,
	[AfectarSalarioDiarioReal] [bit] NULL,
	[RespetarSalarioVariable] [bit] NULL,
	[MetaIncrementoSalarialGeneral] [decimal](18, 4) NULL,
	[Aplicado] [bit] NULL,
	[IDUsuario] [int] NOT NULL,
	[IDReporteBasico] [int] NULL,
 CONSTRAINT [PK_TblControlAumentosDesempeno_IDControlAumentosDesempeno] PRIMARY KEY CLUSTERED 
(
	[IDControlAumentosDesempeno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] ADD  CONSTRAINT [DF_NominatblControlAumentosDesempeno_FechaReferencia]  DEFAULT (getdate()) FOR [FechaReferencia]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] ADD  CONSTRAINT [DF_NominatblControlAumentosDesempeno_FechaMovAfiliatorio]  DEFAULT (getdate()) FOR [FechaMovAfiliatorio]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] ADD  CONSTRAINT [DF_NominatblControlAumentosDesempeno_FechaInformacionColaboradores]  DEFAULT (getdate()) FOR [FechaInformacionColaboradores]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlAumentosDesempeno_IMSStblCatRazonesMovAfiliatorios_IDRazonMovimiento] FOREIGN KEY([IDRazonMovimiento])
REFERENCES [IMSS].[tblCatRazonesMovAfiliatorios] ([IDRazonMovimiento])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] CHECK CONSTRAINT [FK_NominaTblControlAumentosDesempeno_IMSStblCatRazonesMovAfiliatorios_IDRazonMovimiento]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlAumentosDesempeno_NominatblTabuladorDesempeno_IDTabuladorDesempeno] FOREIGN KEY([IDTabuladorDesempeno])
REFERENCES [Nomina].[tblTabuladorDesempeno] ([IDTabuladorDesempeno])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] CHECK CONSTRAINT [FK_NominatblControlAumentosDesempeno_NominatblTabuladorDesempeno_IDTabuladorDesempeno]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlAumentosDesempeno_NominatblTabuladorNivelSalarialAumentosDesempeno_IDTabuladorNivelSalarialAumentosDesempeno] FOREIGN KEY([IDTabuladorNivelSalarialAumentosDesempeno])
REFERENCES [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno] ([IDTabuladorNivelSalarialAumentosDesempeno])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] CHECK CONSTRAINT [FK_NominatblControlAumentosDesempeno_NominatblTabuladorNivelSalarialAumentosDesempeno_IDTabuladorNivelSalarialAumentosDesempeno]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlAumentosDesempeno_NominatblTabuladorResultadoDesempeno_IDTabuladorResultadoDesempeno] FOREIGN KEY([IDTabuladorResultadoDesempeno])
REFERENCES [Nomina].[tblTabuladorResultadoDesempeno] ([IDTabuladorResultadoDesempeno])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] CHECK CONSTRAINT [FK_NominaTblControlAumentosDesempeno_NominatblTabuladorResultadoDesempeno_IDTabuladorResultadoDesempeno]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblControlAumentosDesempeno_ReportesTblCatReportesBasicos_IDReporteBasico] FOREIGN KEY([IDReporteBasico])
REFERENCES [Reportes].[tblCatReportesBasicos] ([IDReporteBasico])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempeno] CHECK CONSTRAINT [FK_NominaTblControlAumentosDesempeno_ReportesTblCatReportesBasicos_IDReporteBasico]
GO

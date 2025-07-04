USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblReportesEvaluacionesRenovacionContratosImpresas](
	[IDReporteEvaluacionRenovacionContratoImpresa] [int] IDENTITY(1,1) NOT NULL,
	[IDReporteBasico] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_RHTblReportesEvaluacionesRenovacionContratosImpresas_IDReporteEvaluacionRenovacionContratoImpresa] PRIMARY KEY CLUSTERED 
(
	[IDReporteEvaluacionRenovacionContratoImpresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [D_RHTblReportesEvaluacionesRenovacionContratosImpresas_IDReporteBasico] UNIQUE NONCLUSTERED 
(
	[IDReporteBasico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblReportesEvaluacionesRenovacionContratosImpresas] ADD  CONSTRAINT [D_RHTblReportesEvaluacionesRenovacionContratosImpresas_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [RH].[tblReportesEvaluacionesRenovacionContratosImpresas]  WITH CHECK ADD  CONSTRAINT [Fk_ReportesTblCatReportesBasicos_RHTblReportesEvaluacionesRenovacionContratosImpresas_IDReporteBasico] FOREIGN KEY([IDReporteBasico])
REFERENCES [Reportes].[tblCatReportesBasicos] ([IDReporteBasico])
GO
ALTER TABLE [RH].[tblReportesEvaluacionesRenovacionContratosImpresas] CHECK CONSTRAINT [Fk_ReportesTblCatReportesBasicos_RHTblReportesEvaluacionesRenovacionContratosImpresas_IDReporteBasico]
GO
ALTER TABLE [RH].[tblReportesEvaluacionesRenovacionContratosImpresas]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_RHTblReportesEvaluacionesRenovacionContratosImpresas_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [RH].[tblReportesEvaluacionesRenovacionContratosImpresas] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_RHTblReportesEvaluacionesRenovacionContratosImpresas_IDUsuario]
GO

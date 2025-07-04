USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reportes].[tblConfigReporteRayas](
	[IDConcepto] [int] NOT NULL,
	[Orden] [int] NOT NULL,
	[Impresion] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Reportes].[tblConfigReporteRayas]  WITH CHECK ADD  CONSTRAINT [FK_NominatblcatConceptos_ReportesTblConfigReporteRayas_IDConcepto] FOREIGN KEY([IDConcepto])
REFERENCES [Nomina].[tblCatConceptos] ([IDConcepto])
GO
ALTER TABLE [Reportes].[tblConfigReporteRayas] CHECK CONSTRAINT [FK_NominatblcatConceptos_ReportesTblConfigReporteRayas_IDConcepto]
GO

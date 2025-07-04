USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reportes].[tblCatReportesBasicosSubReportes](
	[IDSubreporte] [int] IDENTITY(1,1) NOT NULL,
	[IDReporteBasico] [int] NULL,
	[Nombre] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ReportestblCatReportesBasicosSubReportes_IDSubreporte] PRIMARY KEY CLUSTERED 
(
	[IDSubreporte] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reportes].[tblCatReportesBasicosSubReportes]  WITH CHECK ADD  CONSTRAINT [FK_ReportestblCatReportesBasicosSubReportes_ReportestblCatReportesBasicos_IDReporteBasico] FOREIGN KEY([IDReporteBasico])
REFERENCES [Reportes].[tblCatReportesBasicos] ([IDReporteBasico])
GO
ALTER TABLE [Reportes].[tblCatReportesBasicosSubReportes] CHECK CONSTRAINT [FK_ReportestblCatReportesBasicosSubReportes_ReportestblCatReportesBasicos_IDReporteBasico]
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reportes].[tblCatReportesBasicos](
	[IDReporteBasico] [int] NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreReporte] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfiguracionFiltros] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Grupos] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreProcedure] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Personalizado] [bit] NULL,
	[Privado] [bit] NULL,
 CONSTRAINT [Pk_ReportesTblCatReportesBasicos_IDReporteBasico] PRIMARY KEY CLUSTERED 
(
	[IDReporteBasico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reportes].[tblCatReportesBasicos] ADD  CONSTRAINT [D_ReportesTblcatReportesBasicos_Personalizado]  DEFAULT ((0)) FOR [Personalizado]
GO
ALTER TABLE [Reportes].[tblCatReportesBasicos] ADD  DEFAULT ((0)) FOR [Privado]
GO
ALTER TABLE [Reportes].[tblCatReportesBasicos]  WITH CHECK ADD  CONSTRAINT [Fk_ReportesTblCatReportesBasicos_AppTblCatAplicaciones_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [Reportes].[tblCatReportesBasicos] CHECK CONSTRAINT [Fk_ReportesTblCatReportesBasicos_AppTblCatAplicaciones_IDAplicacion]
GO

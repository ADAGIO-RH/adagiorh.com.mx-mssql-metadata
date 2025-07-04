USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dashboard].[tblHistorialVigenciasPorFechas](
	[Fecha] [date] NOT NULL,
	[Total] [int] NULL,
 CONSTRAINT [Pk_DashboardtblHistorialVigenciasPorFechas_Fecha] PRIMARY KEY CLUSTERED 
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Dashboard].[tblHistorialVigenciasPorFechas] ADD  CONSTRAINT [D_DashboardtblHistorialVigenciasPorFechas_Total]  DEFAULT ((0)) FOR [Total]
GO

USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlAumentosDesempenoCiclosMedicion](
	[IDControlAumentosDesempenoCiclo] [int] IDENTITY(1,1) NOT NULL,
	[IDControlAumentosDesempeno] [int] NOT NULL,
	[IDCicloMedicionObjetivo] [int] NOT NULL,
 CONSTRAINT [PK_NominatblControlAumentosDesempenoCiclosMedicion_IDControlAumentosDesempenoCiclo] PRIMARY KEY CLUSTERED 
(
	[IDControlAumentosDesempenoCiclo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoCiclosMedicion]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlAumentosDesempenoCiclosMedicion_Evaluacion360tblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo] FOREIGN KEY([IDCicloMedicionObjetivo])
REFERENCES [Evaluacion360].[tblCatCiclosMedicionObjetivos] ([IDCicloMedicionObjetivo])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoCiclosMedicion] CHECK CONSTRAINT [FK_NominatblControlAumentosDesempenoCiclosMedicion_Evaluacion360tblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoCiclosMedicion]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlAumentosDesempenoCiclosMedicion_NominatblControlAumentosDesempeno_IDControlAumentosDesempeno] FOREIGN KEY([IDControlAumentosDesempeno])
REFERENCES [Nomina].[tblControlAumentosDesempeno] ([IDControlAumentosDesempeno])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoCiclosMedicion] CHECK CONSTRAINT [FK_NominatblControlAumentosDesempenoCiclosMedicion_NominatblControlAumentosDesempeno_IDControlAumentosDesempeno]
GO

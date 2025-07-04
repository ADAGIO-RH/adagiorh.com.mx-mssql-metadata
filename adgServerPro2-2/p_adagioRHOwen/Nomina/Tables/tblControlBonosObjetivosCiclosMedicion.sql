USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlBonosObjetivosCiclosMedicion](
	[IDControlBonosObjetivosCiclo] [int] IDENTITY(1,1) NOT NULL,
	[IDControlBonosObjetivos] [int] NOT NULL,
	[IDCicloMedicionObjetivo] [int] NOT NULL,
 CONSTRAINT [PK_NominatblControlBonosObjetivosCiclosMedicion_IDControlBonosObjetivosCiclo] PRIMARY KEY CLUSTERED 
(
	[IDControlBonosObjetivosCiclo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosCiclosMedicion]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivosCiclosMedicion_Evaluacion360tblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo] FOREIGN KEY([IDCicloMedicionObjetivo])
REFERENCES [Evaluacion360].[tblCatCiclosMedicionObjetivos] ([IDCicloMedicionObjetivo])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosCiclosMedicion] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivosCiclosMedicion_Evaluacion360tblCatCiclosMedicionObjetivos_IDCicloMedicionObjetivo]
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosCiclosMedicion]  WITH CHECK ADD  CONSTRAINT [FK_NominatblControlBonosObjetivosCiclosMedicion_NominatblControlBonosObjetivos_IDControlBonosObjetivos] FOREIGN KEY([IDControlBonosObjetivos])
REFERENCES [Nomina].[tblControlBonosObjetivos] ([IDControlBonosObjetivos])
GO
ALTER TABLE [Nomina].[tblControlBonosObjetivosCiclosMedicion] CHECK CONSTRAINT [FK_NominatblControlBonosObjetivosCiclosMedicion_NominatblControlBonosObjetivos_IDControlBonosObjetivos]
GO

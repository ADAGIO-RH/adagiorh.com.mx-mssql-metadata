USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlAumentosDesempenoProyectos](
	[IDControlAumentosDesempenoProyecto] [int] IDENTITY(1,1) NOT NULL,
	[IDControlAumentosDesempeno] [int] NOT NULL,
	[IDProyecto] [int] NOT NULL,
 CONSTRAINT [PK_NominatblControlAumentosDesempenoProyectos_IDControlAumentosDesempenoProyecto] PRIMARY KEY CLUSTERED 
(
	[IDControlAumentosDesempenoProyecto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoProyectos]  WITH NOCHECK ADD  CONSTRAINT [FK_NominatblControlAumentosDesempenoProyecto_Evaluacion360tblCatProyectos_IDProyecto] FOREIGN KEY([IDProyecto])
REFERENCES [Evaluacion360].[tblCatProyectos] ([IDProyecto])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoProyectos] CHECK CONSTRAINT [FK_NominatblControlAumentosDesempenoProyecto_Evaluacion360tblCatProyectos_IDProyecto]
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoProyectos]  WITH NOCHECK ADD  CONSTRAINT [FK_NominatblControlAumentosDesempenoProyecto_NominatblControlAumentosDesempeno_IDControlAumentosDesempeno] FOREIGN KEY([IDControlAumentosDesempeno])
REFERENCES [Nomina].[tblControlAumentosDesempeno] ([IDControlAumentosDesempeno])
GO
ALTER TABLE [Nomina].[tblControlAumentosDesempenoProyectos] CHECK CONSTRAINT [FK_NominatblControlAumentosDesempenoProyecto_NominatblControlAumentosDesempeno_IDControlAumentosDesempeno]
GO

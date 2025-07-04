USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle](
	[IDTabuladorNivelSalarialBonosObjetivosDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTabuladorNivelSalarialBonosObjetivos] [int] NOT NULL,
	[Nivel] [int] NOT NULL,
	[PorcentajeResultadoUtilidad] [decimal](18, 4) NOT NULL,
	[PorcentajeDesempenoEvaluacionPersonal] [decimal](18, 4) NOT NULL,
	[PorcentajeBonoAnual] [decimal](18, 4) NOT NULL,
 CONSTRAINT [Pk_NominatblTabuladorNivelSalarialBonosObjetivosDetalle_IDTabuladorNivelSalarialBonosObjetivosDetalle] PRIMARY KEY CLUSTERED 
(
	[IDTabuladorNivelSalarialBonosObjetivosDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblTabuladorNivelSalarialBonosObjetivosDetalle_IDTabuladorNivelSalarialBonosObjetivos] ON [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]
(
	[IDTabuladorNivelSalarialBonosObjetivos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblTabuladorNivelSalarialBonosObjetivosDetalle_NominatblTabuladorNivelSalarialBonosObjetivos_ID] FOREIGN KEY([IDTabuladorNivelSalarialBonosObjetivos])
REFERENCES [Nomina].[tblTabuladorNivelSalarialBonosObjetivos] ([IDTabuladorNivelSalarialBonosObjetivos])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] CHECK CONSTRAINT [Fk_NominatblTabuladorNivelSalarialBonosObjetivosDetalle_NominatblTabuladorNivelSalarialBonosObjetivos_ID]
GO

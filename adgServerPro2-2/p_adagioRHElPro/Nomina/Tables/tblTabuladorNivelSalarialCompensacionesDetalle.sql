USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle](
	[IDTabuladorNivelSalarialCompensacionesDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTabuladorNivelSalarialCompensaciones] [int] NOT NULL,
	[Nivel] [int] NOT NULL,
	[Minimo] [decimal](18, 4) NOT NULL,
	[Maximo] [decimal](18, 4) NOT NULL,
	[PorcentajeResultadoUtilidad] [decimal](18, 4) NOT NULL,
	[PorcentajeDesempenoEvaluacionPersonal] [decimal](18, 4) NOT NULL,
	[PorcentajeBonoAnual] [decimal](18, 4) NOT NULL,
 CONSTRAINT [Pk_NominatblTabuladorNivelSalarialCompensacionesDetalle_IDTabuladorNivelSalarialCompensacionesDetalle] PRIMARY KEY CLUSTERED 
(
	[IDTabuladorNivelSalarialCompensacionesDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblTabuladorNivelSalarialCompensacionesDetalle_IDTabuladorNivelSalarialCompensaciones] ON [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
(
	[IDTabuladorNivelSalarialCompensaciones] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] ADD  CONSTRAINT [DF_NominatblTabuladorNivelSalarialCompensacionesDetalle_PorcentajeResultadoUtilidad]  DEFAULT ((0)) FOR [PorcentajeResultadoUtilidad]
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] ADD  CONSTRAINT [DF_NominatblTabuladorNivelSalarialCompensacionesDetalle_PorcentajeDesempenoEvaluacionPersonal]  DEFAULT ((0)) FOR [PorcentajeDesempenoEvaluacionPersonal]
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] ADD  CONSTRAINT [DF_NominatblTabuladorNivelSalarialCompensacionesDetalle_PorcentajeBonoAnual]  DEFAULT ((0)) FOR [PorcentajeBonoAnual]
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblTabuladorNivelSalarialCompensacionesDetalle_NominatblTabuladorNivelSalarialCompensaciones_ID] FOREIGN KEY([IDTabuladorNivelSalarialCompensaciones])
REFERENCES [Nomina].[tblTabuladorNivelSalarialCompensaciones] ([IDTabuladorNivelSalarialCompensaciones])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] CHECK CONSTRAINT [Fk_NominatblTabuladorNivelSalarialCompensacionesDetalle_NominatblTabuladorNivelSalarialCompensaciones_ID]
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblDetalleTablasImpuestos](
	[IDDetalleTablaImpuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDTablaImpuesto] [int] NOT NULL,
	[LimiteInferior] [decimal](18, 4) NULL,
	[LimiteSuperior] [decimal](18, 4) NULL,
	[CoutaFija] [decimal](18, 4) NULL,
	[Porcentaje] [decimal](18, 4) NULL,
 CONSTRAINT [Pk_NominatblDetalleTablasImpuestos_IDDetalleTablaImpuesto] PRIMARY KEY CLUSTERED 
(
	[IDDetalleTablaImpuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblDetalleTablasImpuestos_IDTablaImpuesto] ON [Nomina].[tblDetalleTablasImpuestos]
(
	[IDTablaImpuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblDetalleTablasImpuestos]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblDetalleTablasImpuestos] FOREIGN KEY([IDTablaImpuesto])
REFERENCES [Nomina].[tblTablasImpuestos] ([IDTablaImpuesto])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblDetalleTablasImpuestos] CHECK CONSTRAINT [Fk_NominaTblDetalleTablasImpuestos]
GO

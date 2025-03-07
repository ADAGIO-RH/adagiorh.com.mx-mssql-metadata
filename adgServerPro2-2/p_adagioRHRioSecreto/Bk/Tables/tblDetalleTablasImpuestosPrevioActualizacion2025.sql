USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDetalleTablasImpuestosPrevioActualizacion2025](
	[IDDetalleTablaImpuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDTablaImpuesto] [int] NOT NULL,
	[LimiteInferior] [decimal](18, 4) NULL,
	[LimiteSuperior] [decimal](18, 4) NULL,
	[CoutaFija] [decimal](18, 4) NULL,
	[Porcentaje] [decimal](18, 4) NULL
) ON [PRIMARY]
GO

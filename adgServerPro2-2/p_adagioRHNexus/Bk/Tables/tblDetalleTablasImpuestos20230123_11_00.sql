USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDetalleTablasImpuestos20230123_11_00](
	[IDDetalleTablaImpuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDTablaImpuesto] [int] NOT NULL,
	[LimiteInferior] [decimal](18, 4) NULL,
	[LimiteSuperior] [decimal](18, 4) NULL,
	[CoutaFija] [decimal](18, 4) NULL,
	[Porcentaje] [decimal](18, 4) NULL
) ON [PRIMARY]
GO

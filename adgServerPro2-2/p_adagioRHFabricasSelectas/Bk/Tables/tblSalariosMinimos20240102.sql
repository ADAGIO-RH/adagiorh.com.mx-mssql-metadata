USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblSalariosMinimos20240102](
	[IDSalarioMinimo] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[SalarioMinimo] [decimal](18, 2) NULL,
	[SalarioMinimoFronterizo] [decimal](18, 2) NULL,
	[UMA] [decimal](18, 2) NULL,
	[FactorDescuento] [decimal](18, 2) NULL,
	[IDPais] [int] NULL,
	[AjustarUMI] [bit] NULL
) ON [PRIMARY]
GO

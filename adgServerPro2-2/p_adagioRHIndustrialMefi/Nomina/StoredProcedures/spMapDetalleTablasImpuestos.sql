USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Nomina].[spMapDetalleTablasImpuestos](
		@dtDetalleTablaImpuestos [Nomina].[dtDetalleTablasImpuestos]readonly,
		@IDUsuario int
) as

	
		select			
			LimiteInferior,
			LimiteSuperior,
			CoutaFija,
			Porcentaje		
		from @dtDetalleTablaImpuestos
GO

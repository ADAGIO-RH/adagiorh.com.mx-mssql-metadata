USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spUMatrizIncrementoDetalle](
	@IDMatrizIncremento int,
	@ValorNivelProgresion decimal(18,4),
	@ValorNivelAmplitud decimal(18,4),
	@Valor decimal(18,4),
	@IDUsuario int
)
AS
BEGIN

	update Compensaciones.TblMatrizIncrementoDetalle
		set Valor = @Valor / 100.00
	where IDMatrizIncremento = @IDMatrizIncremento
	and ValorNivelProgresion = @ValorNivelProgresion
	and ValorNivelAmplitud = @ValorNivelAmplitud /100.00
	
END
GO

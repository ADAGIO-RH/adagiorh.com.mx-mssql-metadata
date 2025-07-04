USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE App.spUGeneracionRecibos(
	@IDReciboGeneracion int
	,@Generado bit
	,@Recibo varchar(max)
	,@XML varchar(max)
	,@QR varchar(max)
)
AS
BEGIN
	UPDATE Facturacion.tblGeneracionRecibos
		set Generado = @Generado
		,  Recibo = @Recibo
		, [XML] = @XML
		, QR = @QR
		, FechaHoraGeneracion = GETDATE()
	WHERE IDReciboGeneracion = @IDReciboGeneracion
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE App.spBuscarPendientesGeneracionRecibos
AS
BEGIN
	SELECT 
	IDReciboGeneracion
	,IDHistorialEmpleadoPeriodo
	,isnull(IDPeriodo,0) as IDPeriodo
	,isnull(Timbrado,0) as Timbrado
	,Isnull(Generado,0) as Generado
	,Recibo
	,XML
	,QR
	,FechaHoraCreacion
	,FechaHoraGeneracion
	,IDUsuario
	FROM Facturacion.tblGeneracionRecibos
	WHERE ISNULL(Generado,0) = 0
END
GO

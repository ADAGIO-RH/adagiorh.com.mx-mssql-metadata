USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Nomina.spBuscarDetallePrestamo
(
	@IDPrestamo int
)
AS
BEGIN
	SELECT * 
	FROM Nomina.fnPagosPrestamo(@IDPrestamo)
END
GO

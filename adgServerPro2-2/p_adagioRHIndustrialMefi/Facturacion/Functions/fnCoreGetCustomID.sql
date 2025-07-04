USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Facturacion.fnCoreGetCustomID
(
	@IDHistorialEmpleadoPeriodo int
)
returns varchar(100)
BEGIN 
	DECLARE @CustomID Varchar(100), 
			@COUNT int

	SELECT  @Count =  COUNT(*)
		FROM Facturacion.TblTimbrado WITH(NOLOCK)
		WHERE IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo

	RETURN CAST(@IDHistorialEmpleadoPeriodo as Varchar(20)) +'-'+ CAST(ISNULL(@Count,0) as Varchar(80))

END
GO

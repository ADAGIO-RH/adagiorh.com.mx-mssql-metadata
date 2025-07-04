USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC Utilerias.spRedondeaCantidad
(
	 @cantidadARedondear float

)AS
	DECLARE
		@parteDecimal float
BEGIN
	select @parteDecimal = ( @cantidadARedondear - FLOOR ( @cantidadARedondear ) )
	IF ( @parteDecimal < 0.50 ) 
		BEGIN 
			RETURN FLOOR ( @cantidadARedondear );
		END
	ELSE
		BEGIN
			RETURN CEILING ( @cantidadARedondear );
		END
END
GO

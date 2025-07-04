USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Utilerias].[fnArreglarCuentasSAP]
(
	-- Add the parameters for the function here
	 @cadenaCuenta varchar(11)	--201-001-999
	,@posicion int				--001-002-003 
	,@cadenaCambiar varchar(3)	--002
)	RETURNS varchar(11)
AS
BEGIN
	DECLARE
		 @cuentaCorrecta varchar(11)
		,@auxiliar1 varchar(3)
		,@auxiliar2 varchar(3)
		,@auxiliar3 varchar(3)

	SET @auxiliar1 = SUBSTRING (@cadenaCuenta,1,3)
	SET @auxiliar2 = SUBSTRING (@cadenaCuenta,5,3)
	SET @auxiliar3 = SUBSTRING (@cadenaCuenta,9,3)

	SELECT @cuentaCorrecta =	CASE WHEN ( @posicion = 1 ) THEN CONCAT(@cadenaCambiar, '-', @auxiliar2, '-' , @auxiliar3 )
									 WHEN ( @posicion = 2 ) THEN CONCAT(@auxiliar1, '-', @cadenaCambiar, '-' , @auxiliar3 )
									 WHEN ( @posicion = 3 ) THEN CONCAT(@auxiliar1, '-', @auxiliar2, '-' , @cadenaCambiar )
								END
	RETURN @cuentaCorrecta;
END
GO

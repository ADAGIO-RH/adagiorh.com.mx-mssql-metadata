USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Aneudy Abreu
-- Create date: 2023-08-22
-- Description:	
--			Genera claves de empleados. 
--				NO GENERA NUEVAS CLAVES DE EMPLEADOS, solo genera la clave partiendo del número, es decir. 
--				Si la pasamos el 1 nos regresará la clave ADG0001 (esto en función de la configuración del cliente que también la enviamos por parámetros)
-- =============================================
CREATE FUNCTION RH.fnGeneraClaveEmpleado 
(
	-- Add the parameters for the function here
	@Prefijo varchar(10),
	@LongitudNoNomina int, 
	@ID int

)
RETURNS varchar(20)
AS
BEGIN
	RETURN  isnull(@Prefijo,'')+REPLICATE('0', (@LongitudNoNomina - LEN(isnull(@Prefijo,''))  ) - LEN(RTRIM(cast(@ID as varchar)))) + cast(@ID as Varchar)  
END
GO

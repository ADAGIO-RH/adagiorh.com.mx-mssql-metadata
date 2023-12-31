USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [RH].[spBuscarNombreEmpleado]
(
	 @ClaveEmpleado varchar(max)
	
	
)
AS
BEGIN
    
    SELECT COALESCE(Empleado.Paterno,'')+' '+COALESCE(Empleado.Materno,'') +' '+COALESCE(Empleado.Nombre,'')+ CASE WHEN ISNULL(Empleado.SegundoNombre,'') <> '' THEN ' '+COALESCE(Empleado.SegundoNombre,'') ELSE ' ' END  AS NOMBRECOMPLETO        
    FROM RH.TBLEMPLEADOS EMPLEADO
    WHERE ClaveEmpleado=@ClaveEmpleado


END
GO

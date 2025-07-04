USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Buscar datos de Geolocalizacion del colaborador    
** Autor   : Andrea Zainos
** Email   : azainos@adagio.com.mx    
** FechaCreacion : 2024-12-04    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
 
***************************************************************************************************/    
CREATE proc [RH].[spBuscarGeolocalizacionEmpleado] --0, 126

(    
    @IDEmpleadoGeolocalizacion int = 0    
    ,@IDEmpleado int = 0    
)  as    
      
	if exists(select * from [RH].[tblEmpleadoGeolocalizacion] where IDEmpleado = @IDEmpleado)
	    BEGIN
    select     
		ISNULL(IDEmpleadoGeolocalizacion,0) as IDEmpleadoGeolocalizacion,
		ISNULL(IDEmpleado, @IDEmpleado) as IDEmpleado,
		cast(ISNULL(OmitirGeolocalizacion,0) as bit) as OmitirGeolocalizacion
    from [RH].[tblEmpleadoGeolocalizacion]     
    where (IDEmpleadoGeolocalizacion = @IDEmpleadoGeolocalizacion) or     
    (IDEmpleado = @IDEmpleado)  
	END
	ELSE
	BEGIN
		select     
		ISNULL(0,0) as IDEmpleadoGeolocalizacion,
		ISNULL(@IDEmpleado, @IDEmpleado) as IDEmpleado,
		cast(0 as bit) as OmitirGeolocalizacion
	END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar los subordinados de los colaboradores
** Autor   : Javier Peña Fuentes
** Email   : jpena@adagio.com.mx
** FechaCreacion : 2024-08-28
** Paremetros  :                

	
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2024-08-28			Javier Peña	     Se crea el procedimiento para proporcionar informacion a los componentes de busquedaa

***************************************************************************************************/  
CREATE   PROC [RH].[spBuscarSubordinadosWithDetalle](  
	@IDEmpleado int    	
	,@IDUsuario int  
)  
AS  

	SELECT   		
		 je.IDEmpleado                                                                                           AS [IDEmpleado]
		,e.ClaveEmpleado                                                                                         AS [ClaveEmpleado] 
		,e.NOMBRECOMPLETO                                                                                        AS [NombreCompleto]
		,SUBSTRING(COALESCE(e.Nombre, ''), 1, 1)+SUBSTRING(COALESCE(e.Paterno, COALESCE(e.Materno, '')), 1, 1)   AS [Iniciales] 
        ,e.Sucursal                                                                                              AS [Sucursal]
        ,e.Departamento                                                                                          AS [Departamento]		
		,e.Puesto				                                                                                 AS [Puesto]
        ,e.Vigente                                                                                               AS [Vigente]        
	FROM [RH].[tblJefesEmpleados] je  		
		LEFT JOIN [RH].[tblEmpleadosMaster] e on je.IDEmpleado = e.IDEmpleado  		
	WHERE je.IDJefe = @IDEmpleado 
      AND e.Vigente = 1
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Buscar datos de PTU del colaborador    
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-29    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
 
***************************************************************************************************/    
CREATE proc [RH].[spBuscarPTUEmpleado] --0, 126

(    
    @IDEmpleadoPTU int = 0    
    ,@IDEmpleado int = 0    
)  as    
      
	if exists(select * from [RH].[tblEmpleadoPTU] where IDEmpleado = @IDEmpleado)
	    BEGIN
    select     
		ISNULL(IDEmpleadoPTU,0) as IDEmpleadoPTU,
		ISNULL(IDEmpleado, @IDEmpleado) as IDEmpleado,
		cast(ISNULL(PTU,0) as bit) as PTU
    from [RH].[tblEmpleadoPTU]     
    where (IDEmpleadoPTU = @IDEmpleadoPTU) or     
    (IDEmpleado = @IDEmpleado)  
	END
	ELSE
	BEGIN
		select     
		ISNULL(0,0) as IDEmpleadoPTU,
		ISNULL(@IDEmpleado, @IDEmpleado) as IDEmpleado,
		cast(0 as bit) as PTU
	END
GO

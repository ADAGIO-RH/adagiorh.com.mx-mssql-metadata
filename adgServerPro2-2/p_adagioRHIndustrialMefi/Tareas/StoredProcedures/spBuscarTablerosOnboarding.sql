USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ?
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBuscarTablerosOnboarding](    	        
	@IDUsuario int
) as
begin

    
    select 
        IDProcesoOnboarding ,
        NombreProceso,
        IDNuevoEmpleado as  IDEmpleadoNuevo,
        m.NOMBRECOMPLETO as NombreEmpleadoNuevo,
        IDsPlantilla ,
        Terminado    
    from Onboarding.tblProcesosOnboarding  po
    inner join tareas.tblTableroUsuarios  tu on po.IDProcesoOnboarding=tu.IDReferencia and tu.IDTipoTablero=3
    inner join rh.tblEmpleadosMaster m on m.IDEmpleado=po.IDNuevoEmpleado
    where Terminado=0 and tu.IDUsuario=@IDUsuario
      
end
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spImportacionChecadasEmpleados]      
(      
 @dtImportacion [Asistencia].[dtChecadasImportacion] READONLY  
 ,@IDUsuario int    
)      
AS      
BEGIN      
	select 
		ROW_NUMBER()over(Order by em.ClaveEmpleado,Fecha ASC) as RN      
		,isnull(em.IDEmpleado,0) as [IDEmpleado]      
		,E.[ClaveEmpleado]      
		,isnull(em.NOMBRECOMPLETO,'') as [NombreCompleto]     
		,cast(isnull(E.[Fecha],'9999-12-31') as varchar(20))+' '+cast(isnull(E.[Hora],'00:00:00') as varchar(20))  as [Fecha]      
		from @dtImportacion E   
			left join RH.tblEmpleadosMaster em on e.ClaveEmpleado = em.ClaveEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on em.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		WHERE isnull(E.ClaveEmpleado,'') <>''       
END
GO

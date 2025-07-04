USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spImportacionHorariosEmpleados]    
(    
 @dtImportacion [Asistencia].[dtHorariosImportacion] READONLY    
  ,@IDUsuario int    
)    
AS    
BEGIN    
	select 
		ROW_NUMBER()over(Order by e.ClaveEmpleado,FechaInicio ASC) as RN    
		,isnull(em.IDEmpleado,0) as [IDEmpleado]    
		,E.[ClaveEmpleado]    
		,isnull(em.NOMBRECOMPLETO,'') as [NombreCompleto]   
		,isnull((Select TOP 1 IDHorario from Asistencia.tblCatHorarios Where Codigo = E.[Horario]),0) as [IDHorario]   
		,E.Horario as CodigoHorario 
		,isnull((Select TOP 1 Descripcion from Asistencia.tblCatHorarios Where Codigo = E.[Horario]),'') as [Horario]    
		,cast(isnull(E.[FechaInicio],'9999-12-31') as DATE) as [FechaInicio]    
		,cast(isnull(E.[FechaFin],'9999-12-31') as DATE) as [FechaFin]    
	from @dtImportacion E    
		left join RH.tblEmpleadosMaster em on e.ClaveEmpleado = em.ClaveEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on em.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
	WHERE isnull(E.ClaveEmpleado,'') <>''     
END
GO

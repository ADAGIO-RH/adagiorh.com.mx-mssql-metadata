USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spBuscarEmpleadosPorCatFiltroUsuario](      
	@IDCatFiltroUsuario int  
	,@IDUsuario int
) as      
	 SET LANGUAGE 'Spanish';      
      
	 select DFEU.IDDetalleFiltrosEmpleadosUsuarios      
		,DFEU.IDUsuario      
		,DFEU.IDEmpleado      
		,em.ClaveEmpleado      
		,em.NOMBRECOMPLETO      
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,isnull(DFEU.Filtro,'Empleados') as Filtro      
	 from [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] DFEU 
		join [RH].[tblEmpleadosMaster] em on DFEU.IDEmpleado = em.IDEmpleado    
	where DFEU.IDCatFiltroUsuario = @IDCatFiltroUsuario  
	ORDER BY EM.ClaveEmpleado ASC, EM.NOMBRECOMPLETO ASC
GO

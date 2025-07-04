USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Docs].[spBuscarUsuariosPorCatFiltroDocumentos](      
	@IDCatFiltroDocumento int  
	,@IDUsuario int
) as      
	 SET LANGUAGE 'Spanish';      
      
	 select DFEU.IDDetalleFiltrosDocumentosUsuarios      
		,DFEU.IDUsuario      
		,DFEU.IDDocumento      
		,u.Cuenta      
		,coalesce(u.Nombre,'') +' '+coalesce(u.Apellido,'') as NombreCompleto      
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,isnull(DFEU.Filtro,'Empleados') as Filtro      
	 from [Docs].[tblDetalleFiltrosDocumentosUsuarios] DFEU 
		join Seguridad.tblUsuarios u on DFEU.IDUsuario = u.IDUsuario
		left join [RH].[tblEmpleadosMaster] em on u.IDEmpleado = em.IDEmpleado    
	where DFEU.IDCatFiltroDocumento = @IDCatFiltroDocumento  
	ORDER BY u.Cuenta ASC, u.Nombre +' '+ u.Apellido ASC
GO

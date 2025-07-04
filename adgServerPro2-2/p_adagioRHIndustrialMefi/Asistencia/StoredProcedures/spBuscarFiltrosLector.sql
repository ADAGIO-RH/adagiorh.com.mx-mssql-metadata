USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarFiltrosLector](  
	@IDFiltroLector int = 0  
	,@IDLector int = 0   
	,@IDGrupoFiltrosLector int = 0
) as  
	select   
		 fu.IDFiltroLector
		,fu.IDLector  
		,fu.Filtro  
		,fu.ID  
		,fu.Descripcion  
		,fu.IDGrupoFiltrosLector
		,cfu.Nombre as GrupoFiltro
	from [Asistencia].[tblFiltrosLector] fu 
		join [Asistencia].[tblGrupoFiltrosLector] cfu on fu.IDGrupoFiltrosLector = cfu.IDGrupoFiltrosLector
	where (fu.IDFiltroLector = @IDFiltroLector or @IDFiltroLector = 0) 
		and (fu.IDLector = @IDLector or @IDLector = 0)
		and (fu.IDGrupoFiltrosLector = @IDGrupoFiltrosLector or @IDGrupoFiltrosLector = 0)
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarFiltrosUsuarios](  
	@IDFiltrosUsuarios int = 0  
	,@IDUsuario int = 0   
	,@IDCatFiltroUsuario int = 0
) as  
	select   
		 fu.IDFiltrosUsuarios  
		,fu.IDUsuario  
		,fu.Filtro  
		,fu.ID  
		,fu.Descripcion  
		,fu.IDCatFiltroUsuario
		,cfu.Nombre as CatFiltro
	from [Seguridad].[tblFiltrosUsuarios] fu 
		join [Seguridad].[tblcatFiltrosUsuarios] cfu on fu.IDCatFiltroUsuario = cfu.IDCatFiltroUsuario
	where (fu.IDFiltrosUsuarios = @IDFiltrosUsuarios or @IDFiltrosUsuarios = 0) 
		and (fu.IDUsuario = @IDUsuario or @IDUsuario = 0)
		and (fu.IDCatFiltroUsuario = @IDCatFiltroUsuario or @IDCatFiltroUsuario = 0)
GO

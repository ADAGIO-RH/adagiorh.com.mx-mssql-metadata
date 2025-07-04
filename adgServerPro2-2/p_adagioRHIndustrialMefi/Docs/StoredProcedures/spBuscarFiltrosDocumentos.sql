USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spBuscarFiltrosDocumentos](  
	@IDFiltrosDocumentos int = 0  
	,@IDDocumento int = 0   
	,@IDCatFiltroDocumento int = 0
) as  
	select   
		 fu.IDFiltrosDocumentos  
		,fu.IDDocumento  
		,fu.Filtro  
		,fu.ID  
		,fu.Descripcion  
		,fu.IDCatFiltroDocumento
		,cfu.Nombre as CatFiltro
	from [Docs].[tblFiltrosDocumentos] fu 
		join [Docs].[tblCatFiltrosDocumentos] cfu on fu.IDCatFiltroDocumento = cfu.IDCatFiltroDocumento
	where (fu.IDFiltrosDocumentos = @IDFiltrosDocumentos or @IDFiltrosDocumentos = 0) 
		and (fu.IDDocumento = @IDDocumento or @IDDocumento = 0)
		and (fu.IDCatFiltroDocumento = @IDCatFiltroDocumento or @IDCatFiltroDocumento = 0)
GO

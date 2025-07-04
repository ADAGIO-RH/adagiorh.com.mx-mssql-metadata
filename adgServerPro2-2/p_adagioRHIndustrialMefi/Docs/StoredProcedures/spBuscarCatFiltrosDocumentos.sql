USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spBuscarCatFiltrosDocumentos](
	 @IDCatFiltroDocumento int = 0	
	,@IDDocumento int
) as

	select
		 cfu.IDCatFiltroDocumento
		,cfu.Nombre
		,cfu.IDDocumento
		,coalesce(u.Nombre,'') as Documento
		,cfu.IDUsuarioCreo
		,coalesce(uc.Nombre,'')+' '+coalesce(uc.Apellido,'') as UsuarioCreo
		,isnull(cfu.FechaHora,getdate()) as FechaHora
	from Docs.tblCatFiltrosDocumentos cfu
		join Docs.tblCarpetasDocumentos u on cfu.IDDocumento = u.IDItem
		join Seguridad.tblUsuarios uc on cfu.IDUsuarioCreo = uc.IDUsuario
	where (cfu.IDCatFiltroDocumento = @IDCatFiltroDocumento or ISNULL(@IDCatFiltroDocumento,0) = 0)
		and (cfu.IDDocumento = @IDDocumento)
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Seguridad.spBuscarCatFiltrosUsuario(
	 @IDCatFiltroUsuario int = 0	
	,@IDUsuario int
) as

	select
		 cfu.IDCatFiltroUsuario
		,cfu.Nombre
		,cfu.IDUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
		,cfu.IDUsuarioCreo
		,coalesce(uc.Nombre,'')+' '+coalesce(uc.Apellido,'') as UsuarioCreo
		,isnull(cfu.FechaHora,getdate()) as FechaHora
	from Seguridad.tblCatFiltrosUsuarios cfu
		join Seguridad.tblUsuarios u on cfu.IDUsuario = u.IDUsuario
		join Seguridad.tblUsuarios uc on cfu.IDUsuarioCreo = uc.IDUsuario
	where (cfu.IDCatFiltroUsuario = @IDCatFiltroUsuario or ISNULL(@IDCatFiltroUsuario,0) = 0)
		and (cfu.IDUsuario = @IDUsuario)
GO

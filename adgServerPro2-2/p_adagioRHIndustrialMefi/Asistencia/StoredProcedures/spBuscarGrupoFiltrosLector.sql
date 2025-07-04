USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarGrupoFiltrosLector](
	 @IDGrupoFiltrosLector int = 0	
	,@IDLector int
) as

	select
		 cfu.IDGrupoFiltrosLector
		,cfu.Nombre
		,cfu.IDLector
		,L.Lector as Lector
		,cfu.IDUsuarioCreo
		,coalesce(uc.Nombre,'')+' '+coalesce(uc.Apellido,'') as UsuarioCreo
		,isnull(cfu.FechaHora,getdate()) as FechaHora
	from Asistencia.tblGrupoFiltrosLector cfu
		join Asistencia.tblLectores L on cfu.IDLector = L.IDLector
		join Seguridad.tblUsuarios uc on cfu.IDUsuarioCreo = uc.IDUsuario
	where (cfu.IDGrupoFiltrosLector = @IDGrupoFiltrosLector or ISNULL(@IDGrupoFiltrosLector,0) = 0)
		and (cfu.IDLector = @IDLector)
GO

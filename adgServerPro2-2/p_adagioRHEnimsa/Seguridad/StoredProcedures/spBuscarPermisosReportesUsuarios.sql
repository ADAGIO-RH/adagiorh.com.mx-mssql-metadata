USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Seguridad.spBuscarPermisosReportesUsuarios(
	@IDUsuario int	
	,@IDUsuarioLogin int
) as

	select
		 cr.IDItem
		,cr.TipoItem
		,cr.IDCarpeta
		,cr.Nombre
		,cr.FullPath
		,isnull(prp.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
		,isnull(prp.IDUsuario,0) as IDUsuario
		,ISNULL(prp.Acceso,0) as Acceso
	from Reportes.tblCatReportes  cr
		left join Seguridad.tblPermisosReportesUsuarios prp on cr.IDItem = prp.IDItem and prp.IDUsuario = @IDUsuario
GO

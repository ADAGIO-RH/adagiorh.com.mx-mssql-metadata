USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisosReportesUsuarios](
	@IDUsuario int	
	,@IDUsuarioLogin int
) as

	--select
	--	 cr.IDItem
	--	,cr.TipoItem
	--	,cr.IDCarpeta
	--	,cr.Nombre
	--	,cr.FullPath
	--	,isnull(prp.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
	--	,isnull(prp.IDUsuario,0) as IDUsuario
	--	,ISNULL(prp.Acceso,0) as Acceso
	--from Reportes.tblCatReportes  cr
	--	left join Seguridad.tblPermisosReportesUsuarios prp on cr.IDItem = prp.IDItem and prp.IDUsuario = @IDUsuario

	select
		 cr.IDReporteBasico
		,cr.IDAplicacion
		,a.Descripcion as Aplicacion
		,cr.Nombre
		,cr.Descripcion
		,cr.NombreReporte
		,isnull(cr.Personalizado,0) as Personalizado
		,isnull(prp.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
		,isnull(prp.IDUsuario,0) as IDPerfil
		,ISNULL(prp.Acceso,0) as Acceso
	from [Reportes].[tblCatReportesBasicos]  cr
		join [App].[tblCatAplicaciones] a on a.IDAplicacion = cr.IDAplicacion
		left join Seguridad.tblPermisosReportesUsuarios prp on cr.IDReporteBasico = prp.IDReporteBasico and prp.IDUsuario = @IDUsuario
	order by cr.IDAplicacion, cr.Nombre
GO

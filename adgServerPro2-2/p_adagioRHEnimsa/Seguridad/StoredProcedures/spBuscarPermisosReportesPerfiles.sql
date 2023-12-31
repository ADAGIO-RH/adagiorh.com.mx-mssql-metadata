USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Seguridad.spBuscarPermisosReportesPerfiles(
	@IDPerfil int
	,@IDUsuario int	
) as

--declare 
--	@IDPerfil int  = 1
--	,@TipoItem int = 0
--	,@IDUsuario int	= 1


	select
		 cr.IDItem
		,cr.TipoItem
		,cr.IDCarpeta
		,cr.Nombre
		,cr.FullPath
		,isnull(prp.IDPermisoReportePerfil,0) as IDPermisoReportePerfil
		,isnull(prp.IDPerfil,0) as IDPerfil
		,ISNULL(prp.Acceso,0) as Acceso
	from Reportes.tblCatReportes  cr
		left join Seguridad.tblPermisosReportesPerfiles prp on cr.IDItem = prp.IDItem and prp.IDPerfil = @IDPerfil
GO

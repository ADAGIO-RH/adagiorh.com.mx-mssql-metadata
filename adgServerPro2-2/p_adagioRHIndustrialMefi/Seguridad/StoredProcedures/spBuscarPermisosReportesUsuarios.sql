USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisosReportesUsuarios] --22635,1 
(
	@IDUsuario int	
	,@IDUsuarioLogin int
) as
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuarioLogin, 'esmx')

	select
		 cr.IDReporteBasico
		,cr.IDAplicacion
		,JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Aplicacion
		,cr.Nombre
		,cr.Descripcion
		,cr.NombreReporte
		,isnull(cr.Personalizado,0) as Personalizado
		,isnull(pur.IDPermisoReporteUsuario,0) as IDPermisoReporteUsuario
		,isnull(pur.IDUsuario,0) as IDUsuario
		,CAST(ISNULL(pur.Acceso,0) as bit) as Acceso
        ,cast (case when pur.IDPermisoReporteUsuario <> 0 then 1 else 0 end as bit) as PermisoPersonalizado
	from [Reportes].[tblCatReportesBasicos]  cr
		join [App].[tblCatAplicaciones] a on a.IDAplicacion = cr.IDAplicacion
        left join [Seguridad].[vwPermisosUsuariosReportes] pur on cr.IDReporteBasico = pur.IDReporteBasico and pur.IDUsuario = @IDUsuario
	order by isnull(cr.Personalizado, 0)-- cr.IDAplicacion, cr.Nombre
GO

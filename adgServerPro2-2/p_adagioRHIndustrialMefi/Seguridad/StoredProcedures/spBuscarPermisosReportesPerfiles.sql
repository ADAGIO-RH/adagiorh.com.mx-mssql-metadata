USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisosReportesPerfiles](
	@IDPerfil int
	,@IDUsuario int	
) as
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select
		 cr.IDReporteBasico
		,cr.IDAplicacion
		,JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Aplicacion
		,cr.Nombre
		,cr.Descripcion
		,cr.NombreReporte
		,isnull(cr.Personalizado,0) as Personalizado
		,isnull(prp.IDPermisoReportePerfil,0) as IDPermisoReportePerfil
		,isnull(prp.IDPerfil,0) as IDPerfil
		,ISNULL(prp.Acceso,0) as Acceso
	from [Reportes].[tblCatReportesBasicos]  cr
		join [App].[tblCatAplicaciones] a on a.IDAplicacion = cr.IDAplicacion
		left join Seguridad.tblPermisosReportesPerfiles prp on cr.IDReporteBasico = prp.IDReporteBasico and prp.IDPerfil = @IDPerfil
	order by isnull(cr.Personalizado, 0)-- , cr.IDAplicacion, cr.Nombre
GO

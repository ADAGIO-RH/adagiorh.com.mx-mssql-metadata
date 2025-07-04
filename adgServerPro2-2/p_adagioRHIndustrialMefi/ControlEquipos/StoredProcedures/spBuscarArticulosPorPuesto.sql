USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [ControlEquipos].[spBuscarArticulosPorPuesto](
	@IDArticulosPorPuesto int = 0
	,@IDPuesto int	= 0
	,@IDUsuario int
) as

	declare  
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		app.IDArticulosPorPuesto
		,app.IDPuesto
		,p.Codigo+' - '+JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto
		,a.IDTipoArticulo
		,ta.Codigo+' - '+JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoArticulo
		,app.IDArticulo
		,a.Nombre as Articulo
		,ISNULL(app.Cantidad, 1) as Cantidad
		,a.Descripcion as DescripcionArticulo
		,app.FechaHora
	from ControlEquipos.tblArticulosPorPuesto app
		join RH.tblCatPuestos p on p.IDPuesto = app.IDPuesto
		join ControlEquipos.tblArticulos a on a.IDArticulo = app.IDArticulo
		join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
	where (app.IDArticulosPorPuesto = @IDArticulosPorPuesto or isnull(@IDArticulosPorPuesto, 0) = 0)
		and (app.IDPuesto = @IDPuesto or isnull(@IDPuesto, 0) = 0)
GO

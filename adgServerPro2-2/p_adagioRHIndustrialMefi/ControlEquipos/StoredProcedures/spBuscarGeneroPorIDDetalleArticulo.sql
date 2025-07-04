USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarGeneroPorIDDetalleArticulo](
	@IDDetalleArticulo int,
	@IDUsuario int
)
as
begin
	declare @IDIdioma varchar(20)
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select da.IDDetalleArticulo,
		   ISNULL(cast(da.IDGenero as varchar(3)), 'N/A') as IDGenero,
		   ISNULL(JSON_VALUE(cg.Traduccion, FORMATMESSAGE('$.%s.%s', '' + lower(replace(@IDIdioma, '-','')) + '', 'Descripcion')), 'N/A') as Genero,
		   ISNULL(da.Costo, 0.00) as Costo,
		   ISNULL(da.IDCatTipoCaducidad, 0) as IDCatTipoCaducidad,
		   ISNULL(da.IDUnidadDeTiempo, 0) as IDUnidadDeTiempo,
		   ISNULL(da.Tiempo, 0) as Tiempo
	from ControlEquipos.tblDetalleArticulos da
		left join RH.tblCatGeneros cg on cg.IDGenero = da.IDGenero
	where da.IDDetalleArticulo = @IDDetalleArticulo
end
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spBuscarCatTiposCaducidad](
	@IDCatTipoCaducidad int = 0,
	@IDUsuario int
)
as
begin
	declare @IDIdioma varchar(20);
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		IDCatTipoCaducidad,
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
	from ControlEquipos.tblCatTiposCaducidad
	where IDCatTipoCaducidad = 0 or (@IDCatTipoCaducidad = 0)
end
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc App.spBuscarCatTiposDatosExtras(
	@IDTipoDatoExtra varchar(100) = null,
	@IDUsuario int
) as
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		tde.IDTipoDatoExtra,
		JSON_VALUE(tde.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre
	from App.tblCatTiposDatosExtras tde
	where (tde.IDTipoDatoExtra = @IDTipoDatoExtra or isnull(@IDTipoDatoExtra, '') = '')
GO

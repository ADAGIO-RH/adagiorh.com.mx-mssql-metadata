USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [App].[spBuscarCatInputsTypes](
	@IDInputType varchar(100) = null,
	@IDUsuario int
) as
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		it.IDInputType,
		JSON_VALUE(it.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
		JSON_VALUE(it.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion,
		it.TipoDato,
		it.ConfiguracionSizeInput
	from App.tblCatInputsTypes it
		join App.tblCatTiposDatos td on td.TipoDato = it.TipoDato
	where (it.IDInputType = @IDInputType or isnull(@IDInputType, '') = '')
GO

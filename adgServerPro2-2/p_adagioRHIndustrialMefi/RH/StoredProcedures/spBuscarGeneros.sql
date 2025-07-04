USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc RH.spBuscarGeneros(
	@IDGenero char(1) = null,
	@IDUsuario int
) as
	declare 
		@IDIdioma varchar(20) 
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		IDGenero
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,Traduccion
	FROM RH.tblCatGeneros
	WHERE (IDGenero = @IDGenero or isnull(@IDGenero, '') = '')
GO

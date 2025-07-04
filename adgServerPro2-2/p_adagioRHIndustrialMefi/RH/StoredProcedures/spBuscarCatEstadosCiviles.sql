USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatEstadosCiviles](
	@EstadoCivil Varchar(50) = null,
	@IDUsuario int = 0
)
AS
BEGIN
	declare 
		@IDIdioma varchar(20) 
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		IDEstadoCivil
		,Codigo
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,Traduccion
	FROM RH.tblCatEstadosCiviles
	WHERE (Codigo LIKE @EstadoCivil+'%') OR(Descripcion LIKE @EstadoCivil+'%') OR (@EstadoCivil IS NULL)
END
GO

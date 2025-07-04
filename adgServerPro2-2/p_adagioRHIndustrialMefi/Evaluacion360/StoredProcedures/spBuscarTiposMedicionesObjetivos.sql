USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE   PROCEDURE [Evaluacion360].[spBuscarTiposMedicionesObjetivos](
	@IDTipoMedicionObjetivo int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
		tmo.IDTipoMedicionObjetivo
		,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
		,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,tmo.TipoDato
	from [Evaluacion360].[tblCatTiposMedicionesObjetivos] tmo
	where (tmo.IDTipoMedicionObjetivo = @IDTipoMedicionObjetivo or isnull(@IDTipoMedicionObjetivo, 0) = 0) 

END
GO

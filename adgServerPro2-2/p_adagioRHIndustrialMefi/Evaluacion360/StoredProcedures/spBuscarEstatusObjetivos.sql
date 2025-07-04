USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE   PROCEDURE [Evaluacion360].[spBuscarEstatusObjetivos](
	@IDEstatusObjetivo int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
		eo.IDEstatusObjetivo
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,eo.Orden
	from Evaluacion360.tblCatEstatusObjetivos eo
	where (eo.IDEstatusObjetivo = @IDEstatusObjetivo or isnull(@IDEstatusObjetivo, 0) = 0) 
END
GO

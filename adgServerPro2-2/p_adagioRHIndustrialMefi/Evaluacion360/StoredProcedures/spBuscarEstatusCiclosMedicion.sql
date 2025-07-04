USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Evaluacion360].[spBuscarEstatusCiclosMedicion](
	@IDEstatusCicloMedicion int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
		eo.IDEstatusCicloMedicion
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,eo.Orden
	from Evaluacion360.tblCatEstatusCiclosMedicion eo
	where (eo.IDEstatusCicloMedicion = @IDEstatusCicloMedicion or isnull(@IDEstatusCicloMedicion, 0) = 0) 
END
GO

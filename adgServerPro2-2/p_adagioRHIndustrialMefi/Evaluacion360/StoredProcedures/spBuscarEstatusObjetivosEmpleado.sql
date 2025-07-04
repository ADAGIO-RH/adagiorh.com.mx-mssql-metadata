USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROCEDURE [Evaluacion360].[spBuscarEstatusObjetivosEmpleado](
	@IDEstatusObjetivoEmpleado int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
		eo.IDEstatusObjetivoEmpleado
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,eo.Orden
	from Evaluacion360.tblCatEstatusObjetivosEmpleado eo
	where (eo.IDEstatusObjetivoEmpleado = @IDEstatusObjetivoEmpleado or isnull(@IDEstatusObjetivoEmpleado, 0) = 0) 
END
GO

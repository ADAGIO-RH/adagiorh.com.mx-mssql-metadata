USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spBuscarCatTiposProyectos](
	@IDTipoProyecto int = 0,
	@SoloActivos bit = 0,
	@IDUsuario int
) as

	declare 
		@IDIdioma varchar(20)
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		IDTipoProyecto,
		JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre,
		isnull(Activo, 0) as Activo,
		Configuracion
	from Evaluacion360.tblCatTiposProyectos
	where (IDTipoProyecto = @IDTipoProyecto or isnull(@IDTipoProyecto, 0) = 0)
		and (isnull(Activo, 0) = case when isnull(@SoloActivos, 0) = 1 then 1 else isnull(Activo, 0) end)
GO

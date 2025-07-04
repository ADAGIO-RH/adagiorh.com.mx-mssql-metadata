USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
CREATE   PROCEDURE [Evaluacion360].[spBuscarConfiguracionesObjetivos](
	@IDConfiguracionObjetivo int = 0,
	@IDGrupo int = 0,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	select 
		co.IDConfiguracionObjetivo
		,co.IDGrupo
		,g.Nombre as Grupo
		,co.FechaInicio
		,co.FechaFin
		,co.IDTipoMedicionObjetivo
		,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicion 
		,co.IDEstatusObjetivo
		,JSON_VALUE(o.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus 
		,co.IDUsuario
		,co.FechaHoraReg
	from [Evaluacion360].[tblConfiguracionesObjetivos] co
		join Evaluacion360.tblCatGrupos g on g.IDGrupo = co.IDGrupo
		join Evaluacion360.tblCatTiposMedicionesObjetivos tmo on tmo.IDTipoMedicionObjetivo = co.IDTipoMedicionObjetivo
		join Evaluacion360.tblCatEstatusObjetivos o on o.IDEstatusObjetivo = co.IDEstatusObjetivo
	where (co.IDConfiguracionObjetivo = @IDConfiguracionObjetivo or isnull(@IDConfiguracionObjetivo, 0) = 0) 
		and (co.IDGrupo = @IDGrupo or isnull(@IDGrupo, 0) = 0)
END
GO

USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Evaluacion360.spBuscarCiclosMedicionObjetivos(
	@IDCicloMedicionObjetivo int = 0
	,@IDUsuario int
) aS

	select 
		ccmo.IDCicloMedicionObjetivo
		,UPPER(ccmo.Nombre) as Nombre
		,ccmo.FechaInicio
		,ccmo.FechaFin
		,ccmo.IDEstatusCicloMedicion
		,JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusCicloMedicion
		,ccmo.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
	from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
		join Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
		join Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
	WHERE (ccmo.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
GO

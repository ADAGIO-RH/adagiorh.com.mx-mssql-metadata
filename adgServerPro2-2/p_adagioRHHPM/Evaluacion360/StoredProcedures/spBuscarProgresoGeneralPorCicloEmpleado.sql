USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc Evaluacion360.spBuscarProgresoGeneralPorCicloEmpleado(
	@IDCicloMedicionObjetivo int,
	@IDEmpleado int,
	@IDUsuario int
) as
	select 
		IDProgresoGeneralPorCicloEmpleado
		,IDCicloMedicionObjetivo
		,IDEmpleado
		,Porcentaje
	from Evaluacion360.tblProgresoGeneralPorCicloEmpleados 
	where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo and IDEmpleado = @IDEmpleado
GO

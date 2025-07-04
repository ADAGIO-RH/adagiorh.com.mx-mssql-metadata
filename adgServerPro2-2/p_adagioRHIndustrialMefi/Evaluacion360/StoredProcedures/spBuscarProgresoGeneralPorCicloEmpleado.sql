USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spBuscarProgresoGeneralPorCicloEmpleado](
	@IDCicloMedicionObjetivo int,
	@IDEmpleado int,
	@IDUsuario int
) as

	if exists(
		select 
			IDProgresoGeneralPorCicloEmpleado
			,IDCicloMedicionObjetivo
			,IDEmpleado
			,Porcentaje
		from Evaluacion360.tblProgresoGeneralPorCicloEmpleados 
		where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo and IDEmpleado = @IDEmpleado
	) 
	begin
		select 
			IDProgresoGeneralPorCicloEmpleado
			,IDCicloMedicionObjetivo
			,IDEmpleado
			,Porcentaje
		from Evaluacion360.tblProgresoGeneralPorCicloEmpleados 
		where IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo and IDEmpleado = @IDEmpleado
	end else 
	begin
		select 
			0 IDProgresoGeneralPorCicloEmpleado
			,@IDCicloMedicionObjetivo IDCicloMedicionObjetivo
			,@IDEmpleado IDEmpleado
			,0 Porcentaje
	end
GO

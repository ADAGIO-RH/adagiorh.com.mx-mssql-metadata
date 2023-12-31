USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view Dashboard.vwClimaLaboralTotalesPorDepartamentosIndicadores  as
	---- Total por departamento/indicador
	select 
		IDProyecto
		,Departamento
		,Indicador
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
	from (
		select 
			IDProyecto, 
			Departamento, 
			Indicador,
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Reportes.vwDashboardClimaLaboral
		group by IDProyecto, Departamento,Indicador
	) as info
	--order by Departamento
GO

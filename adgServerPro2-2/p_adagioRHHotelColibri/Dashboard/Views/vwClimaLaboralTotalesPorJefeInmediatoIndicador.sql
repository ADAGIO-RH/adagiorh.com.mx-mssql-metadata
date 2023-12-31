USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view Dashboard.vwClimaLaboralTotalesPorJefeInmediatoIndicador as
	-- Total por Jefe Inmediato/Indicador
	select 
		IDProyecto
		,ClaveEvaluado
		,Evaluado
		,Indicador
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
	from (
		select 
			IDProyecto,
			ClaveEvaluado,
			Evaluado,
			Indicador,
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Reportes.vwDashboardClimaLaboral
		group by IDProyecto, ClaveEvaluado, Evaluado,Indicador
	) as info
	--order by IDProyecto, Evaluado

GO

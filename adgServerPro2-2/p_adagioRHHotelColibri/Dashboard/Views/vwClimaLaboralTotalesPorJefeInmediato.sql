USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view Dashboard.vwClimaLaboralTotalesPorJefeInmediato as
	-- Total por Jefe Inmediato
	select 
		IDProyecto
		,ClaveEvaluado
		,Evaluado
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
	from (
		select 
			IDProyecto,
			ClaveEvaluado,
			Evaluado,
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Reportes.vwDashboardClimaLaboral
		group by IDProyecto,ClaveEvaluado, Evaluado
	) as info
GO

USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Dashboard].[spTotalesPorDepartamnetos] (
	@IDProyecto int
) as
	-- Total por departamento
	select 
		DepartamentoEvaluador as Departamento
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
	from (
		select 
			DepartamentoEvaluador, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Dashboard.tblReporteClimaLaboral
		where IDProyecto = @IDProyecto
		group by DepartamentoEvaluador
	) as info

GO

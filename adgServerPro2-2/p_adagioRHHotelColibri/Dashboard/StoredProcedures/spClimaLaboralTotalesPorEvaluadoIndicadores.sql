USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [Dashboard].[spClimaLaboralTotalesPorEvaluadoIndicadores](
	@IDProyecto int
)  as
	---- Total por departamento/indicador
	select 
		IDProyecto
		,ClaveEvaluado
		,Evaluado
		,Indicador
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
		,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
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
		where  IDProyecto = @IDProyecto-- and CodigoDepartamento = @CodigoDepartamento 
			and Indicador is not null and Grupo like '%SECCION 1%'
		group by IDProyecto, ClaveEvaluado, Evaluado,Indicador
	) as info
	order by ClaveEvaluado , Evaluado, cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc
	--order by Departamento
GO

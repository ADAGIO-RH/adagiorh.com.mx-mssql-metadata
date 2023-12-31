USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Dashboard].[spClimaLaboralTotalesPorSupervidor](
	@IDProyecto int
) as
	-- Total por departamento
	select	IDProyecto
			,ClaveEvaluado
			,Evaluado
			,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) * 100
			,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
	from (
		select 
			IDProyecto,
			ClaveEvaluado,
			Evaluado, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Reportes.vwDashboardClimaLaboral
		where  IDProyecto = @IDProyecto and Indicador is not null and Grupo like '%SECCION 1%'
		group by IDProyecto, ClaveEvaluado, Evaluado
	) as info
	order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc
GO

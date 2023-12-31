USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Dashboard].[spClimaLaboralTotalesPorDepartamentos](
	@IDProyecto int,
	@IDUsuario int
) as

	if OBJECT_ID('tempdb..#TempDepartamentosFiltrosClima') is not null drop table #TempDepartamentosFiltrosClima;

	select CodigoDepartamento
	INTO #TempDepartamentosFiltrosClima
	from  Dashboard.tblPermisosDepartamentos
	where IDUsuario = @IDUsuario

	-- Total por departamento
	select	IDProyecto
			,CodigoDepartamentoEvaluador as CodigoDepartamento
			,DepartamentoEvaluador as Departamento
			,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
			,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
	from (
		select 
			IDProyecto,
			CodigoDepartamentoEvaluador,
			DepartamentoEvaluador, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Dashboard.tblReporteClimaLaboral
		where  IDProyecto = @IDProyecto and Indicador is not null and Grupo like '%SECCION 1%'
			and (
				CodigoDepartamentoEvaluador in (select CodigoDepartamento from #TempDepartamentosFiltrosClima) or not exists(select CodigoDepartamento from #TempDepartamentosFiltrosClima)
			) 
		group by IDProyecto, CodigoDepartamentoEvaluador, DepartamentoEvaluador
	) as info
	order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc

GO

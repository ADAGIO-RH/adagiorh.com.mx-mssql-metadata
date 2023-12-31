USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Dashboard].[spClimaLaboralGetSugerencias] as

	select top 2
		IDProyecto
		,Proyecto
		,DepartamentoEvaluador as Departamento
		,Indicador
		,(
			select Respuesta 
			from Dashboard.tblReporteClimaLaboral
			where  IDProyecto = info.IDProyecto and CodigoDepartamentoEvaluador = info.CodigoDepartamentoEvaluador 
				and App.fnRemoveVarcharSpace(
						replace(replace(replace(Pregunta,' ','<>'),'><',''),'<>',' ')
					) like info.Indicador+'%'
				and Grupo like '%SECCION 4%'
			for JSON auto
		) Sugerencias
	from (
		select 
			IDProyecto, 
			Proyecto,
			CodigoDepartamentoEvaluador,
			DepartamentoEvaluador, 
			Indicador,
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Dashboard.tblReporteClimaLaboral
		where Indicador is not null and Grupo like '%SECCION 1%'
		group by IDProyecto, Proyecto, CodigoDepartamentoEvaluador, DepartamentoEvaluador,Indicador
	) as info
GO

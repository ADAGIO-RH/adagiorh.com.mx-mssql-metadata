USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    proc [Dashboard].[spClimaLaboralTotalesPorNiveles] (
	@IDProyecto int,
	@IDUsuario int
) as
	-- Total por departamento
	select	IDProyecto
			,CodigoNivelEvaluador as CodigoNivel
			,NivelEvaluador as Nivel
			,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
			,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
	from (
		select 
			IDProyecto,
			CodigoNivelEvaluador,
			NivelEvaluador, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from [Dashboard].tblReporteClimaLaboral
		where  IDProyecto = @IDProyecto and Indicador is not null and Grupo like '%SECCION 1%'
		group by IDProyecto, CodigoNivelEvaluador, NivelEvaluador
	) as info
	order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc

GO

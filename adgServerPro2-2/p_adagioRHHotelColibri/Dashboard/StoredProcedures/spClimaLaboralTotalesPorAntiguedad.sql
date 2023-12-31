USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Dashboard].[spClimaLaboralTotalesPorAntiguedad](
	@IDProyecto int,
	@IDUsuario int
) as
	-- Total por departamento
	select	IDProyecto
			,RangoAntiguedad
			,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
			,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
	from (
		select 
			IDProyecto,
			RangoAntiguedad, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from (
			select 
				IDProyecto,
				(select top 1 [label] from Dashboard.tblRangosAntiguedad where d.Antiguedad between [min] and [max]) as RangoAntiguedad, 
				Pregunta,
				ValorFinal
			from Dashboard.tblReporteClimaLaboral d			
			where  IDProyecto = @IDProyecto and Indicador is not null and Grupo like '%SECCION 1%'
		) dd
		group by IDProyecto, RangoAntiguedad
	) as info
	order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc

GO

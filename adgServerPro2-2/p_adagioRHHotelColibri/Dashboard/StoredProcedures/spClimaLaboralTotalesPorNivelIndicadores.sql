USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Dashboard].[spClimaLaboralTotalesPorNivelIndicadores](
	@IDProyecto int,
	@CodigoNivel varchar(20),
	@IDUsuario int
)  as
	---- Total por departamento/indicador
	select 
		IDProyecto
		,NivelEvaluador as Nivel
		,Indicador
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
		,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
		,(
			select Respuesta 
			from Dashboard.tblReporteClimaLaboral
			where  IDProyecto = @IDProyecto and CodigoNivelEvaluador = @CodigoNivel 
				and App.fnRemoveVarcharSpace(
						replace(replace(replace(Pregunta,' ','<>'),'><',''),'<>',' ')
					) like info.Indicador+'%'
				and Grupo like '%SECCION 4%'
				and (select top 1 Comentario from Dashboard.tblPermisosProyectos where IDProyecto = info.IDProyecto and IDUsuario = @IDUsuario) = 1
			for JSON auto
		) Sugerencias
	from (
		select 
			IDProyecto, 
			CodigoNivelEvaluador,
			NivelEvaluador, 
			Indicador,
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Dashboard.tblReporteClimaLaboral
		where  IDProyecto = @IDProyecto and CodigoNivelEvaluador = @CodigoNivel 
			and Indicador is not null and Grupo like '%SECCION 1%'
		group by IDProyecto, CodigoNivelEvaluador, NivelEvaluador,Indicador
	) as info
	order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc
	--order by Departamento
GO

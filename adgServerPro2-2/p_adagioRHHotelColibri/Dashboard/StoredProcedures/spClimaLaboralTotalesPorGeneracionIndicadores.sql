USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Dashboard].[spClimaLaboralTotalesPorGeneracionIndicadores](
	@IDProyecto int,
	@Generacion varchar(50),
	@IDUsuario int
)  as
	---- Total por departamento/indicador
	select 
		IDProyecto
		,Generacion
		,Indicador
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
		,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
		,(
			select Respuesta 
			from Dashboard.tblReporteClimaLaboral
			where  IDProyecto = @IDProyecto and Generacion = @Generacion
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
			Generacion, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor,
			Indicador
		from (
			select 
				IDProyecto,
				(select top 1 [label] from Dashboard.tblGeneraciones where DATEPART(YEAR, FechaNacimiento) between [min] and [max]) as Generacion, 
				Pregunta,
				ValorFinal,
				Indicador
			from Dashboard.tblReporteClimaLaboral d			
			where  IDProyecto = @IDProyecto and Indicador is not null and Grupo like '%SECCION 1%'
		) dd
		where Generacion = @Generacion
		group by IDProyecto, Generacion, Indicador
	) as info
	order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc
GO

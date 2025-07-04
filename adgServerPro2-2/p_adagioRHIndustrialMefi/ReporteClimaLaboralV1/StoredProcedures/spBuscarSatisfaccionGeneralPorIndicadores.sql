USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorIndicadores](
	@IDProyecto int,
	@IDUsuario int
) as
	
	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

	insert @Respuesta(Title, Valor, IDProyecto, JSONData)
	select 
		Indicador
		,AVG(Valor) as Valor
		,IDProyecto
		,FORMATMESSAGE('{ "IDIndicador": %d }', IDIndicador)
	from (
		select 
			d.IDProyecto, 
			d.IDIndicador,
			i.Nombre as Indicador,
			COUNT(d.IDPregunta) as TotalPreguntas,
			COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
			SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
			--SUM(d.ValorFinal) as Valor
		from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
			join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador
		where IDProyecto = @IDProyecto and IDTipoPreguntaGrupo in (2,3)
		group by d.IDProyecto, d.IDGrupo, d.IDIndicador, i.Nombre, d.MaximaCalificacionPosible
	) as info
	group by  IDProyecto, IDIndicador, Indicador
	--order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc
	
	update @Respuesta
		set
			Total = Valor * 100.00,
			Color = (
					select esg.Color 
					from [Evaluacion360].[tblEscalaSatisfaccionGeneral] esg
					where esg.IDProyecto = @IDProyecto and Valor between esg.[min] and esg.[max]
				)

	select *
	from @Respuesta
	order by Total desc
GO

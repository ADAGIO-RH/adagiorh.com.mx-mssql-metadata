USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorAntiguedad](
	@IDProyecto int,
	@IDRango int = 0,
	@IDUsuario int
) as
	declare 
		@Respuesta [Evaluacion360].[dtSatisfaccionGeneral],
		@query varchar(max),
		@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR int = 6,
		@ID_TIPO_PREGUNTA_TEXT_SIMPLE int = 4
	;

	set @query = N'
		select 
			'+case when isnull(@IDRango, 0) != 0 then 'Indicador' else 'Antiguedad' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"departamento","id":%d, "title": "%s por Indicadores", "IDIndicador": %d}'', IDProyecto, '+case when isnull(@IDRango, 0) != 0 then 'IDIndicador' else 'IDRango' end +', Antiguedad)
			--,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"antiguedad","id":%d, "title": "%s por Indicadores"}'', IDProyecto, IDRango, Antiguedad)
		from (
			select 
				d.IDProyecto, 
				d.IDRango,
				ra.Descripcion as Antiguedad,
				'+case when isnull(@IDRango, 0) != 0 then 'i.IDIndicador, i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join RH.tblRangosAntiguedad ra on ra.IDRango = d.IDRango
				'+case when isnull(@IDRango, 0) != 0 then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto = '+cast(@IDProyecto as varchar)+' and IDTipoPreguntaGrupo in (2,3)
				'+case when isnull(@IDRango, 0) != 0 then 'and d.IDRango = '+cast(@IDRango as varchar) else '' end +'
			group by d.IDProyecto, d.IDGrupo, d.IDRango, ra.Descripcion, '+case when isnull(@IDRango, 0) != 0 then 'i.IDIndicador, i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by  IDProyecto, IDRango, Antiguedad '+case when isnull(@IDRango, 0) != 0 then ',IDIndicador,Indicador' else '' end +'
	';

	insert @Respuesta(Title, Valor, IDProyecto, JSONData)
	exec (@query)

	update @Respuesta
		set
			Total = Valor * 100.00,
			Color = (
					select esg.Color 
					from [Evaluacion360].[tblEscalaSatisfaccionGeneral] esg
					where esg.IDProyecto = @IDProyecto and Valor between esg.[min] and esg.[max]
				),
			JSONData = (
				select *
				from (
					SELECT 
						@IDProyecto as IDProyecto,
						JSON_VALUE(JSONData, '$.tipo')  as tipo,
						JSON_VALUE(JSONData, '$.id')	as id,
						JSON_VALUE(JSONData, '$.title') as title,
						comentarios = 
							case when isnull(@IDRango, 0) != 0 then
								(
									select r.Respuesta
									from InfoDir.tblRespuestasNormalizadasClimaLaboral r
										join Evaluacion360.tblCatPreguntas p on p.IDPregunta = r.IDPregunta
									where IDProyecto = @IDProyecto 
											and r.IDDepartamento = 9
											and r.IDIndicador = cast(JSON_VALUE(JSONData, '$.id') as int)
										and IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR 
										and IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXT_SIMPLE 
										for json auto
								)
							else '[]' end
					) as info
				for json auto, without_array_wrapper
		
			) 

	select *
	from @Respuesta
	order by Total desc
GO

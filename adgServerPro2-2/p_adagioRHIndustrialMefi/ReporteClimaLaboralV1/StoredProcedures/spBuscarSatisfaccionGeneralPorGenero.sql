USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorGenero](
	@IDProyecto int,
	@IDGenero char(1) = '',
	@IDUsuario int
) as
	declare  
		@Respuesta [Evaluacion360].[dtSatisfaccionGeneral],
		@IDIdioma varchar(20),
		@query varchar(max),
		@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR int = 6,
		@ID_TIPO_PREGUNTA_TEXT_SIMPLE int = 4
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	set @query= N'
		select 
			'+case when isnull(@IDGenero, '') !=  '' then 'Indicador' else 'Genero' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"genero","id":"%s", "title": "%s por Indicadores", "IDIndicador": %d}'', IDProyecto, '+case when isnull(@IDGenero, '') !=  '' then 'cast(IDIndicador as varchar(10))' else 'IDGenero' end +', Genero)
			--,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"genero","id":"%s", "title": "%s por Indicadores"}'', IDProyecto, IDGenero, Genero)
		from (
			select 
				d.IDProyecto, 
				d.IDGenero,
				JSON_VALUE(g.Traduccion, FORMATMESSAGE(''$.%s.%s'', lower(replace('''+@IDIdioma+''', ''-'','''')), ''Descripcion'')) as Genero,
				'+case when isnull(@IDGenero, '') !=  '' then 'i.IDIndicador, i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join RH.tblCatGeneros g on g.IDGenero = d.IDGenero
				'+case when isnull(@IDGenero, '') !=  '' then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto =  '+cast(@IDProyecto as varchar)+' and IDTipoPreguntaGrupo in (2,3)
				'+case when isnull(@IDGenero, '') !=  '' then 'and d.IDGenero = '''+@IDGenero+'''' else '' end +'
			group by d.IDProyecto, d.IDGrupo, d.IDGenero, g.Traduccion, '+case when  isnull(@IDGenero, '') !=  '' then 'i.IDIndicador, i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by IDProyecto, IDGenero, Genero '+case when isnull(@IDGenero, '') !=  '' then ',IDIndicador, Indicador' else '' end +'
	';

	print (@query)

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
							case when isnull(@IDGenero, '') !=  '' then
								(
									select r.Respuesta
									from InfoDir.tblRespuestasNormalizadasClimaLaboral r
										join Evaluacion360.tblCatPreguntas p on p.IDPregunta = r.IDPregunta
									where IDProyecto = @IDProyecto 
											and r.IDGenero = @IDGenero
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

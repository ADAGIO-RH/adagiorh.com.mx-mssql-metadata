USE [p_adagioRHGrupoEnergy]
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
		@query varchar(max)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	set @query= N'
		select 
			'+case when isnull(@IDGenero, '') !=  '' then 'Indicador' else 'Genero' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"genero","id":"%s", "title": "%s por Indicadores"}'', IDProyecto, IDGenero, Genero)
		from (
			select 
				d.IDProyecto, 
				d.IDGenero,
				JSON_VALUE(g.Traduccion, FORMATMESSAGE(''$.%s.%s'', lower(replace('''+@IDIdioma+''', ''-'','''')), ''Descripcion'')) as Genero,
				'+case when isnull(@IDGenero, '') !=  '' then 'i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join RH.tblCatGeneros g on g.IDGenero = d.IDGenero
				'+case when isnull(@IDGenero, '') !=  '' then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto =  '+cast(@IDProyecto as varchar)+' and IDTipoPreguntaGrupo in (2,3)
			group by d.IDProyecto, d.IDGrupo, d.IDGenero, g.Traduccion, '+case when  isnull(@IDGenero, '') !=  '' then 'i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by IDProyecto, IDGenero, Genero '+case when isnull(@IDGenero, '') !=  '' then ',Indicador' else '' end +'
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
				)

	select 
		*
	from @Respuesta
	order by Total desc
GO

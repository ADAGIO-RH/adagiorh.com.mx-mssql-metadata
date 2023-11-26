USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorGeneracion](
	@IDProyecto int,
	@IDGeneracion int,
	@IDUsuario int
) as

	declare 
		@query varchar(max)
	;

	set @query = N'
		select 			
			'+case when isnull(@IDGeneracion, 0) != 0 then 'Indicador' else 'Generacion' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"generacion","id":%d, "title": "%s por Indicadores"}'', IDProyecto, IDGeneracion, Generacion)
		from (
			select 
				d.IDProyecto, 
				d.IDGeneracion,
				g.Descripcion as Generacion,
				'+case when isnull(@IDGeneracion, 0) != 0 then 'i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join RH.tblCatGeneraciones g on g.IDGeneracion = d.IDGeneracion
				'+case when isnull(@IDGeneracion, 0) != 0 then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto =  '+cast(@IDProyecto as varchar)+'  and IDTipoPreguntaGrupo in (2,3)
				'+case when isnull(@IDGeneracion, 0) != 0 then 'and d.IDGeneracion = '+cast(@IDGeneracion as varchar) else '' end +'
			group by d.IDProyecto, d.IDGrupo, d.IDGeneracion, g.Descripcion, '+case when isnull(@IDGeneracion, 0) != 0 then 'i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by  IDProyecto, IDGeneracion, Generacion '+case when isnull(@IDGeneracion, 0) != 0 then ',Indicador' else '' end +'
	
	';
	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

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

	select *
	from @Respuesta
	order by Total desc
GO

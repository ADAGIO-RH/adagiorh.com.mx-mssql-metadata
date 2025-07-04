USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorNiveles](
	@IDProyecto int,
	@IDNivelEmpresarial int = 0,
	@IDUsuario int
) as

	declare 
		@query varchar(max),
		@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR int = 6,
		@ID_TIPO_PREGUNTA_TEXT_SIMPLE int = 4
	;

	set @query = N'
		select 
			'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'Indicador' else 'Nivel' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"nivelempresarial","id":%d, "title": "%s por Indicadores", "IDIndicador": %d}'', IDProyecto, '+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'IDIndicador' else 'IDNivelEmpresarial' end +', Nivel)
			--,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"nivelempresarial","id":%d, "title": "%s por Indicadores"}'', IDProyecto, IDNivelEmpresarial, Nivel)
		from (
			select 
				d.IDProyecto, 
				d.IDNivelEmpresarial,
				cat.Nombre as Nivel,
				'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'i.IDIndicador, i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join #listaNiveles cat on cat.IDNivelEmpresarial = d.IDNivelEmpresarial
				'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto = '+cast(@IDProyecto as varchar)+' and IDTipoPreguntaGrupo in (2,3)
				'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'and d.IDNivelEmpresarial = '+cast(@IDNivelEmpresarial as varchar) else '' end +'
			group by d.IDProyecto, d.IDNivelEmpresarial, cat.Nombre, '+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'i.IDIndicador, i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by  IDProyecto, IDNivelEmpresarial, Nivel '+case when isnull(@IDNivelEmpresarial, 0) != 0 then ',IDIndicador, Indicador' else '' end +'
	'; 

	if object_id('tempdb..#listaNiveles') is not null drop table #listaNiveles;

	create table #listaNiveles (
		IDNivelEmpresarial int,
		Nombre varchar(255),
		Orden int,
		TotalPaginas int,
		TotalRegistros int
	);

	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

	insert #listaNiveles
	exec RH.[spBuscarNivelesEmpresariales] @IDUsuario=@IDUsuario

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
							case when isnull(@IDNivelEmpresarial, 0) != 0 then
								(
									select r.Respuesta
									from InfoDir.tblRespuestasNormalizadasClimaLaboral r
										join Evaluacion360.tblCatPreguntas p on p.IDPregunta = r.IDPregunta
									where IDProyecto = @IDProyecto 
											and r.IDNivelEmpresarial = @IDNivelEmpresarial
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

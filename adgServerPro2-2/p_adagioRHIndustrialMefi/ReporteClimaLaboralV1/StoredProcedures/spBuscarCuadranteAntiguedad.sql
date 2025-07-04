USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [ReporteClimaLaboralV1].[spBuscarCuadranteAntiguedad] (
	@IDProyecto int,
	@IDRango int,
	@IDUsuario int
) as
	declare 
		@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR int = 6,
		@ID_TIPO_PREGUNTA_RANKING int = 10,
		@RespuestaJSON varchar(max),
		@RN int,
		@satisfaccionGeneral [Evaluacion360].[dtSatisfaccionGeneral]
	;

	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

	insert @satisfaccionGeneral(Title, Valor, Total, IDProyecto, JSONData)
	select 
		Indicador
		,AVG(Valor) as Valor
		,AVG(Valor) *100.00 as Total
		,IDProyecto
		,FORMATMESSAGE('{"IDIndicador":%d}', IDIndicador)
	from (
		select 
			d.IDProyecto, 
			d.IDRango,
			ra.Descripcion as Antiguedad,
			i.IDIndicador,
			i.Nombre as Indicador,
			COUNT(d.IDPregunta) as TotalPreguntas,
			COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
			SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
		from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
			join RH.tblRangosAntiguedad ra on ra.IDRango = d.IDRango
			join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador
		where IDProyecto = @IDProyecto and IDTipoPreguntaGrupo in (2,3)
			and d.IDRango = @IDRango
		group by d.IDProyecto, d.IDGrupo, d.IDRango, ra.Descripcion,i.IDIndicador, i.Nombre, d.MaximaCalificacionPosible
	) as info
	group by  IDProyecto, IDRango, Antiguedad, IDIndicador,Indicador
	

	if OBJECT_ID('tempdb..#tempRespuestasJSON') is not null drop table #tempRespuestasJSON;
	if OBJECT_ID('tempdb..#tempRespuestas') is not null drop table #tempRespuestas;
	if OBJECT_ID('tempdb..#tempRespuestasCount') is not null drop table #tempRespuestasCount;
	if OBJECT_ID('tempdb..#tempRespuestasFinal') is not null drop table #tempRespuestasFinal;
	if OBJECT_ID('tempdb..#tempSatifasccion') is not null drop table #tempSatifasccion;

	create table #tempRespuestas (
		IDPosibleRespuesta INT,
		Orden INT
	);

	create table #tempRespuestasFinal (
		OpcionRespuesta varchar(max),
		Orden INT,
		IDIndicador int
	);

	select 
		rnc.IDProyecto, 
		rnc.IDRango,
		rnc.Respuesta,
		0 as IDIndicador,
		ROW_NUMBER()over(order by IDProyecto) as RN
	INTO #tempRespuestasJSON
	from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] rnc
		join Evaluacion360.tblCatPreguntas p on p.IDPregunta = rnc.IDPregunta
	where rnc.IDProyecto = @IDProyecto
		and rnc.IDRango = @IDRango
		and rnc.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR
		and p.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING

	select @RN = MIN(RN) from #tempRespuestasJSON

	while exists (select top 1 1
					from #tempRespuestasJSON
					where RN >= @RN)
	begin
		select @RespuestaJSON = Respuesta from #tempRespuestasJSON where RN = @RN

		if (ISJSON(@RespuestaJSON) = 1)
		begin
			insert into #tempRespuestas
			select re.*
			from OPENJSON(@RespuestaJSON)
			WITH (
				IDPosibleRespuesta INT 'strict $.IDPosibleRespuesta',
				Orden INT
			) as re;
		end
		select @RN = MIN(RN) from #tempRespuestasJSON where RN > @RN
	end

	select *,ROW_NUMBER()over(partition by Orden order by Total desc) as RN
	into #tempRespuestasCount
	from (
		select OpcionRespuesta, Orden, pr.JSONData, COUNT(Orden) Total
		from #tempRespuestas r
			join Evaluacion360.tblPosiblesRespuestasPreguntas pr
				on r.IDPosibleRespuesta = pr.IDPosibleRespuesta
		group by OpcionRespuesta, Orden, pr.JSONData
	) as info
	order by Orden desc, Total desc	  
	
	insert #tempRespuestasFinal(OpcionRespuesta, Orden, IDIndicador)
	select OpcionRespuesta, ROW_NUMBER()Over(order by orden_total)  as orden, JSON_VALUE(JSONData, '$.IDIndicador')
	from (
		select OpcionRespuesta, JSONData, SUM(isnull(orden,0) * isnull(Total,0)) as orden_total, sum(Total) as total
		from #tempRespuestasCount
		group by OpcionRespuesta, JSONData
	) info
	order by orden_total desc

	select 
		satisfaccion.Title,
		satisfaccion.Total,
		satisfaccion.Color,
		(
			select *
			from (
				select 
				(
					select esg.IndiceSatisfaccion 
					from [Evaluacion360].[tblEscalaSatisfaccionGeneral] esg
					where esg.IDProyecto = @IDProyecto and satisfaccion.Valor between esg.[min] and esg.[max] 
				) IndiceSatisfaccion,
				(
				select eri.IndiceRelevancia 
				from [Evaluacion360].tblEscalaRelevanciaIndicadores eri
				where eri.IDProyecto = @IDProyecto and final.orden between eri.[min] and eri.[max] 
				) IndiceRelevancia,
				icon.NombreIcono
			) d
			for json auto, without_array_wrapper
		) as JSONData,
		@IDProyecto as IDProyecto
	from #tempRespuestasFinal final
		left join @satisfaccionGeneral satisfaccion on JSON_VALUE(satisfaccion.JSONData, '$.IDIndicador') = final.IDIndicador
		left join Evaluacion360.tblCatIndicadores icon on icon.IDIndicador = final.IDIndicador
GO

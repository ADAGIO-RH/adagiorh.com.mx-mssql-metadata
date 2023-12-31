USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Dashboard].[spClimaLaboralCuadrantePorGeneracion](
	@IDProyecto int,
	@Generacion varchar(50),
	@IDUsuario int
)  as

	declare 
		@RespuestaJSON varchar(max),
		@RN int
	;

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
		Orden INT
	);

	declare @iconos_indicadores as table (
		Indicador varchar(max),
		icon varchar(max)
	)

	insert @iconos_indicadores
	values 
		 ('Confianza en la Organización'	, 'confianza_en_la_organizacion.png')
		,('Satisfacción en el Puesto'		, 'satisfaccion_en_el_puesto.png')
		,('Comunicación'					, 'comunicacion.png')
		,('Efectividad de Liderazgo'		, 'efectividad_de_liderazgo.png')
		,('Compensación y Beneficios'		, 'compensacion_y_beneficios.png')
		,('Espíritu de Equipo y Colaboración', 'espiritu_de_equipo_y_colaboracion.png')
		,('Calidad de Vida y Trabajo'		, 'calidad_de_vida_y_trabajo.png')
		,('Entorno Físico de Trabajo'		, 'entorno_fisico_de_trabajo.png')
		,('Desarrollo Profesional'			, 'desarrollo_profesional.png')
		,('Reconocimiento'					, 'reconocimiento.png')
		,('Identidad y Compromiso'			, 'identidad_y_compromiso.png')

	select 
		IDProyecto
		,Generacion
		,Indicador
		,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
		,(select top 1 color from Dashboard.tblEscala where cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  between [min] and [max]) color
	INTO #tempSatifasccion
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
			where  IDProyecto = @IDProyecto and Indicador is not null and Grupo like '%SECCION 2%'
		) dd
		where Generacion = @Generacion
		group by IDProyecto, Generacion,Indicador
	) as info
	--order by cast(Valor / MaximaCalificacionPosible  as decimal(10,2))  desc

	select 
		IDProyecto, 
		Generacion,
		Respuesta,
		ROW_NUMBER()over(order by Generacion) as RN
	INTO #tempRespuestasJSON
	from (
		select *,
			(select top 1 [label] from Dashboard.tblGeneraciones where DATEPART(YEAR, FechaNacimiento) between [min] and [max]) as Generacion
		from  Dashboard.tblReporteClimaLaboral
		where  IDProyecto = @IDProyecto and Grupo like '%SECCION 3%'
	) ddd
	where Generacion = @Generacion
	
	select @RN = MIN(RN) from #tempRespuestasJSON

	while exists (select top 1 1
					from #tempRespuestasJSON
					where RN >= @RN)
	begin
		select @RespuestaJSON = Respuesta from #tempRespuestasJSON where RN = @RN

		if (ISJSON(@RespuestaJSON) = 1)
		begin
			insert into #tempRespuestas
			select *
			from OPENJSON(@RespuestaJSON)
			WITH (
				IDPosibleRespuesta INT 'strict $.IDPosibleRespuesta',
				Orden INT
			);
		end
		select @RN = MIN(RN) from #tempRespuestasJSON where RN > @RN
	end

	select *,ROW_NUMBER()over(partition by Orden order by Total desc) as RN
	into #tempRespuestasCount
	from (
		select OpcionRespuesta, Orden, COUNT(Orden) Total
		from #tempRespuestas r
			join Evaluacion360.tblPosiblesRespuestasPreguntas pr
				on r.IDPosibleRespuesta = pr.IDPosibleRespuesta
		group by OpcionRespuesta, Orden	
	) as info
	order by Orden desc, Total desc	  

	set @RN = 11

	insert #tempRespuestasFinal(OpcionRespuesta, Orden)
	select OpcionRespuesta, ROW_NUMBER()Over(order by orden_total)  as orden
	from (
		select OpcionRespuesta, SUM(isnull(orden,0) * isnull(Total,0)) as orden_total, sum(Total) as total
		from #tempRespuestasCount
		group by OpcionRespuesta
	) info
	order by orden_total desc

	update #tempRespuestasFinal
	set OpcionRespuesta = 'ENTORNO FÍSICO DE TRABAJO'
	where OpcionRespuesta = 'ENTORNO FÍSICO DE  TRABAJO    '

	update #tempRespuestasFinal
	set OpcionRespuesta = 'DESARROLLO PROFESIONAL'
	where OpcionRespuesta = 'DESARROLLO  PROFESIONAL   '

	update #tempRespuestasFinal
	set OpcionRespuesta = 'IDENTIDAD Y COMPROMISO'
	where OpcionRespuesta = 'IDENTIDAD Y  COMPROMISO   '

	select final.*, satisfaccion.*, icon.icon,
		(select top 1 indiceRelevancia from Dashboard.tblEscalRelevancia where Orden between [min] and [max]) indiceRelevancia,
		(select top 1 indiceSatisfaccion from Dashboard.tblEscala where Total between [min] and [max]) indiceSatisfaccion

	from #tempRespuestasFinal final
		left join #tempSatifasccion satisfaccion on App.fnRemoveVarcharSpace(satisfaccion.Indicador) = App.fnRemoveVarcharSpace(final.OpcionRespuesta)
		left join @iconos_indicadores icon on icon.Indicador = satisfaccion.Indicador

GO

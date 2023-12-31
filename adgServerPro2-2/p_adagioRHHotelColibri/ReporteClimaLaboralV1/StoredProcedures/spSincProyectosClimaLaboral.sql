USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc ReporteClimaLaboralV1.spSincProyectosClimaLaboral (
	@IDProyecto int
) as

	declare 
		@IDTipoProyecto int,
		@config varchar(max),
		@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3,

		@TIPO_REFERENCIA_PROYECTO int = 1,
		@ID_TIPO_GRUPO_SECCION int = 5,
		@ID_TIPO_PREGUNTA_GRUPO_MIXTA int = 1,
		@ID_TIPO_PREGUNTA_GRUPO_ESCALA_INDIVIDUAL int = 3,
		@ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR int = 6,
		@ID_TIPO_PREGUNTA_RANKING int = 10,
		@ID_TIPO_PREGUNTA_TEXT_SIMPLE int = 4,

		@IDGrupoNuevo int,
		@IDPreguntaRankingNueva int,
		@IDPreguntaTextoSimpleNueva int
	;

	select @IDTipoProyecto=p.IDTipoProyecto,
		@config=tp.Configuracion
	from Evaluacion360.tblCatProyectos p
		join Evaluacion360.tblCatTiposProyectos tp on tp.IDTipoProyecto = p.IDTipoProyecto
	where p.IDProyecto = @IDProyecto

	if (@IDTipoProyecto != @ID_TIPO_PROYECTO_CLIMA_LABORAL)
	begin
		raiserror('El proeycto no es un clima laboral', 16, 1)
		return
	end

	BEGIN -- ESCALA
		if not exists(select top 1 1 
					from [Evaluacion360].[tblEscalaSatisfaccionGeneral] 
					where IDProyecto = @IDProyecto
				)
		begin
			insert [Evaluacion360].[tblEscalaSatisfaccionGeneral](Nombre, Descripcion, [Min], [Max], Color, IndiceSatisfaccion, IDProyecto)
			SELECT 
				Nombre,
				Descripcion,
				[Min],
				[Max],
				Color,
				IndiceSatisfaccion,
				@IDProyecto
			FROM OPENJSON(@config, '$.Escalas.Satisfaccion') 
				with (
					IDEscalaSatisfaccion int,
					Nombre varchar(255),
					Descripcion varchar(255),
					[Min] float,
					[Max] float,
					Color varchar(255),
					IndiceSatisfaccion int
				)
			AS config
		end

		if not exists(select top 1 1 
					from [Evaluacion360].tblEscalaRelevanciaIndicadores 
					where IDProyecto =@IDProyecto)
		begin
			insert Evaluacion360.tblEscalaRelevanciaIndicadores(Descripcion, [Min], [Max], IndiceRelevancia, IDProyecto)
			SELECT 
				Descripcion,
				[Min],
				[Max],
				IndiceRelevancia,
				@IDProyecto
			FROM OPENJSON(@config, '$.Escalas.Relevancia') 
				with (
					Descripcion varchar(255),
					[Min] float,
					[Max] float,
					IndiceRelevancia int
				)
			AS config
		end
	END

	BEGIN -- PREGUNTAS EVALUACION
		begin -- CORRECION OPCIONES RESPUESTAS INDICADOR
			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and prp.OpcionRespuesta = 'ENTORNO FÍSICO DE  TRABAJO    '
			)
			begin
				update prp
					set
						prp.OpcionRespuesta = 'ENTORNO FÍSICO DE TRABAJO'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and prp.OpcionRespuesta = 'ENTORNO FÍSICO DE  TRABAJO    '
			end

			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and prp.OpcionRespuesta = 'DESARROLLO  PROFESIONAL   '
			)
			begin
				update prp
					set
						prp.OpcionRespuesta = 'DESARROLLO PROFESIONAL'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and prp.OpcionRespuesta = 'DESARROLLO  PROFESIONAL   '
			end

			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and prp.OpcionRespuesta = 'IDENTIDAD Y  COMPROMISO   '
			)
			begin
				update prp
					set
						prp.OpcionRespuesta = 'IDENTIDAD Y COMPROMISO'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and prp.OpcionRespuesta = 'IDENTIDAD Y  COMPROMISO   '
			end
	
			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'ENTORNO FÍSICO DE %'
			)
			begin
				update p
					set
						p.Descripcion = 'ENTORNO FÍSICO DE TRABAJO: DISPONIBILIDAD DE HERRAMIENTAS Y ESPACIOS SEGUROS Y CONFORTABLES PARA REALIZAR LAS  ACTIVIDADES DEL PUESTO'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'ENTORNO FÍSICO DE %'
			end

			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'DESARROLLO %'
			)
			begin
				update p
					set
						p.Descripcion = 'DESARROLLO PROFESIONAL: OPORTUNIDADES DE CRECIMIENTO Y FORMACIÓN PROFESIONAL DENTRO DE LA ORGANIZACIÓN.'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'DESARROLLO %'
			end

			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'IDENTIDAD Y %'
			)
			begin
				update p
					set
						p.Descripcion = 'IDENTIDAD Y COMPROMISO: AFINIDAD Y CONEXIÓN QUE SE TIENE CON LOS OBJETIVOS Y VALORES DE LA ORGANIZACIÓN, Y EL ORGULLO  DE PERTENECER A ELLA.'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'IDENTIDAD Y %'
			end

			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'EFECTIVIDAD: DE LIDERAZGO ES LA ORIENTACIÓN, APOYO E INFLUENCIA QUE TIENEN LOS LÍDERES EN SUS EQUIPOS.%'
			)
			begin
				update p
					set
						p.Descripcion = 'EFECTIVIDAD DE LIDERAZGO: ES LA ORIENTACIÓN, APOYO E INFLUENCIA QUE TIENEN LOS LÍDERES EN SUS EQUIPOS.'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'EFECTIVIDAD: DE LIDERAZGO ES LA ORIENTACIÓN, APOYO E INFLUENCIA QUE TIENEN LOS LÍDERES EN SUS EQUIPOS.%'
			end

			if exists(
				select top 1 1
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'CONFIANZA: EN LA ORGANIZACIÓN ES LA CONGRUENCIA Y CREDIBILIDAD QUE TRANSMITE LA ORGANIZACIÓN.%'
			)
			begin
				update p
					set
						p.Descripcion = 'CONFIANZA EN LA ORGANIZACIÓN: ES LA CONGRUENCIA Y CREDIBILIDAD QUE TRANSMITE LA ORGANIZACIÓN.'
				from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
					and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
					and p.Descripcion like 'CONFIANZA: EN LA ORGANIZACIÓN ES LA CONGRUENCIA Y CREDIBILIDAD QUE TRANSMITE LA ORGANIZACIÓN.%'
			end
		end

		update p
		set p.IDIndicador =
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXT_SIMPLE then
				(select top 1 IDIndicador from Evaluacion360.tblCatIndicadores where p.Descripcion like '%'+Nombre+ '%' )
			end  
		from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA

		update prp
		set prp.JSONData = case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING then
				(select top 1 FORMATMESSAGE('{ "IDIndicador": %d }', IDIndicador) from Evaluacion360.tblCatIndicadores where Nombre = prp.OpcionRespuesta)
			end
		from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA

		select g.IDTipoPreguntaGrupo, p.*, prp.*,
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING then
				(select top 1 FORMATMESSAGE('{ "IDIndicador": %d }', IDIndicador) from Evaluacion360.tblCatIndicadores where Nombre = prp.OpcionRespuesta)
			end as JSONDataOpcionRespuesta,
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXT_SIMPLE then
				(select top 1 IDIndicador from Evaluacion360.tblCatIndicadores where p.Descripcion like '%'+Nombre+ '%' )
			end as IDIndicadorPregunta
		from Evaluacion360.tblEmpleadosProyectos ep
			join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
			left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
		where ep.IDProyecto = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
			and p.IDTipoPregunta = 10
	
		select g.IDTipoPreguntaGrupo, p.*, prp.*,
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING then
				(select top 1 FORMATMESSAGE('{ "IDIndicador": %d }', IDIndicador) from Evaluacion360.tblCatIndicadores where Nombre = prp.OpcionRespuesta)
			end as JSONDataOpcionRespuesta,
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXT_SIMPLE then
				(select top 1 IDIndicador from Evaluacion360.tblCatIndicadores where p.Descripcion like '%'+Nombre+ '%' )
			end as IDIndicadorPregunta
		from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
			and p.IDTipoPregunta = 4

		if exists(
			select top 1 1
			from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
			and p.IDTipoPregunta in (@ID_TIPO_PREGUNTA_RANKING,@ID_TIPO_PREGUNTA_TEXT_SIMPLE)
		) 
		begin
			update g
				set
					g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR
			from Evaluacion360.tblEmpleadosProyectos ep
					join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
					join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
					left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
				where ep.IDProyecto = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
			and p.IDTipoPregunta in (@ID_TIPO_PREGUNTA_RANKING,@ID_TIPO_PREGUNTA_TEXT_SIMPLE)
		end
		update p
			set
				p.IDIndicador = i.IDIndicador
		from Evaluacion360.tblEmpleadosProyectos ep
			join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			join Evaluacion360.tblCatGrupos g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
			left join Dashboard.tblReporteClimaLaboral c on c.Pregunta = p.Descripcion
			left join Evaluacion360.tblCatIndicadores i on i.Nombre = c.Indicador
			--left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
		where ep.IDProyecto = @IDProyecto
		and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_ESCALA_INDIVIDUAL
	END

	BEGIN -- PREGUNTAS COMENTARIOS
		update p
		set p.IDIndicador =
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXT_SIMPLE then
				(select top 1 IDIndicador from Evaluacion360.tblCatIndicadores where p.Descripcion like '%'+Nombre+ '%' )
			end  
		from Evaluacion360.tblCatGrupos g
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
			left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
		where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA

		update prp
		set prp.JSONData = case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING then
				(select top 1 FORMATMESSAGE('{ "IDIndicador": %d }', IDIndicador) from Evaluacion360.tblCatIndicadores where Nombre = prp.OpcionRespuesta)
			end
		from Evaluacion360.tblCatGrupos g
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
			left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
		where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA

		select g.IDTipoPreguntaGrupo, p.*, prp.*,
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING then
				(select top 1 FORMATMESSAGE('{ "IDIndicador": %d }', IDIndicador) from Evaluacion360.tblCatIndicadores where Nombre = prp.OpcionRespuesta)
			end as JSONDataOpcionRespuesta,
			case when p.IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXT_SIMPLE then
				(select top 1 IDIndicador from Evaluacion360.tblCatIndicadores where p.Descripcion like '%'+Nombre+ '%' )
			end as IDIndicadorPregunta
		from Evaluacion360.tblCatGrupos g
			join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
			left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
		where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto
			and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA

		if exists(
			select top 1 1
			from Evaluacion360.tblCatGrupos g
				join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
				left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
			where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto
				and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
		) 
		begin
			update g
				set
					g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_IMPORTANCIA_INDICADOR
			from Evaluacion360.tblCatGrupos g
				join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
				left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta
			where g.TipoReferencia = 1 and g.IDReferencia = @IDProyecto
				and g.IDTipoPreguntaGrupo = @ID_TIPO_PREGUNTA_GRUPO_MIXTA
		end
	END

	exec InfoDir.spSincronizarEvaluacionesClimaLaboral_V1 @IDProyecto = @IDProyecto
	 
GO

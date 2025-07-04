USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spResumenGrupalEvaluacionExcel](
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int
) as

	declare 
		@IDProyecto int,
        @IDIdioma VARCHAR(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	SET @IDProyecto = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDProyecto'),','))
	
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where ep.IDProyecto = @IDProyecto

	select 
		empleado.ClaveEmpleado		as [CLAVE COLABORADOR]
		,empleado.NOMBRECOMPLETO	as [COLABORADOR]
		,evaluador.ClaveEmpleado	as [CLAVE EVALUADOR]
		,evaluador.NOMBRECOMPLETO	as [EVALUADOR]
		,ctg.Nombre					as [TIPO GRUPO]
		,g.Nombre					as [NOMBRE DEL GRUPO]
		,isnull(g.Porcentaje,0)		as [PORCENTAJE]
		,isnull(g.Promedio,0)		as [PROMEDIO]
		,UPPER (JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'TipoPregunta'))) 			as [TIPO DE PREGUNTA]
		,p.Descripcion				as [PREGUNTA]
		,[RESPUESTA] = 
			case 
				/* MENÚ DESPLEGABLE */
				when p.IDTipoPregunta = 5 then (select top 1 OpcionRespuesta
												from [Evaluacion360].[tblPosiblesRespuestasPreguntas] with (nolock)
												where IDpregunta = p.IDPregunta and IDPosibleRespuesta = cast(rp.Respuesta as int))
				/* CONTROL DESLIZANTE */
				when p.IDTipoPregunta = 6 then rp.Respuesta+ '% de '+ [Evaluacion360].[fnBuscarValorLadoDerechoControlDeslizable]((select top 1 OpcionRespuesta
												from [Evaluacion360].[tblPosiblesRespuestasPreguntas] with (nolock)
												where IDpregunta = p.IDPregunta
												))
				/* ESCALA PROYECTO */
				when p.IDTipoPregunta = 8 then (select top 1 Nombre
												from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock) 
												where IDProyecto = @IDProyecto and Valor = cast(rp.Respuesta as int)
												)
				
			else rp.Respuesta end
		,[VALOR NUMERICO] =
			case 
				when p.IDTipoPregunta = 6 then rp.Respuesta else rp.ValorFinal
			end
		,estatus.Estatus as [ESTATUS]
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join #tempHistorialEstatusEvaluacion estatus with (nolock) on ee.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.[ROW] = 1
		left join [Evaluacion360].[tblCatGrupos] g with (nolock) on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
		left join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on ctg.IDTipoGrupo = g.IDTipoGrupo
		left join [Evaluacion360].[tblCatPreguntas] p with (nolock) on p.IDGrupo = g.IDGrupo
		left join [Evaluacion360].[tblCatTiposDePreguntas] ctp with (nolock) on ctp.IDTipoPregunta = p.IDTipoPregunta
		left join [Evaluacion360].[tblRespuestasPreguntas] rp with (nolock) on rp.IDPregunta = p.IDPregunta
		left join [RH].[tblEmpleadosMaster] empleado with (nolock) on ep.IDEmpleado = empleado.IDEmpleado
		left join [RH].[tblEmpleadosMaster] evaluador with (nolock) on ee.IDEvaluador = evaluador.IDEmpleado
	where ep.IDProyecto = @IDProyecto
	order by empleado.ClaveEmpleado, ctg.Nombre, g.Nombre
GO

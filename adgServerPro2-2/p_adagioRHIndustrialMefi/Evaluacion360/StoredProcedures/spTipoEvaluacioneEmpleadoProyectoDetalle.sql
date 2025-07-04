USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Evaluacion360].[spTipoEvaluacioneEmpleadoProyectoDetalle](
	@IDEmpleadoProyecto int,
	@IDTipoEvaluacion int,
	@IDUsuario int
) as
	declare
			@ID_TIPO_PREGUNTA_FUNCION_CLAVE int = 11,
			@TIPO_REFERENCIA_EVALUACION_EMPLEADO int = 4
	;

	select 
		tg.Nombre	as TipoGrupo,
		g.Nombre	as Grupo,
		g.Descripcion as DescripcionGrupo, 
		cast(sum(g.Porcentaje	)/count(*) as decimal(18,2)) as Porcentaje, 
		cast(sum(g.Promedio		)/count(*) as decimal(18,2)) as Promedio,
		p.Descripcion as Pregunta,
		cast(sum(isnull(rp.ValorFinal, 0))/count(*) as decimal(10,2)) as ValorFinal,
		JSON_VALUE(rp.Payload, '$.Herramienta') as Herramienta,
		JSON_VALUE(rp.Payload, '$.Resultado') as Resultado
	from Evaluacion360.tblEvaluacionesEmpleados ee
		left join Evaluacion360.tblCatTiposEvaluaciones cte on cte.IDTipoEvaluacion = ee.IDTipoEvaluacion
		join Evaluacion360.tblCatGrupos		g	on g.TipoReferencia = @TIPO_REFERENCIA_EVALUACION_EMPLEADO 
			and IDReferencia = ee.IDEvaluacionEmpleado
		join Evaluacion360.tblCatTipoGrupo	tg	on tg.IDTipoGrupo = g.IDTipoGrupo
		join Evaluacion360.tblCatPreguntas	p	on p.IDGrupo = g.IDGrupo
		left join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
	where ee.IDEmpleadoProyecto = @IDEmpleadoProyecto and ee.IDTipoEvaluacion = @IDTipoEvaluacion
	group by 
		tg.Nombre
		,g.Nombre
		,g.Descripcion
		--,g.Porcentaje
		--,g.Promedio
		,p.Descripcion
		,rp.Payload
	order by g.Nombre, p.Descripcion
GO

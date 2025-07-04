USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create   proc Evaluacion360.spBuscarResultadosEvaluacionEmpleadoPorGrupos(
	@IDEmpleadoProyecto int,
	@IDTipoEvaluacion int,
	@IDUsuario int
) as
	declare 
		@TIPO_REFERENCIA_EVALUACION_EMPLEADO int = 4
	;

	select
		tg.Nombre as TipoGrupo
		,g.Nombre as Grupo
		,g.Descripcion
		,cast(sum(isnull(g.Promedio,	0.00))/count(*) as decimal(10, 2)) as Promedio							,cast(sum(isnull(g.Porcentaje,	0.00))/count(*) as decimal(10, 2)) as Porcentaje		
	from Evaluacion360.tblEvaluacionesEmpleados ee
		join Evaluacion360.tblCatGrupos g on g.TipoReferencia = @TIPO_REFERENCIA_EVALUACION_EMPLEADO and g.IDReferencia = ee.IDEvaluacionEmpleado
		join Evaluacion360.tblCatTipoGrupo tg on tg.IDTipoGrupo = g.IDTipoGrupo
	where ee.IDEmpleadoProyecto = @IDEmpleadoProyecto and ee.IDTipoEvaluacion = @IDTipoEvaluacion
	group by 
		tg.Nombre
		,g.Nombre
		,g.Descripcion
GO

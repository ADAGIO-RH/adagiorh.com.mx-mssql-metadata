USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las pruebas por Proyecto según el parámetro Tipo
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-15
** Paremetros		:    
	@Tipo 1 = Las pruebas pendientes
		  2 = Las pruebas completas
		  3 = Todas las pruebas
		  4 = Las pruebas en estatus EVALUADOR ASIGNADO

** DataTypes Relacionados: 


-- Si se modifica este SP será necesario modificar los siguientes:
	[Evaluacion360].[spCompletarProyecto]
	Demo.spCrearProyectoEvaluacion
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10		Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2024-09-27		Alejandro Paredes	Se agrego el @Tipo = 4
***************************************************************************************************/
/*
	[Evaluacion360].[spBuscarPruebasPorProyecto]  
						 @IDProyecto	= 28
						,@Tipo			= 3
						,@IDUsuario		= 1

					*/
CREATE proc [Evaluacion360].[spBuscarPruebasPorProyecto] (
	@IDProyecto int
	,@Tipo int = 3
	,@IDUsuario int  
) AS
	
	DECLARE @ListaEstatus varchar(100) = CASE 
											WHEN @Tipo = 1 THEN '11,12' 
											WHEN @Tipo = 2 THEN '13' 
											WHEN @Tipo = 3 THEN '10,11,12,13,14'
											WHEN @Tipo = 4 THEN '11' 
										ELSE NULL end
                                        ,@IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
		drop table #tempHistorialEstatusEvaluacion;

	-- select * from [Evaluacion360].[tblEmpleadosProyectos] where IDProyecto = @IDProyecto
	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	where ep.IDProyecto = @IDProyecto 

	select
		 ee.IDEvaluacionEmpleado
		,ee.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,JSON_VALUE(cte.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
		,ee.IDEvaluador
		,eva.ClaveEmpleado as ClaveEvaluador
		,eva.NOMBRECOMPLETO as Evaluador
		,ep.IDProyecto
		,p.Nombre as Proyecto
		,ep.IDEmpleado
		,emp.ClaveEmpleado 
		,emp.NOMBRECOMPLETO as Colaborador
		,thee.IDEstatusEvaluacionEmpleado
		,thee.IDEstatus
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
		,thee.IDUsuario
		,thee.FechaCreacion		
		,isnull(ee.Progreso,0) as Progreso -- = case when isnull(thee.IDEstatus,0) = 13 then 100 else floor(RAND()*(100-0)+0) end
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee 
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = ep.IDEmpleado and dfe.IDUsuario = @IDUsuario
		left join #tempHistorialEstatusEvaluacion thee on ee.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
		join [Evaluacion360].[tblCatTiposRelaciones] cte on ee.IDTipoRelacion = cte.IDTipoRelacion
		join [RH].[tblEmpleadosMaster] emp on ep.IDEmpleado = emp.IDEmpleado
		left join [RH].[tblEmpleadosMaster] eva on ee.IDEvaluador = eva.IDEmpleado
		join [Evaluacion360].[tblCatProyectos] p on ep.IDProyecto = p.IDProyecto
	where ep.IDProyecto = @IDProyecto 
		and thee.IDEstatus in (SELECT cast(item AS int) FROM app.Split(@ListaEstatus,','))
GO

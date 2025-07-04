USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las pruebas por Evaluador según el parámetro Tipo
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-29
** Paremetros		:    
	@Tipo 1 = Las pruebas pendientes
		  2 = Las pruebas completas
		  3 = Todas las pruebas          

** DataTypes Relacionados: 


-- Si se modifica este SP será necesario modificar los siguientes:
	 [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado]

	 select * from [Evaluacion360].[tblEstatusEvaluacionEmpleado]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
/*
[Evaluacion360].[spBuscarPruebasPorEvaluador]  
					 @IDUsuario   = 1
					 ,@Tipo = 1
					,@IDEvaluador   = 1279

					*/
CREATE proc [Evaluacion360].[spBuscarPruebasPorEvaluador] (
    @IDProyecto int = 0
	,@IDEvaluador int = 0
	,@Tipo int
	,@IDUsuario int  
) AS
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	DECLARE @ListaEstatus varchar(100) = CASE 
											WHEN @Tipo = 1 THEN '11,12' 
											WHEN @Tipo = 2 THEN '13' 
											WHEN @Tipo = 3 THEN '10,11,12,13,14' 
										ELSE NULL end

		  
	declare @tempHistorialEstatusEvaluacion as table (
		IDEstatusEvaluacionEmpleado	int,
		IDEvaluacionEmpleado		int,
		IDEstatus					int,
		IDUsuario					int,
		FechaCreacion				datetime,
		[ROW]						int
	);

	declare @tempHistorialEstatusProyectos as table(
		IDEstatusProyecto int,
		IDProyecto int,
		IDEstatus int,
		Estatus varchar(255),
		IDUsuario int, 
		FechaCreacion datetime,
		[ROW] int
	)
	
	insert @tempHistorialEstatusProyectos
	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
		,tep.IDUsuario
		,tep.FechaCreacion 
		,ROW_NUMBER()over(partition by tep.IDProyecto 
							ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		inner join [Evaluacion360].[tblEmpleadosProyectos] ep on ep.IDProyecto = tcp.IDProyecto
		inner join [Evaluacion360].[tblEvaluacionesEmpleados] ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto --and ee.IDEvaluador = @IDEvaluador
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus
	where  ee.IDEvaluador = @IDEvaluador

	delete @tempHistorialEstatusProyectos
	where [ROW] != 1

	delete @tempHistorialEstatusProyectos
	where IDEstatus != 3 

	-- select * from [Evaluacion360].[tblEmpleadosProyectos] where IDProyecto = @IDProyecto
	insert @tempHistorialEstatusEvaluacion
	select 
		eee.IDEstatusEvaluacionEmpleado
		,eee.IDEvaluacionEmpleado 
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	where ep.IDProyecto = @IDProyecto or (isnull(@IDProyecto, 0) = 0)

	select
		 ee.IDEvaluacionEmpleado
		,ee.IDEmpleadoProyecto
		,ee.IDTipoRelacion	
		,CASE 
			WHEN P.IDTipoProyecto IN (3,4)
				THEN ''
				ELSE JSON_VALUE(cte.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) 
			END AS Relacion
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
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) AS Estatus
		,thee.IDUsuario
		,thee.FechaCreacion		
		,isnull(ee.Progreso,0) as Progreso-- = case when isnull(thee.IDEstatus,0) = 13 then 100 else floor(RAND()*(100-0)+0) end
		,case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador
		,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoProyecto
		,JSON_VALUE(ctee.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join @tempHistorialEstatusEvaluacion thee on ee.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
		join [Evaluacion360].[tblCatTiposRelaciones] cte with (nolock) on ee.IDTipoRelacion = cte.IDTipoRelacion
		left join [RH].[tblEmpleadosMaster] emp with (nolock) on ep.IDEmpleado = emp.IDEmpleado
		left join [RH].[tblEmpleadosMaster] eva with (nolock) on ee.IDEvaluador = eva.IDEmpleado
		join [Evaluacion360].[tblCatProyectos] p with (nolock) on ep.IDProyecto = p.IDProyecto
		LEFT JOIN Evaluacion360.tblCatTiposProyectos tp on tp.IDTipoProyecto = p.IDTipoProyecto
		left join Evaluacion360.tblCatTiposEvaluaciones ctee on ctee.IDTipoEvaluacion = ee.IDTipoEvaluacion
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = ep.IDEmpleado
	where (ep.IDProyecto in (select IDProyecto from @tempHistorialEstatusProyectos) ) 
		and ee.IDEvaluador = @IDEvaluador
		and thee.IDEstatus in (SELECT cast(item AS int) FROM app.Split(@ListaEstatus,','))
GO

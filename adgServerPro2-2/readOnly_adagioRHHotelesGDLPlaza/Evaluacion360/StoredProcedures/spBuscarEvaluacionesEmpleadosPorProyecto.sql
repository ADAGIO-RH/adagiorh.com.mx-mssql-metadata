USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las Evaluaciones por proyecto, incluyendo las que aún no han sido asignadas a Evaluadores
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-11-07
** Paremetros		:              


Si se modifica el Result set de este SP se deben de actualizar los siguientes sp's: 
	[Evaluacion360].[spActualizarProgresoProyecto]
	[Evaluacion360].[spReporteTotalEvaluacionesPorEvaluadorEstatus]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario


[Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] 81,1

[Evaluacion360].[spBuscarRelacionesProyecto] 10018
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2019-05-10		Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] ( 
	@IDProyecto int
	,@IDUsuario int
	) as

	-- Declaración de variables
	declare 
		@i int = 0
		,@j int = 0
		,@Maximo int = 0
		,@Minimo int = 0
		,@IDTipoRelacion int = 0
		,@IDEvaluadorRequerido int = 0
		,@AutoevaluacionNoEsRequerida bit = 0
	;

 -- Autoevaluacion no es requerida
	select @AutoevaluacionNoEsRequerida = cast(isnull(valor,0) as bit) 
	from Evaluacion360.tblConfiguracionAvanzadaProyecto 
	where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 9


	-- Se valida si las tablas temporales existen, en caso de que si existan se eliminan y se vuelven a crear.
	if object_id('tempdb..#tempEmpPro') is not null
		drop table #tempEmpPro;
	if object_id('tempdb..#tempEvaEmp') is not null
		drop table #tempEvaEmp;
	if object_id('tempdb..#tempRequeridos') is not null
		drop table #tempRequeridos;
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
		drop table #tempHistorialEstatusEvaluacion;

	create table #tempRequeridos(
		IDTipoRelacion int
		,Codigo	varchar(20)
		,Relacion varchar(255)
		,Minimo int
		,Maximo int
	);

	-- Se crean tantos registros como evaluadores máximos requeridos según las restricciones del proyecto.
	select @IDEvaluadorRequerido=min(IDEvaluadorRequerido) from [Evaluacion360].[tblEvaluadoresRequeridos]  WHERE IDProyecto = @IDProyecto

	while exists(select top 1 1 
				from [Evaluacion360].[tblEvaluadoresRequeridos]  
				WHERE IDProyecto = @IDProyecto AND IDEvaluadorRequerido >= @IDEvaluadorRequerido)
	begin
		select 
			@IDTipoRelacion = IDTipoRelacion
			,@Maximo = Maximo
			,@Minimo = Minimo
		from [Evaluacion360].[tblEvaluadoresRequeridos] 
		where IDEvaluadorRequerido = @IDEvaluadorRequerido
		
		set @j = 1;
		while @j <= @Maximo
		begin
			insert into #tempRequeridos(IDTipoRelacion,Minimo,Maximo)
			select @IDTipoRelacion,@Minimo,@Maximo

			set @j = @j + 1;
		end;
		
		select @IDEvaluadorRequerido=min(IDEvaluadorRequerido) 
		from [Evaluacion360].[tblEvaluadoresRequeridos]  
		WHERE IDProyecto = @IDProyecto  AND IDEvaluadorRequerido > @IDEvaluadorRequerido
	end;
	

	-- Se actualiza el nombre del tipo de relación y el Código
	update er
	set er.Relacion = cte.Relacion
		,er.Codigo = cte.Codigo 
	from [Evaluacion360].[tblCatTiposRelaciones] cte
		join #tempRequeridos er on cte.IDTipoRelacion = er.IDTipoRelacion

	-- Se crea la tabla temporal #tempEmpPro haciendo un cross join con la tabla #tempRequeridos 
	-- para que se múltipliquen los registros según correspondan con las restricciones del proyecto
	select  
		ep.IDEmpleadoProyecto
		,ep.IDProyecto
		,ep.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,0 as IDEvaluacionEmpleado
		,isnull(req.IDTipoRelacion,0) as IDTipoRelacion
		,req.Relacion
		,0 as IDEvaluador
		,cast('' as varchar(20)) ClaveEvaluador
		,cast('' as varchar(255)) as Evaluador
		--,cast(0 as bit) as Completo
		,req.Minimo
		,req.Maximo
		,Requerido = 
		case 
			when req.IDTipoRelacion = 4 and @AutoevaluacionNoEsRequerida = 0 then cast(1 as bit) 
			when (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo) and 
				(ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= isnull(totalRelaciones.Total,0)) then cast(1 as bit) else cast(0 as bit) end
			--case when ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion 
			--		order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo then cast(1 as bit) else cast(0 as bit) end
		,CumpleTipoRelacion = case 
				when req.IDTipoRelacion = 4 then cast(1 as bit)
				when (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= isnull(totalRelaciones.Total,0)) then cast(1 as bit) else cast(0 as bit) end
		,ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) as [Row]
	INTO #tempEmpPro
	from [Evaluacion360].[tblEmpleadosProyectos] ep 
	--	left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [RH].[tblEmpleadosMaster] e on ep.IDEmpleado = e.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		cross join  #tempRequeridos req  --on ee.IDTipoRelacion = req.IDTipoRelacion
		left join RH.tblTotalRelacionesEmpleados totalRelaciones on totalRelaciones.IDEmpleado = ep.IDEmpleado and req.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	where ep.IDProyecto = @IDProyecto

	delete from #tempEmpPro where CumpleTipoRelacion = 0

	select ee.IDEvaluacionEmpleado
		,ep.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,ee.IDEvaluador
		,ep.IDProyecto
		,ep.IDEmpleado
		--,e.NOMBRECOMPLETO as Evaluador
		,ROW_NUMBER()over(partition by ep.IDEmpleado,ee.IDTipoRelacion order by ep.IDEmpleado,ee.IDTipoRelacion) as [Row]
	INTO #tempEvaEmp
	from  [Evaluacion360].[tblEvaluacionesEmpleados] ee
		left join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
		--									and ee.IDTipoRelacion = emp.IDTipoRelacion
		--								--	and ee.[Row] = emp.[Row]
		--left join [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado	
		where ep.IDProyecto = @IDProyecto

	update emp
	set emp.IDEvaluador = isnull(ee.IDEvaluador,0)
	 	,emp.Evaluador = isnull(e.NOMBRECOMPLETO,'[Sin evaluador asignado]')
		,emp.ClaveEvaluador = isnull(e.ClaveEmpleado,'[00000]')
		,emp.IDEvaluacionEmpleado = isnull(ee.IDEvaluacionEmpleado,0) 
		--,emp.Completo = case when emp.[Row] >= Maximo and isnull(ee.IDEvaluacionEmpleado,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
	from #tempEmpPro emp
		left join #tempEvaEmp ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
											and ee.IDTipoRelacion = emp.IDTipoRelacion and emp.[Row] = ee.[Row]
		left join [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado

	--#tempHistorialEstatusEvaluacion
	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	where ep.IDProyecto = @IDProyecto 

	select ep.* 
		,isnull(thee.IDEstatusEvaluacionEmpleado,0) IDEstatusEvaluacionEmpleado
		,isnull(thee.IDEstatus,0) IDEstatus
		,isnull(estatus.Estatus,'Sin estatus') Estatus
		,isnull(Progreso,0) as Progreso --= case when isnull(thee.IDEstatus,0) != 0 then floor(RAND()*(100-0)+0) else 0 end
	from #tempEmpPro ep 
		left join #tempHistorialEstatusEvaluacion thee on ep.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
		
	order by Colaborador,Evaluador desc

	--SELECT floor(RAND()*(100-0)+0);

	--select *
	--from [Evaluacion360].[tblEstatusEvaluacionEmpleado]
	--order by IDEvaluacionEmpleado
GO

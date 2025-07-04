USE [p_adagioRHIndustrialMefi]
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


[Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] 53,1,0

[Evaluacion360].[spBuscarRelacionesProyecto] 10018
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2019-05-10			Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2022-10-05			Alejandro Paredes	Se agrego la busqueda por empleado y se filtrar los empleados excluidos
2023-02-03			Aneudy Abreu		En la creación de la tabla temporal #tempEvaEmp se le agregó la columna isnull(ee.IDEvaluador, 9999)
											al order by del campo [Row].
										Esto corrige el bug que pasa cuando cambian el máximo de evaluadores requeridos
										en un tipo de relación de un número mayor a uno menor.
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] (  
	@IDProyecto int
	,@IDUsuario int
	,@IDEmpleado int = 0
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
	    ,@IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma',@IDUsuario , 'esmx')

 -- Autoevaluacion no es requerida
	select @AutoevaluacionNoEsRequerida = cast(isnull(valor,0) as bit) 
	from Evaluacion360.tblConfiguracionAvanzadaProyecto 
	where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 9

	-- Se valida si las tablas temporales existen, en caso de que si existan se eliminan y se vuelven a crear.
	if object_id('tempdb..#tempEmpPro') is not null drop table #tempEmpPro;
	if object_id('tempdb..#tempEvaEmp') is not null drop table #tempEvaEmp;
	if object_id('tempdb..#tempRequeridos') is not null drop table #tempRequeridos;
	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;

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
			@IDTipoRelacion = er.IDTipoRelacion
			,@Minimo = er.Minimo
			,@Maximo = case 
							when isnull(@IDEmpleado, 0) = 0 then er.Maximo
							when (select count(*) 
									from Evaluacion360.tblEmpleadosProyectos ep
										join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
									where ep.IDEmpleado = @IDEmpleado and ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion = er.IDTipoRelacion)
									> er.Maximo then (select count(*) 
									from Evaluacion360.tblEmpleadosProyectos ep
										join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
									where ep.IDEmpleado = @IDEmpleado and ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion = er.IDTipoRelacion)
						else er.Maximo end

		from [Evaluacion360].[tblEvaluadoresRequeridos] er
		where er.IDEvaluadorRequerido = @IDEvaluadorRequerido
		
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
	set er.Relacion = JSON_VALUE(cte.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion'))
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
		,CAST(0 as bit) as Requerido
		,CAST(0 as bit) as CumpleTipoRelacion
		,ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) as [Row]
	INTO #tempEmpPro
	from [Evaluacion360].[tblEmpleadosProyectos] ep 
		join [RH].[tblEmpleadosMaster] e on ep.IDEmpleado = e.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		cross join  #tempRequeridos req  --on ee.IDTipoRelacion = req.IDTipoRelacion
		left join RH.tblTotalRelacionesEmpleados totalRelaciones on totalRelaciones.IDEmpleado = ep.IDEmpleado and req.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	where ep.IDProyecto = @IDProyecto AND
		  EP.TipoFiltro != 'Excluir Empleado' AND
		  ((EP.IDEmpleado = @IDEmpleado OR ISNULL(@IDEmpleado, 0) = 0))

	update temp 
		set 
			Requerido = CASE 
							-- 4 = AUTOEVALUACIÓN
							WHEN temp.IDTipoRelacion = 4 AND @AutoevaluacionNoEsRequerida = 0			THEN CAST(1 AS BIT) 
							-- 6 = CLIENTE INTERNO
							WHEN ([Row] <= temp.Minimo) AND ([Row] <= ISNULL(totalRelaciones.Total, 0)) THEN CAST(1 AS BIT)
							WHEN ([Row] <= (
									select count(*) 
									from Evaluacion360.tblEvaluacionesEmpleados ee
									where ee.IDEmpleadoProyecto = temp.IDEmpleadoProyecto and ee.IDTipoRelacion = temp.IDTipoRelacion
							)) THEN CAST(1 as BIT)
							WHEN temp.IDTipoRelacion = 6 AND [Row] <= temp.Minimo THEN CAST(1 AS BIT) 

						ELSE 
							CAST(0 AS BIT) 
						END,
		   CumpleTipoRelacion = CASE 
									-- 4 = AUTOEVALUACIÓN
									-- 6 = CLIENTE INTERNO
									WHEN temp.IDTipoRelacion in (4,6)						THEN 1
									WHEN ([Row] <= (
										select count(*) 
										from Evaluacion360.tblEvaluacionesEmpleados ee
										where ee.IDEmpleadoProyecto = temp.IDEmpleadoProyecto and ee.IDTipoRelacion = temp.IDTipoRelacion
									)) THEN CAST(1 as BIT)
									WHEN ([Row] <= ISNULL(totalRelaciones.Total, 0))	THEN CAST(1 AS BIT) 
								ELSE 
									CAST(0 AS BIT)
								END
	from #tempEmpPro temp
		LEFT JOIN RH.tblTotalRelacionesEmpleados totalRelaciones WITH (NOLOCK) ON totalRelaciones.IDEmpleado = temp.IDEmpleado AND temp.IDTipoRelacion = totalRelaciones.IDTipoRelacion

	delete from #tempEmpPro where CumpleTipoRelacion = 0

	select ee.IDEvaluacionEmpleado
		,ep.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,ee.IDEvaluador
		,ep.IDProyecto
		,ep.IDEmpleado
		--,e.NOMBRECOMPLETO as Evaluador
		,ROW_NUMBER()over(partition by ep.IDEmpleado,ee.IDTipoRelacion order by ep.IDEmpleado,ee.IDTipoRelacion, isnull(ee.IDEvaluador, 9999)) as [Row]
	INTO #tempEvaEmp
	from  [Evaluacion360].[tblEvaluacionesEmpleados] ee
		left join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		where ep.IDProyecto = @IDProyecto AND
			  EP.TipoFiltro != 'Excluir Empleado' AND
			 ((EP.IDEmpleado = @IDEmpleado OR ISNULL(@IDEmpleado, 0) = 0))

	update emp
	set emp.IDEvaluador = isnull(ee.IDEvaluador,0)
	 	,emp.Evaluador = isnull(e.NOMBRECOMPLETO,'[Sin evaluador asignado]')
		,emp.ClaveEvaluador = isnull(e.ClaveEmpleado,'[00000]')
		,emp.IDEvaluacionEmpleado = isnull(ee.IDEvaluacionEmpleado,0) 
	from #tempEmpPro emp
		left join #tempEvaEmp ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
											and ee.IDTipoRelacion = emp.IDTipoRelacion and emp.[Row] = ee.[Row]
		left join [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado

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
	where ep.IDProyecto = @IDProyecto AND
		  EP.TipoFiltro != 'Excluir Empleado' AND
		  ((EP.IDEmpleado = @IDEmpleado OR ISNULL(@IDEmpleado, 0) = 0)) 
		  
	select ep.* 
		,isnull(thee.IDEstatusEvaluacionEmpleado,0) IDEstatusEvaluacionEmpleado
		,isnull(thee.IDEstatus,0) IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') Estatus
		,isnull(Progreso,0) as Progreso --= case when isnull(thee.IDEstatus,0) != 0 then floor(RAND()*(100-0)+0) else 0 end
		,ISNULL(SUBSTRING (E.Nombre, 1, 1) + SUBSTRING (E.Paterno, 1, 1), 'SE') Iniciales
		,CASE
			WHEN EP.IDTipoRelacion = 4
				THEN CAST(0 AS BIT)
				ELSE CAST(1 AS BIT)
			END AS Evaluar
	from #tempEmpPro ep 
		left join #tempHistorialEstatusEvaluacion thee on ep.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
		left join [RH].[tblEmpleadosMaster] E ON EP.IDEvaluador = E.IDEmpleado
	order by ep.Relacion desc, Evaluador desc
GO

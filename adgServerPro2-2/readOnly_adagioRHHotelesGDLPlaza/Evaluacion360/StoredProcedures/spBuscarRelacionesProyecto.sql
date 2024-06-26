USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las posibles evaluaciones del proyecto según las restrucciones que cumplan los colaboradores
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de este sp será necesario modificar los siguientes sp's:
		- [Evaluacion360].[spAsignacionAutomaticaEvaluadores]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarRelacionesProyecto] (
	@IDEmpleado int = 0
	,@IDEvaluador int = 0
	,@IDProyecto int 
	,@IDUsuario int
)as
	SET FMTONLY OFF

	declare 	
		 @i int = 0
		,@j int = 0
		,@IDTipoRelacion int = 0
		,@Maximo int = 0
		,@Minimo int = 0
		,@AutoevaluacionNoEsRequerida bit = 0
	;

 -- Autoevaluacion no es requerida
	select @AutoevaluacionNoEsRequerida = cast(isnull(valor,0) as bit) 
	from Evaluacion360.tblConfiguracionAvanzadaProyecto  with (nolock) 
	where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 9

	if object_id('tempdb..#tempRequeridos') is not null
		drop table #tempRequeridos;

	create table #tempRequeridos(
		IDTipoRelacion int
		,Codigo	varchar(20)
		,Relacion varchar(255)
		,Minimo int
	);

	select @i = min(IDTipoRelacion) from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)  where IDProyecto = @IDProyecto

	while exists(select top 1 1 
				from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)  
				where IDProyecto = @IDProyecto and IDTipoRelacion >= @i)
	begin
		select @IDTipoRelacion = IDTipoRelacion
			,@Maximo = Maximo
			,@Minimo = Minimo
		from [Evaluacion360].[tblEvaluadoresRequeridos]  with (nolock) 
		where IDProyecto = @IDProyecto and IDTipoRelacion = @i 
		
		set @j = 1;
		while @j <= @Maximo
		begin
			insert into #tempRequeridos(IDTipoRelacion,Minimo)
			select @IDTipoRelacion,@Minimo

			set @j = @j + 1;
		end;

		select @i = min(IDTipoRelacion) 
		from [Evaluacion360].[tblEvaluadoresRequeridos]  with (nolock) 
		where IDProyecto = @IDProyecto and IDTipoRelacion > @i
	end;

	update er
	set er.Relacion = cte.Relacion
		,er.Codigo = cte.Codigo 
	from [Evaluacion360].[tblCatTiposRelaciones] cte with (nolock) 
		join #tempRequeridos er on cte.IDTipoRelacion = er.IDTipoRelacion
	 
	if object_id('tempdb..#tempEmpPro') is not null
		drop table #tempEmpPro;
		
	select  
		ep.IDEmpleadoProyecto
		,ep.IDProyecto
		,ep.IDEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,0 as IDEvaluacionEmpleado
		,isnull(req.IDTipoRelacion,0) as IDTipoRelacion
		,req.Relacion
		,0 as IDEvaluador
		,cast('' as varchar(255)) as Evaluador
		,Requerido = 
			case 
				when req.IDTipoRelacion = 4 and @AutoevaluacionNoEsRequerida = 0 then cast(1 as bit) 
				when 					 
					 (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo) and 
					 (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= isnull(totalRelaciones.Total,0)) then cast(1 as bit) 
						else cast(0 as bit) end
		,CumpleTipoRelacion = case 
				when req.IDTipoRelacion = 4 then 1
				when (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= isnull(totalRelaciones.Total,0)) then cast(1 as bit) else cast(0 as bit) end
		,ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) as [Row]
	into #tempEmpPro
	from [Evaluacion360].[tblEmpleadosProyectos] ep  with (nolock) 
	--	left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [RH].[tblEmpleadosMaster] e with (nolock)  on ep.IDEmpleado = e.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		cross join  #tempRequeridos req  --on ee.IDTipoRelacion = req.IDTipoRelacion
		left join RH.tblTotalRelacionesEmpleados totalRelaciones with (nolock)  on totalRelaciones.IDEmpleado = ep.IDEmpleado and req.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	where (ep.IDEmpleado = @IDEmpleado or @IDEmpleado = 0) 
	--and (ee.IDEvaluador = @IDEvaluador or @IDEvaluador = 0) 
	and ep.IDProyecto = @IDProyecto

	delete from #tempEmpPro where CumpleTipoRelacion = 0

	--#tempRequeridos req  
	--	left join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	--	left join [Evaluacion360].[tblEvaluacionesEmpleados] ee on ee.IDTipoRelacion = req.IDTipoRelacion
					--and  ep.IDProyecto = @IDProyecto

	if object_id('tempdb..#tempEvaEmp') is not null
		drop table #tempEvaEmp;

	select ee.IDEvaluacionEmpleado
		,ep.IDEmpleadoProyecto
		,ee.IDTipoRelacion
		,ee.IDEvaluador
		,ep.IDProyecto
		,ep.IDEmpleado
		,e.NOMBRECOMPLETO as Evaluador
		,ROW_NUMBER()over(partition by ep.IDEmpleado,ee.IDTipoRelacion order by ep.IDEmpleado,ee.IDTipoRelacion) as [Row]
	INTO #tempEvaEmp
	from  [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock) 
		left join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock)  on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		--left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
		--									and ee.IDTipoRelacion = emp.IDTipoRelacion
		--								--	and ee.[Row] = emp.[Row]
		left join [RH].[tblEmpleadosMaster] e with (nolock)  on ee.IDEvaluador = e.IDEmpleado	
	where ep.IDProyecto = @IDProyecto
	order by ee.IDEvaluacionEmpleado asc


	update emp
	set emp.IDEvaluador = isnull(ee.IDEvaluador,0)
	 	,emp.Evaluador = isnull(ee.Evaluador,'[Sin evaluador asignado]')
		,emp.IDEvaluacionEmpleado = isnull(ee.IDEvaluacionEmpleado,0) 
	from #tempEmpPro emp
		left join #tempEvaEmp ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
											and ee.IDTipoRelacion = emp.IDTipoRelacion and emp.[Row] = ee.[Row]

	
	update emp
	set emp.IDEvaluador = isnull(ee.IDEvaluador,0)
	 	,emp.Evaluador = isnull(ee.Evaluador,'[Sin evaluador asignado]')
		,emp.IDEvaluacionEmpleado = isnull(ee.IDEvaluacionEmpleado,0) 
	from #tempEmpPro emp
		left join #tempEvaEmp ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
											and ee.IDTipoRelacion = emp.IDTipoRelacion and emp.[Row] = ee.[Row]
										--	and ee.[Row] = emp.[Row]
		--left join [RH].[tblEmpleadosMaster] e on ee.IDEmpleado = e.IDEmpleado
		
	
	select IDEmpleadoProyecto
		,IDProyecto
		,IDEmpleado
		,Colaborador
		,IDEvaluacionEmpleado
		,IDTipoRelacion
		,Relacion
		,IDEvaluador
		,Evaluador
		,Requerido 
	from #tempEmpPro
	where IDEvaluador = @IDEvaluador or @IDEvaluador = 0
	order by IDTipoRelacion asc,IDEvaluacionEmpleado desc,Requerido asc
GO

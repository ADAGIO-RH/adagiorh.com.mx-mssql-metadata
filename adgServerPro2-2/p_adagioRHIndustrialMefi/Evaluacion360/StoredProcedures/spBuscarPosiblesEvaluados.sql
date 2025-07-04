USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca los posibles colaboradores que el @IDEmpleado puede Evaluar según el @IDTipoRelacion
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@gmail.com
** FechaCreacion	: 2018-10-29
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-23			Aneudy Abreu		Se cambió la table temporal #tempEmps por un nuevo dataType @tempEmps(RH.dtInfoOrganigrama)
2022-09-22			Alejandro Paredes	Se agrego la paginación
***************************************************************************************************/
/*
 [Evaluacion360].[spBuscarPosiblesEvaluados] 
		@IDEmpleado   = 72
		,@IDTipoRelacion  = 2
		,@IDUsuario  = 1
		,@IDProyecto = 1	

			exec [RH].[spBuscarInfoOrganigramaEmpleado]
				 @IDEmpleado = 72  
				,@IDTipoRelacion = 2
				,@IDUsuario = 1

			exec [Evaluacion360].[spBuscarPosiblesEvaluados] 
		@IDEmpleado =   1279 
		,@IDTipoRelacion = 1  
		,@IDProyecto = 11 
		,@IDUsuario = 1

	--	select * from [RH].[tblJefesEmpleados] where IDJefe = 20310
*/
CREATE proc [Evaluacion360].[spBuscarPosiblesEvaluados]( 
		@IDEmpleado int,
		@IDTipoRelacion int,
		@IDProyecto int,
		@IDUsuario int, 	
		@PageNumber	INT = 1,
		@PageSize INT = 2147483647,
		@query VARCHAR(100) = '""',
		@orderByColumn	VARCHAR(50) = '',
		@orderDirection VARCHAR(4) = ''
	) as

	SET FMTONLY OFF;

	declare 
		@i int = 0
		,@j int = 0
		,@Maximo int = 0
		,@Minimo int = 0
		,@Relacion varchar(255) = null
		,@tempEmps RH.dtInfoOrganigrama
		,@TotalPaginas INT = 0
		,@TotalRegistros DECIMAL(18,2) = 0.00
        ,@IDIdioma VARCHAR(max)

        select @IDIdioma=app.fnGetPreferencia('Idioma',@IDUsuario,'esmx')


		IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
		IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

		SELECT
			 @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Total' ELSE @orderByColumn END,
			 @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'DESC' ELSE @orderDirection END

   
		SET @query = CASE
						WHEN @query IS NULL THEN '""'
						WHEN @query = '' THEN '""'
						WHEN @query = '""' THEN @query
					ELSE '"' + @query + '*"' END


		DECLARE @tempResponse AS TABLE (
			IDEmpleado INT,
			ClaveEmpleado VARCHAR(50),
			Colaborador VARCHAR(150),
			Iniciales VARCHAR(2),
			Relacion VARCHAR(50),
			Total INT
		);



		select top 1 @Relacion = JSON_VALUE(Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) 
		from [Evaluacion360].[tblCatTiposRelaciones]
		where IDTipoRelacion = case when @IDTipoRelacion = 1 then 2
									when @IDTipoRelacion = 2 then 1 else @IDTipoRelacion end

	if object_id('tempdb..#tempRequeridos') is not null
		drop table #tempRequeridos;

	create table #tempRequeridos(
		IDTipoRelacion int
		,Codigo	varchar(20)
		,Relacion varchar(255)
		,Minimo int
		,Maximo int
	);

	--if object_id('tempdb..#tempEmps') is not null
	--	drop table #tempEmps;

	--create table #tempEmps(
	--	IDJefeEmpleado int
	--	,IDEmpleado int
	--	,ClaveEmpleado varchar(255)
	--	,NombreEmpleado varchar(255)
	--	,IDJefe int
	--	,ClaveJefe varchar(255)
	--	,NombreJefe varchar(255)
	--	,IDTipoRelacion int
	--);

	if object_id('tempdb..#tempEmpPro') is not null
		drop table #tempEmpPro;


	create table #tempEmpPro(
			  IDEmpleadoProyecto int
			, IDProyecto		 int
			, IDEmpleado		 int
			,ClaveEmpleado varchar(20)
			,Colaborador varchar(500)
			,Iniciales VARCHAR(2)
			,IDEvaluacionEmpleado int
			, IDTipoRelacion int
			--,req.Relacion
			, IDEvaluador int
			, Evaluador  varchar(500)
			--,cast(0 as bit) as Completo
			, Maximo int
			--,Requerido = 
			--	case when ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion 
			--			order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo then cast(1 as bit) else cast(0 as bit) end
			,[Row] int
		);

	select 
		@Maximo = Maximo
		,@Minimo = Minimo
	from [Evaluacion360].[tblEvaluadoresRequeridos] 
	where IDProyecto = @IDProyecto and IDTipoRelacion =  case when @IDTipoRelacion = 1 then 2
									when @IDTipoRelacion = 2 then 1 else @IDTipoRelacion end 
		
	set @j = 1;
	while @j <= @Maximo
	begin
		insert into #tempRequeridos(IDTipoRelacion,Minimo,Maximo)
		select @IDTipoRelacion,@Minimo,@Maximo

		set @j = @j + 1;
	end;
	 
	update er
	set er.Relacion =JSON_VALUE(cte.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) 
		,er.Codigo = cte.Codigo 
	from [Evaluacion360].[tblCatTiposRelaciones] cte
		join #tempRequeridos er on cte.IDTipoRelacion = er.IDTipoRelacion

-- select * from #tempRequeridos



	insert @tempEmps
	exec [RH].[spBuscarInfoOrganigramaEmpleado]
				 @IDEmpleado = @IDEmpleado  
				,@IDTipoRelacion = @IDTipoRelacion 
				,@IDUsuario = @IDUsuario

	--Se eliminan los colaboradores que no están asígnados al proyecto
	if (@IDTipoRelacion = 1 ) 
	begin 
		delete from @tempEmps
		where IDJefe not in (
				select IDEmpleado 
				from  [Evaluacion360].[tblEmpleadosProyectos] ep 
				where ep.IDProyecto = @IDProyecto )
	end else
	begin
		delete from @tempEmps
		where IDEmpleado not in (
				select IDEmpleado 
				from  [Evaluacion360].[tblEmpleadosProyectos] ep 
				where ep.IDProyecto = @IDProyecto )
	end

	----Se eliminan los Jefes que no están asígnados al proyecto
	--delete from #tempEmps
	--where IDJefe not in (
	--		select IDEmpleado 
	--		from  [Evaluacion360].[tblEmpleadosProyectos] ep 
	--		where ep.IDProyecto = @IDProyecto )
 
	-- Se eliminan los colaboradores que ya está de alguna manera asignados a Evaluador
	delete from @tempEmps
	where IDEmpleado in (select IDEmpleado 
						from  [Evaluacion360].[tblEmpleadosProyectos] ep 
							join [Evaluacion360].[tblEvaluacionesEmpleados]  ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
						where ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion = @IDTipoRelacion and ee.IDEvaluador = @IDEmpleado
						--UNION
						--select @IDEmpleado as IDEmpleado
						)
 -- select * from #tempEmps
	if (@IDTipoRelacion <> 1)
	begin
		insert #tempEmpPro
		select  
			ep.IDEmpleadoProyecto
			,ep.IDProyecto
			,ep.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Colaborador
			,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1) as Iniciales
			,0 as IDEvaluacionEmpleado
			,isnull(req.IDTipoRelacion,0) as IDTipoRelacion
			--,req.Relacion
			,0 as IDEvaluador
			,cast('' as varchar(255)) as Evaluador
			--,cast(0 as bit) as Completo
			,req.Maximo
			--,Requerido = 
			--	case when ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion 
			--			order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo then cast(1 as bit) else cast(0 as bit) end
			,ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) as [Row]
		from [Evaluacion360].[tblEmpleadosProyectos] ep 
		--	left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			left join [RH].[tblEmpleadosMaster] e on ep.IDEmpleado = e.IDEmpleado
			cross join  #tempRequeridos req  --on ee.IDTipoRelacion = req.IDTipoRelacion
		where ep.IDEmpleado in (select IDEmpleado from @tempEmps) AND
		--and (ee.IDEvaluador = @IDEvaluador or @IDEvaluador = 0) 
		EP.TipoFiltro != 'Excluir Empleado'
		and ep.IDProyecto = @IDProyecto 
		and (@query = '""' OR CONTAINS(e.*, @query))

	end else
	begin
		insert #tempEmpPro
		select  
			ep.IDEmpleadoProyecto
			,ep.IDProyecto
			,ep.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Colaborador
			,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1) as Iniciales
			,0 as IDEvaluacionEmpleado
			,isnull(req.IDTipoRelacion,0) as IDTipoRelacion
			--,req.Relacion
			,0 as IDEvaluador
			,cast('' as varchar(255)) as Evaluador
			--,cast(0 as bit) as Completo
			,req.Maximo
			--,Requerido = 
			--	case when ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion 
			--			order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo then cast(1 as bit) else cast(0 as bit) end
			,ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) as [Row]
		
		from [Evaluacion360].[tblEmpleadosProyectos] ep 
			--left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
			join @tempEmps tt  on ep.IDEmpleado = tt.IDJefe
			left join [RH].[tblEmpleadosMaster] e on tt.IDJefe = e.IDEmpleado
			cross join  #tempRequeridos req  --on ee.IDTipoRelacion = req.IDTipoRelacion
		where 
		--ep.IDEmpleado in (select IDJefe from #tempEmps)
		--and (ee.IDEvaluador = @IDEvaluador or @IDEvaluador = 0) 
		--and
		 EP.TipoFiltro != 'Excluir Empleado' AND
		 ep.IDProyecto = @IDProyecto 
		 and (@query = '""' OR CONTAINS(e.*, @query))
	end;
	

	--select * from #tempEmpPro
	--select IDEmpleado from #tempEmps


	if object_id('tempdb..#tempEvaEmp') is not null
		drop table #tempEvaEmp;


		-- ¿Puedo agregar el filtro de tipo de relación aquí?
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
		where ep.IDEmpleado in (select case when @IDTipoRelacion = 1 then IDJefe else IDEmpleado  end from @tempEmps)
	--and (ee.IDEvaluador = @IDEvaluador or @IDEvaluador = 0) 
	and ep.IDProyecto = @IDProyecto
	and ee.IDEvaluador = @IDEmpleado

--	select * from #tempEvaEmp
	update emp
	set emp.IDEvaluador = isnull(ee.IDEvaluador,0)
	 --	,emp.Evaluador = isnull(ee.Evaluador,'[Sin evaluador asignado]')
		,emp.IDEvaluacionEmpleado = isnull(ee.IDEvaluacionEmpleado,0) 
		--,emp.Completo = case when emp.[Row] >= Maximo and isnull(ee.IDEvaluacionEmpleado,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
	from #tempEmpPro emp
		left join #tempEvaEmp ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
											and ee.IDTipoRelacion = emp.IDTipoRelacion and emp.[Row] = ee.[Row]
	if (@IDTipoRelacion = 1)
	begin
		update emp
		set emp.IDEmpleado = e.IDEmpleado
			,emp.ClaveEmpleado = e.ClaveJefe
		 ,emp.Colaborador = e.Jefe
		from #tempEmpPro emp
			join @tempEmps e on emp.IDEmpleado = e.IDEmpleado
	end

--select * from #tempEmpPro
	--select IDEmpleado
	--		, IDTipoRelacion
	--		--, Relacion
	--		, Maximo
	--		, sum(case when IDEvaluador <> 0 then 1 else  0 end) as Total
	--	from #tempEmpPro
	--	group by IDEmpleado,IDTipoRelacion,Maximo 


	delete t
	from Evaluacion360.tblEmpleadosProyectos ep
		join Evaluacion360.tblEvaluacionesEmpleados ee on ep.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
		join #tempEmpPro t on ep.IDEmpleado = t.IDEmpleado
	where ep.IDProyecto = @IDProyecto and ee.IDEvaluador = @IDEmpleado

	

	INSERT @tempResponse
	select distinct 
		 e.IDEmpleado
		,e.ClaveEmpleado
		,e.Colaborador
		,e.Iniciales
		,@Relacion as Relacion
		,t.Total
	from #tempEmpPro e
	 join (
		select IDEmpleado
			, IDTipoRelacion
			--, Relacion
			, Maximo
			, sum(case when IDEvaluador <> 0 then 1 else  0 end) as Total
		from #tempEmpPro
		group by IDEmpleado,IDTipoRelacion,Maximo ) t on e.IDEmpleado = t.IDEmpleado and t.Maximo > t.Total
	--order by t.Total desc


	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDEmpleado]) AS DECIMAL(18,2)) FROM @tempResponse

	SELECT *,
			TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			CAST(@TotalRegistros AS INT) AS TotalRows
	FROM @tempResponse
	ORDER BY
		CASE WHEN @orderByColumn = 'IDEmpleado'	and @orderDirection = 'asc'	THEN IDEmpleado END,
		CASE WHEN @orderByColumn = 'IDEmpleado'	and @orderDirection = 'desc' THEN IDEmpleado END DESC,
		CASE WHEN @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'asc'	THEN ClaveEmpleado END,
		CASE WHEN @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'desc' THEN ClaveEmpleado END DESC,
		CASE WHEN @orderByColumn = 'Colaborador' and @orderDirection = 'asc' THEN Colaborador END,
		CASE WHEN @orderByColumn = 'Colaborador' and @orderDirection = 'desc' THEN Colaborador END DESC,
		CASE WHEN @orderByColumn = 'Relacion' and @orderDirection = 'asc' THEN Relacion END,
		CASE WHEN @orderByColumn = 'Relacion' and @orderDirection = 'desc' THEN Relacion END DESC,
		CASE WHEN @orderByColumn = 'Total' and @orderDirection = 'asc' THEN Total END,
		CASE WHEN @orderByColumn = 'Total' and @orderDirection = 'desc' THEN Total END DESC,
		Total DESC, IDEmpleado
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);




--	select * from #tempEmpPro
	--select IDEmpleado
	--		, IDTipoRelacion
	--		--, Relacion
	--		, Maximo
	--		, sum(case when IDEvaluador <> 0 then 1 else  0 end) as Total
	--	from #tempEmpPro
	--	group by IDEmpleado,IDTipoRelacion,Maximo
--select * from rh.tblJefesEmpleados
--select * from Evaluacion360.tblCatTiposRelaciones


--select * from Evaluacion360.tblEmpleadosProyectos
--where IDEmpleado in (
--149
--,2953
--,4976
--,5416)
GO

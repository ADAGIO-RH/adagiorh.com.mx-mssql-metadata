USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create    proc [Evaluacion360].[spBuscarColaboradoresAEvaluar](
	 @IDProyecto	int
	,@IDUsuario		int
	,@PageNumber		int = 1
	,@PageSize			int = 2147483647
	,@query				varchar(100) = ''
	,@orderByColumn		varchar(50) = 'Codigo'
	,@orderDirection	varchar(4) = 'asc'
) as
	declare  
		@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'ClaveEmpleado' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if OBJECT_ID('tempdb..#tempResponse') is not null drop table #tempResponse;

	select *
	INTO #tempResponse
	from (
		select ep.IDEmpleadoProyecto
				,ep.IDProyecto
				,ep.IDEmpleado
				,em.ClaveEmpleado
				,em.NOMBRECOMPLETO
				,em.Departamento
				,em.Sucursal
				,em.Puesto
				,isnull(ep.TipoFiltro,'Empleados') as TipoFiltro
		from [Evaluacion360].[tblEmpleadosProyectos] ep  with (nolock)
			join [RH].[tblEmpleadosMaster] em  with (nolock) on ep.IDEmpleado = em.IDEmpleado
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
			join [Evaluacion360].[tblCatProyectos] p with (nolock) on ep.IDProyecto = p.IDProyecto
		where (ep.IDProyecto = @IDProyecto) 
		--order by em.ClaveEmpleado
		UNION ALL
		select
			0 IDEmpleadoProyecto
			,fp.IDProyecto
			,em.IDEmpleado
			,em.ClaveEmpleado
			,em.NOMBRECOMPLETO
			,em.Departamento
			,em.Sucursal
			,em.Puesto
			,fp.TipoFiltro
		from Evaluacion360.tblFiltrosProyectos fp
			join RH.tblEmpleadosMaster em on em.IDEmpleado = CAST(fp.ID as int)
		where IDProyecto = @IDProyecto and TipoFiltro = 'Excluir Empleado'
	) info
	where 
		(ISNULL(@query, '') = '') or
		(
			(info.ClaveEmpleado like '%'+@query+'%') or
			(info.NOMBRECOMPLETO like '%'+@query+'%') or
			(info.Departamento like '%'+@query+'%') or
			(info.Sucursal like '%'+@query+'%') or
			(info.Puesto like '%'+@query+'%') or
			(info.TipoFiltro like '%'+@query+'%') 
		)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = cast(COUNT(IDEmpleadoProyecto) as decimal(18,2)) from #tempResponse		
	
	select
		*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempResponse
	order by TipoFiltro, ClaveEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


	--select *
	--from Evaluacion360.tblEstatusProyectos
	--where IDProyecto = 35

	--delete Evaluacion360.tblEstatusProyectos
	--where IDEstatusProyecto = 81
GO

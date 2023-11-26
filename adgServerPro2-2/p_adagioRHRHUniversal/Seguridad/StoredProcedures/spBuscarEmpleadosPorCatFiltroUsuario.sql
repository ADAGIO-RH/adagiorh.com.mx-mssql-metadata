USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Seguridad].[spBuscarEmpleadosPorCatFiltroUsuario]--@IDUsuario = 290, @IDCatFiltroUsuario = 0
(      
	@IDCatFiltroUsuario int  
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
) as      
	 SET LANGUAGE 'Spanish';      
      
	   SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	if object_id('tempdb..#tempEmpleados') is not null drop table #tempEmpleados;                  
        
      

	 select DFEU.IDDetalleFiltrosEmpleadosUsuarios      
		,DFEU.IDUsuario      
		,DFEU.IDEmpleado      
		,em.ClaveEmpleado
		,isnull(SUBSTRING(em.Nombre, 1, 1) + SUBSTRING(em.Paterno, 1, 1),'') as Iniciales
		,em.NOMBRECOMPLETO      
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,isnull(DFEU.Filtro,'Empleados') as Filtro 
		into #tempEmpleados
	 from [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] DFEU 
		join [RH].[tblEmpleadosMaster] em on DFEU.IDEmpleado = em.IDEmpleado    
	where ((DFEU.IDCatFiltroUsuario = @IDCatFiltroUsuario)  OR (ISNULL(@IDCatFiltroUsuario,0) = 0))
	and ((DFEU.IDUsuario = @IDUsuario)  OR (ISNULL(@IDUsuario,0) = 0))
	 and (@query = '""' or contains(em.*, @query)) 

	 select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempEmpleados

	select @TotalRegistros = cast(COUNT([IDEmpleado]) as decimal(18,2)) from #tempEmpleados		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempEmpleados
	order by 
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc,			
		case when @orderByColumn = 'NOMBRECOMPLETO'	and @orderDirection = 'asc'		then NOMBRECOMPLETO end,			
		case when @orderByColumn = 'NOMBRECOMPLETO'	and @orderDirection = 'desc'	then NOMBRECOMPLETO end desc,			
		case when @orderByColumn = 'Departamento'	and @orderDirection = 'asc'		then Departamento end,		
		case when @orderByColumn = 'Departamento'	and @orderDirection = 'desc'	then Departamento end desc,		
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'asc'		then Sucursal end,				
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'desc'	then Sucursal end desc,				
		case when @orderByColumn = 'Puesto'			and @orderDirection = 'asc'		then Puesto end,				
		case when @orderByColumn = 'Puesto'			and @orderDirection = 'desc'	then Puesto end desc,				
		ClaveEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

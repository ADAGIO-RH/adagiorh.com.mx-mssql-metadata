USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Empleados Usuarios
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [Seguridad].[spBuscarEmpleadosUsuario](      
	@IDUsuario int
	,@IDDetalleFiltrosEmpleadosUsuarios int = null      
	,@Filtro  varchar(255)   = null
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
				else '"'+@query + '*"' end

	if object_id('tempdb..#tempEmpleados') is not null drop table #tempEmpleados;                  
        
      
	 select DFEU.IDDetalleFiltrosEmpleadosUsuarios      
		,DFEU.IDUsuario      
		,DFEU.IDEmpleado      
		,em.ClaveEmpleado      
		,em.NOMBRECOMPLETO      
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,isnull(DFEU.Filtro,'Empleados') as Filtro 
		into #tempEmpleados
	 from [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] DFEU      
		  join [RH].[tblEmpleadosMaster] em on DFEU.IDEmpleado = em.IDEmpleado      
		  join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
		  join [Seguridad].[tblUsuarios] U on DFEU.IDUsuario = U.IDUsuario      
	 where (DFEU.IDUsuario = @IDUsuario or @IDUsuario is null)       
		  and (DFEU.IDDetalleFiltrosEmpleadosUsuarios = @IDDetalleFiltrosEmpleadosUsuarios or @IDDetalleFiltrosEmpleadosUsuarios is null)      
		  and ((isnull(DFEU.ValorFiltro,'Empleados') = @Filtro) OR (isnull(DFEU.Filtro,'Empleados') = @Filtro) or (@Filtro is null))
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

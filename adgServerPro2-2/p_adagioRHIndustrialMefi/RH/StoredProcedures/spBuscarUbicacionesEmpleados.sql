USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RH].[spBuscarUbicacionesEmpleados] --@IDUsuario=1
(
    @IDUbicacionEmpleado int = 0
	,@IDEmpleado int = 0
	,@IDUbicacion int = 0
     ,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Empleado'
	,@orderDirection varchar(4) = 'asc'
)
as BEGIN
	
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	 
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
			 IDUbicacionEmpleado   int ,  
			 IDEmpleado   int, 
			  Empleado Varchar(500),
			 IDUbicacion   int, 
			 Ubicacion Varchar(500)	
			
		
		);

	insert @tempResponse
    SELECT
		ue.IDUbicacionEmpleado
		,e.IDEmpleado
        ,e.NOMBRECOMPLETO [Empleado]
        ,u.IDUbicacion
        ,u.Nombre [Ubicacion]   
	FROM RH.tblUbicacionesEmpleados ue
		inner join RH.tblCatUbicaciones u
			on ue.IDUbicacion = u.IDUbicacion
		inner join RH.tblEmpleadosMaster e
			on e.IDEmpleado = ue.IDEmpleado
	where 
	--(@query = '""' or contains(c.*, @query)) and 
		(ue.IDUbicacion = isnull(@IDUbicacion,0) OR isnull(@IDUbicacion,0) = 0)
		and (ue.IDUbicacionEmpleado = isnull(@IDUbicacionEmpleado,0) OR isnull(@IDUbicacionEmpleado,0) = 0)
	  order by ue.IDUbicacionEmpleado asc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDUbicacionEmpleado]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Empleado'			and @orderDirection = 'asc'		then Empleado end,			
		case when @orderByColumn = 'Empleado'			and @orderDirection = 'desc'	then Empleado end desc,	
		case when @orderByColumn = 'Ubicacion'	and @orderDirection = 'asc'		then Ubicacion end,			
		case when @orderByColumn = 'Ubicacion'	and @orderDirection = 'desc'	then Ubicacion end desc,			
		Ubicacion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

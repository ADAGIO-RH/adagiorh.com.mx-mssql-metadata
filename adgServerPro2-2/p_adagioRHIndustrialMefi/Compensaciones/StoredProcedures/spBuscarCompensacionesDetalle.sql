USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Compensaciones].[spBuscarCompensacionesDetalle](
	@IDCompensacionesDetalle int = 0
	,@IDCompensacion int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'ClaveEmpleado' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


   
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	
	declare @tempResponse as table (
		 IDCompensacionesDetalle			int not null 
		,IDCompensacion			int not null 
		,IDEmpleado				int not null 
		,ClaveEmpleado			Varchar(255) not null
		,NombreCompleto			Varchar(255) not null
		,Departamento			Varchar(250) not null
		,Sucursal				Varchar(250) not null
		,Puesto					Varchar(250) not null
		,IndiceSalarial			Decimal(18,4)
		,IndiceSalarialNuevo	Decimal(18,4)
		,Salario				Decimal(18,4)
		,SalarioNuevo			Decimal(18,4)
		,SalarioDiario			Decimal(18,4)
		,SalarioDiarioNuevo		Decimal(18,4)
		,Compensacion			Decimal(18,4)
	);
	
	insert @tempResponse
	SELECT 
			 isnull(C.IDCompensacionesDetalle,0) as IDCompensacionesDetalle			
		,isnull(C.IDCompensacion,@IDCompensacion)as IDCompensacion
		,M.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO
		,M.Departamento
		,M.Sucursal
		,M.Puesto
		,isnull(C.IndiceSalarial,0.00) as IndiceSalarial		 			
		,isnull(C.IndiceSalarialNuevo,0.00) as IndiceSalarialNuevo		 			
		,isnull(M.SalarioDiario * 30.4,0.00) as Salario		 			
		,isnull(C.SalarioNuevo,0.00) as SalarioNuevo		 			
		,isnull(M.SalarioDiario,0.00) as SalarioDiario		 			
		,isnull(C.SalarioDiarioNuevo,0.00) as SalarioDiarioNuevo		 			
		,isnull(C.Compensacion,0.00) as Compensacion			 			
	FROM [Compensaciones].[TblCompensacionesDetalle] C With(nolock)
		inner join [RH].[tblEmpleadosMaster] m with(nolock)
			on c.IDEmpleado = m.IDEmpleado
	WHERE ((C.IDCompensacion = isnull(@IDCompensacion,0) or isnull(@IDCompensacion,0) = 0))
		and ((C.IDCompensacionesDetalle = isnull(@IDCompensacionesDetalle,0) or isnull(@IDCompensacionesDetalle,0) = 0))
		and ((@query = '""' or (contains(M.*, @query)) ) ) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCompensacion]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 		
		case when @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'desc'	then ClaveEmpleado end desc,	
		case when @orderByColumn = 'NOMBRECOMPLETO'			and @orderDirection = 'asc'		then NOMBRECOMPLETO end,			
		case when @orderByColumn = 'NOMBRECOMPLETO'			and @orderDirection = 'desc'	then NOMBRECOMPLETO end desc,
		ClaveEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Intranet].[spBuscarRecibosNominaEmpleados](
		@IDEmpleado int
		,@IDUsuario int
		,@PageNumber	int = 1
		,@PageSize		int = 15
		,@query			varchar(100) = '""'
		,@orderByColumn	varchar(50) = 'FechaFinPago'
		,@orderDirection varchar(4) = 'asc'
) as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if object_id('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 15;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaFinPago' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	select 
		HEP.IDHistorialEmpleadoPeriodo,
		HEP.IDEmpleado,
		p.IDPeriodo,
		 P.FechaFinPago,
		 P.ClavePeriodo,
		 P.Descripcion as Periodo,
		 isnull(T.IDEstatusTimbrado, 0) as IDEstatusTimbrado,
		 cet.Descripcion as EstatusTimbrado
	INTO #tempRespuesta
	from Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK) 
		inner join Nomina.tblCatPeriodos p on p.IDPeriodo = HEP.IDPeriodo
		left join Facturacion.TblTimbrado T on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo 
			 and isnull(T.Actual, 0) = 1
		left join Facturacion.tblCatEstatusTimbrado cet on cet.IDEstatusTimbrado = T.IDEstatusTimbrado
	where HEP.IDEmpleado = @IDEmpleado and isnull(p.Cerrado, 0) = 1 and isnull(p.Finiquito,0) = 0 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempRespuesta

	select @TotalRegistros = cast(COUNT(IDPeriodo) as decimal(18,2)) from #tempRespuesta		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempRespuesta
	order by 
		case when @orderByColumn = 'FechaFinPago'			and @orderDirection = 'asc'		then FechaFinPago end,			
		case when @orderByColumn = 'FechaFinPago'			and @orderDirection = 'desc'	then FechaFinPago end desc,
		case when @orderByColumn = 'ClavePeriodo'			and @orderDirection = 'asc'		then ClavePeriodo end,
		case when @orderByColumn = 'ClavePeriodo'			and @orderDirection = 'desc'	then ClavePeriodo end desc,
		case when @orderByColumn = 'Periodo'			and @orderDirection = 'asc'		then Periodo end,
		case when @orderByColumn = 'Periodo'			and @orderDirection = 'desc'	then Periodo end desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

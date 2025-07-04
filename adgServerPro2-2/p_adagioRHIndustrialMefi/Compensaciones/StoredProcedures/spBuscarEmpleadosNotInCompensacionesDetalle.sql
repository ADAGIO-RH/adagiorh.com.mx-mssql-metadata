USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Compensaciones].[spBuscarEmpleadosNotInCompensacionesDetalle](
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
	   ,@SalarioMinimo decimal(18,2)
	   ,@IDCatTipoCompensacion int
	   ,@IDTipoNomina int
	   ,@IDMatrizIncremento int
	   ,@Fecha Date
	   ,@bPorcentaje bit
	   ,@bDiasSueldo bit
	   ,@bMonto bit
	   ,@Porcentaje Decimal(18,4)
	   ,@DiasSueldo Decimal(18,4)
	   ,@Monto Decimal(18,4)
	   ,@IDCliente int
	   ,@IDPeriodo int
	   ;

	SELECT 
		 @IDCompensacion		= IDCompensacion
		,@IDCatTipoCompensacion	= IDCatTipoCompensacion
		,@IDCliente				= IDCliente	
		,@IDTipoNomina			= IDTipoNomina
		,@IDPeriodo				= IDPeriodo	
		,@IDMatrizIncremento	= IDMatrizIncremento
		,@Fecha					= Fecha	
		,@bPorcentaje			= bPorcentaje	
		,@bDiasSueldo			= bDiasSueldo	
		,@bMonto				= bMonto
		,@Porcentaje			= Porcentaje
		,@DiasSueldo			= DiasSueldo
		,@Monto					= Monto
	FROM Compensaciones.TblCompensaciones with(nolock)
	WHERE IDCompensacion = @IDCompensacion

	Select @SalarioMinimo = isnull(SalarioMinimo,0)
	from Nomina.tblSalariosMinimos wtih(nolock)
	WHERE Fecha <= @Fecha
	order by Fecha desc



 
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
		 IDCompensacionesDetalle int 
		,IDCompensacion			int  
		,IDEmpleado				int  
		,ClaveEmpleado			Varchar(255) 
		,NombreCompleto			Varchar(255) 
		,Departamento			Varchar(250) 
		,Sucursal				Varchar(250) 
		,Puesto					Varchar(250) 
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
	FROM [RH].[tblEmpleadosMaster] m with(nolock) 
		Left join [Compensaciones].[TblCompensacionesDetalle] C With(nolock)
			on c.IDEmpleado = m.IDEmpleado
			and isnull(C.IDCompensacion,0) = isnull(@IDCompensacion,0)
	WHERE isnull(c.IDCompensacionesDetalle,0) = 0
		and (isnull(M.IDCliente,0) = isnull(@IDCliente,0) OR (isnull(@IDCliente,0) = 0 )) 
		and (isnull(M.IDTipoNomina,0) = isnull(@IDTipoNomina,0) OR (isnull(@IDTipoNomina,0) = 0 )) 
		and ((@query = '""' or (contains(M.*, @query)) ) )
		and m.Vigente = 1

	
		IF(@IDCatTipoCompensacion = 1)
		BEGIN
			Delete @tempResponse
			where SalarioDiario > @SalarioMinimo
		END


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

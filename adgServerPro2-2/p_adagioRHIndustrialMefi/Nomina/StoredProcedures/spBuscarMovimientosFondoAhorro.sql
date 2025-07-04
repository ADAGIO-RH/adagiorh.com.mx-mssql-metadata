USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarMovimientosFondoAhorro](
		@IDFondoAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
		,@PageNumber	int = 1
		,@PageSize		int = 2147483647
		,@query			varchar(100) = '""'
		,@orderByColumn	varchar(50) = 'Periodo'
		,@orderDirection varchar(4) = 'asc'
) as
declare  
		@IDPeriodoInicial	   int
		,@IDPeriodoFinal	   int 
		,@CodigosConceptosFondoAhorroEmpresa varchar(100) = '308' -- FONDO DE AHORRO EMPRESA 
		,@CodigosConceptosFondoAhorroTrabajador varchar(100) = '309' -- FONDO DE AHORRO TRABAJADOR
		,@FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-12-31' 
		,@TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
		if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;


	declare @ResponseAportaciones as table (

		[Periodo] [varchar](100) NULL,	
		[Fecha] [date] NULL,
		[ImporteEmpresa] [decimal] (18,2)NULL,
		[ImporteTrabajador] [decimal] (18,2) NULL,
		[Acumulado] [int] NULL
		

	)
	
	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

	select @FechaIni=FechaInicioPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoInicial
	select @FechaFin= FechaFinPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoFinal;

	with AportacionEmpresa as (
	select c.Descripcion,
	ImporteEmpresa = case when c.Codigo in ('308') then ISNULL(DP.ImporteTotal1,0) else 0 end,
	 p.FechaFinPago as Fecha,
	 p.ClavePeriodo as Periodo,
	  DP.IDEmpleado
	 from Nomina.tblDetallePeriodo dp
	Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
		where c.Codigo in ('308')
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   
		), ImportacionTrabajador as (
			select c.Descripcion,	
	ImporteTrabajador = case when c.Codigo in ('309') then ISNULL(DP.ImporteTotal1,0) else 0 end,
	 p.FechaFinPago as Fecha,
	 p.ClavePeriodo as Periodo,
	 DP.IDEmpleado
	 from Nomina.tblDetallePeriodo dp
	Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
		where c.Codigo in ('309')
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   )
		
			insert @ResponseAportaciones
		Select AE.Periodo, 
		AE.Fecha, 
		AE.ImporteEmpresa, 
		IT.ImporteTrabajador, 
		sum(AE.ImporteEmpresa+ IT.ImporteTrabajador ) as Acumulado 
		from AportacionEmpresa AE inner join  ImportacionTrabajador IT
		on AE.Periodo =IT.Periodo
		group by  AE.Periodo, AE.Fecha, AE.ImporteEmpresa, IT.ImporteTrabajador


			select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @ResponseAportaciones

	select @TotalRegistros = cast(COUNT([Periodo]) as decimal(18,2)) from @ResponseAportaciones	

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @ResponseAportaciones
	order by 
		case when @orderByColumn = 'Periodo'	and @orderDirection = 'asc'		then Periodo end,			
		case when @orderByColumn = 'Periodo'	and @orderDirection = 'desc'	then Periodo end desc,			
		Periodo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

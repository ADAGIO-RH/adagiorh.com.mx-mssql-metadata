USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de retiros por Tipo (Empleado o Trabajador)
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-08-30
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

[Nomina].[spBuscarRetirosFondoAhorroPorEmpleado]
		@IDFondoAhorro	= 4
		,@IDEmpleado	= 1279
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarRetirosFondoAhorroPorEmpleado](
		@IDFondoAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
        ,@PageNumber	int = 1
        ,@PageSize		int = 2147483647
        ,@query			varchar(100) = '""'
        ,@orderByColumn	varchar(50) = 'Fecha'
        ,@orderDirection varchar(4) = 'desc'   
) as


DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT, 
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'Fecha' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempRetirosFondoAhorro') IS NOT NULL DROP TABLE #TempRetirosFondoAhorro;
	--declare @IDFondoAhorro	int = 4
	--		,@IDEmpleado	int = 1279
	--		,@IDUsuario		int = 1
	declare  
			@IDPeriodoInicial	   int
			,@IDPeriodoFinal	   int 
			,@CodigoConceptoRetiroFondoAhorroEmpresa varchar(100) = '165' -- RETIRO FONDO DE AHORRO EMPRESA
			,@CodigoConceptoRetiroFondoAhorroTrabajador varchar(100) = '166' -- RETIRO FONDO DE AHORRO TRABAJADOR
			,@FechaIni date --= '2019-01-01'
			,@FechaFin date --= '2019-12-31'
	;

	--if object_id('tempdb..#tempListaRetiros') is not null drop table #tempListaRetiros
	declare @tempListaRetiros table(
		ID int
		,IDEmpleado  	 int
		,IDConcepto  	 int
		,Codigo			 varchar(20)
		,Fecha			 date
		,Periodo		 varchar(20)
        ,DescripcionPeriodo varchar(max)
		,Importe		 decimal(18,2)
		,Descripcion	 varchar(250)
		,Estatus varchar(20)
		,Pagado bit
	);
	
	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

	select @FechaIni= FechaInicioPago	from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoInicial
	select @FechaFin= FechaFinPago		from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoFinal

	INSERT @tempListaRetiros
	Select	dp.IDDetallePeriodo as ID
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			, p.ClavePeriodo as Periodo
            , UPPER(p.Descripcion) as DescripcionPeriodo
			,ISNULL(DP.ImporteTotal1,0) as Importe
			,c.Descripcion
			,'APLICADO' as Estatus
			,cast(1 as bit) as Pagado
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in ('165','166')
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   
	--order by p.FechaInicioPago asc
	UNION
	select 
		 rfa.IDRetiroFondoAhorro as ID
		,rfa.IDEmpleado
		,c.IDConcepto  
		,c.Codigo
		, p.FechaFinPago as Fecha
		, p.ClavePeriodo as Periodo
        , UPPER(p.Descripcion) as DescripcionPeriodo
		,ISNULL(rfa.MontoEmpresa,0) as Importe
		,c.Descripcion
		,'PENDIENTE' as Estatus
		,cast(0 as bit) as Pagado
	from Nomina.tblRetirosFondoAhorro rfa
		Inner join Nomina.tblCatPeriodos P on rfa.IDPeriodo = P.IDPeriodo AND rfa.IDEmpleado = @IDEmpleado AND P.Cerrado = 0  
		,Nomina.tblCatConceptos c 
	where c.Codigo = @CodigoConceptoRetiroFondoAhorroEmpresa and rfa.IDEmpleado = @IDEmpleado
	--order by p.FechaInicioPago asc
	UNION
	select 
		 rfa.IDRetiroFondoAhorro as ID
		,rfa.IDEmpleado
		,c.IDConcepto  
		,c.Codigo
		, p.FechaFinPago as Fecha
		, p.ClavePeriodo as Periodo
        , UPPER(p.Descripcion) as DescripcionPeriodo
		,ISNULL(rfa.MontoEmpresa,0) as Importe
		,c.Descripcion
		,'PENDIENTE' as Estatus
		,cast(0 as bit) as Pagado
	from Nomina.tblRetirosFondoAhorro rfa
		Inner join Nomina.tblCatPeriodos P on rfa.IDPeriodo = P.IDPeriodo AND rfa.IDEmpleado = @IDEmpleado AND P.Cerrado = 0 
		,Nomina.tblCatConceptos c 
	where c.Codigo = @CodigoConceptoRetiroFondoAhorroTrabajador and rfa.IDEmpleado = @IDEmpleado
	--order by p.FechaInicioPago asc

	select * 
    INTO #TempRetirosFondoAhorro
    from @tempListaRetiros

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempRetirosFondoAhorro

	select @TotalRegistros = cast(COUNT(ID) as decimal(18,2)) from #TempRetirosFondoAhorro
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempRetirosFondoAhorro
	order by 	
		case when @orderByColumn = 'Fecha' and @orderDirection = 'asc'	then Fecha end,			
		case when @orderByColumn = 'Fecha' and @orderDirection = 'desc'	then Fecha end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
 -- exec nomina.spBuscarCatConceptos
GO

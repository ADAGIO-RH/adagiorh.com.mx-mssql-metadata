USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de aportaciones por Tipo (Empleado o Trabajador)
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-08-29
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

[Nomina].[spBuscarAportacionesFondoAhorroPorEmpleado]
		@IDFondoAhorro	= 4
		,@IDEmpleado	= 1279
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAportacionesFondoAhorroPorEmpleado](
		@IDFondoAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
        ,@PageNumber	int = 1
        ,@PageSize		int = 2147483647
        ,@query			varchar(100) = '""'
        ,@orderByColumn	varchar(50) = 'Fecha'
        ,@orderDirection varchar(4) = 'desc'   
) as
--declare @IDFondoAhorro	int = 4
--		,@IDEmpleado	int = 1279
--		,@IDUsuario		int = 1
DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT
	   ,@IDIdioma VARCHAR(20)
       ,@IDTipoNomina INT
        
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

IF OBJECT_ID('tempdb..#TempAportacionesFondoAhorroPorEmpleado') IS NOT NULL DROP TABLE #TempAportacionesFondoAhorroPorEmpleado;


declare  
		@IDPeriodoInicial	   int
		,@IDPeriodoFinal	   int 
		,@CodigosConceptosFondoAhorroEmpresa varchar(100) = '308' -- FONDO DE AHORRO EMPRESA 
		,@CodigosConceptosFondoAhorroTrabajador varchar(100) = '309' -- FONDO DE AHORRO TRABAJADOR
		,@FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-12-31'
        ,@IDPeriodoPago int
 ;
	
	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
          ,@IDTipoNomina= IDTipoNomina
          ,@IDPeriodoPago=ISNULL(IDPeriodoPago,0)
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

    if object_id('tempdb..#tempPeriodosPago') is not null drop table #tempPeriodosPago;

    SELECT ISNULL(IDPeriodoPago,0) AS IDPeriodoPago
    INTO #tempPeriodosPago
    FROM Nomina.tblCatFondosAhorro

	select @FechaIni=FechaInicioPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoInicial
	select @FechaFin= FechaFinPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoFinal
    
    CREATE TABLE #TempAportacionesFondoAhorroPorEmpleado(
    IDDetallePeriodo INT,
    IDEmpleado INT,
    IDConcepto INT,
    Codigo VARCHAR(50),
    Fecha DATE,
    Periodo VARCHAR(50),
    DescripcionPeriodo VARCHAR(100),
    ImporteAbono DECIMAL(18, 2),
    ImporteCargo DECIMAL(18, 2),
    Descripcion VARCHAR(100)
    );

    INSERT INTO #TempAportacionesFondoAhorroPorEmpleado
	----Retenciones que pertenecen al intervalo del Fondo de ahorro pero estan en periodos de pago de fondo de ahorro (Regularmente del anterior)
    Select	dp.IDDetallePeriodo
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			, p.ClavePeriodo as Periodo
			, UPPER(p.Descripcion) as DescripcionPeriodo
			,ImporteAbono = case when c.Codigo in ('308','309') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,ImporteCargo = case when c.Codigo in ('162','163') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,c.Descripcion    
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P 
            on DP.IDPeriodo = P.IDPeriodo 
            AND DP.IDEmpleado = @IDEmpleado 
            AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c 
            on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in ('308','309')--= case when @Tipo = 1 then @CodigosConceptosFondoAhorroEmpresa else @CodigosConceptosFondoAhorroTrabajador end
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   
        AND P.IDPeriodo IN(SELECT IDPeriodoPago FROM #tempPeriodosPago)
		and ((@query = '""') OR CONTAINS(p.*, @query))
    UNION
    ----Devoluciones y Retiros dentro del rango del fondo de ahorro
    Select	dp.IDDetallePeriodo
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			, p.ClavePeriodo as Periodo
			, UPPER(p.Descripcion) as DescripcionPeriodo
			,ImporteAbono = case when c.Codigo in ('308','309') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,ImporteCargo = case when c.Codigo in ('162','163') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,c.Descripcion    
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P 
            on DP.IDPeriodo = P.IDPeriodo 
            AND DP.IDEmpleado = @IDEmpleado 
            AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c 
            on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in ('162','163','308','309')--= case when @Tipo = 1 then @CodigosConceptosFondoAhorroEmpresa else @CodigosConceptosFondoAhorroTrabajador end
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   
		and ((@query = '""') OR CONTAINS(p.*, @query))
        AND P.IDTipoNomina=@IDTipoNomina
        AND P.IDPeriodo NOT IN(SELECT IDPeriodoPago FROM #tempPeriodosPago)	
    UNION
	----Devolucion en el periodo de pago de fondo de ahorro
    Select	dp.IDDetallePeriodo
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			, p.ClavePeriodo as Periodo
			, UPPER(p.Descripcion) as DescripcionPeriodo
			,ImporteAbono = case when c.Codigo in ('308','309') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,ImporteCargo = case when c.Codigo in ('162','163') then ISNULL(DP.ImporteTotal1,0) else 0 end
			,c.Descripcion
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P 
            on DP.IDPeriodo = P.IDPeriodo 
            AND DP.IDEmpleado = @IDEmpleado 
            AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c 
            on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in ('162','163')
		and p.idperiodo=@IDPeriodoPago
		and ((@query = '""') OR CONTAINS(p.*, @query))        
    
    
    
    

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempAportacionesFondoAhorroPorEmpleado

    print(@TotalPaginas)

	select @TotalRegistros = cast(COUNT(IDDetallePeriodo) as decimal(18,2)) from #TempAportacionesFondoAhorroPorEmpleado
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempAportacionesFondoAhorroPorEmpleado
	order by 	
		case when @orderByColumn = 'Fecha' and @orderDirection = 'asc'	then Fecha end,			
		case when @orderByColumn = 'Fecha' and @orderDirection = 'desc'	then Fecha end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

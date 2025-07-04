USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de aportaciones por Tipo (Empleado o Trabajador)
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-06-19
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

***************************************************************************************************/
CREATE proc [Reportes].[spReporteBasicoGenerarExcelAportacionesFondoAhorro](
		 @IDFondoAhorro	int	--= 2
		,@dtFiltros Nomina.dtFiltrosRH readonly
        ,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
        
) as
--declare @IDFondoAhorro	int = 4
--		,@IDEmpleado	int = 1279
--		,@IDUsuario		int = 1
DECLARE  	   	   
       @IDTipoNomina INT
        
	;



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

    SELECT IDPeriodoPago
    INTO #tempPeriodosPago
    FROM Nomina.tblCatFondosAhorro

	select @FechaIni=FechaInicioPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoInicial
	select @FechaFin= FechaFinPago from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoFinal
    
    CREATE TABLE #TempAportacionesFondoAhorroPorEmpleado(    
    Fecha DATE,
    Periodo VARCHAR(50),
    DescripcionPeriodo VARCHAR(100),
    ImporteAbono DECIMAL(18, 2),
    ImporteCargo DECIMAL(18, 2),
    Descripcion VARCHAR(100)
    );

    INSERT INTO #TempAportacionesFondoAhorroPorEmpleado
	----Retenciones que pertenecen al intervalo del Fondo de ahorro pero estan en periodos de pago de fondo de ahorro (Regularmente del anterior)
    Select	
			  p.FechaFinPago 
			, p.ClavePeriodo 
			, UPPER(p.Descripcion) 
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
		
    UNION
    ----Devoluciones y Retiros dentro del rango del fondo de ahorro
    Select	  p.FechaFinPago 
			, p.ClavePeriodo 
			, UPPER(p.Descripcion) 
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
        AND P.IDTipoNomina=@IDTipoNomina
        AND P.IDPeriodo NOT IN(SELECT IDPeriodoPago FROM #tempPeriodosPago)	
    UNION
	----Devolucion en el periodo de pago de fondo de ahorro
    Select	 p.FechaFinPago 
			, p.ClavePeriodo 
			, UPPER(p.Descripcion) 
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
    
    SELECT  Fecha,
            Periodo,
            DescripcionPeriodo AS [Descripción Periodo],
            ImporteAbono AS [Importe Abono],
            ImporteCargo AS [Importe Cargo],
            Descripcion
    FROM #TempAportacionesFondoAhorroPorEmpleado
GO

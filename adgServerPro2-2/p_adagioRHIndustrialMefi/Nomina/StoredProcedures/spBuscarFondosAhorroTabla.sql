USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarFondosAhorroTabla](


	@IDUsuario int
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH]  READONLY  
) as
declare 	
	@IDFondoAhorro int  
	,@IDTipoNomina int = 0
	,@Ejercicio int = 0
	,@IDEmpleado int
		,@IDPeriodoInicial	   int
		,@IDPeriodoFinal	   int 
		,@FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-12-31' 
	,@orderByColumn	varchar(50) = 'Cliente',
	@orderDirection varchar(4) = 'asc'


	SET @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)
	SET @IDFondoAhorro = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDFondoAhorro'),0)

	    Select  @orderByColumn=isnull(Value,'IDEmpleado') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'

	  IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL
    BEGIN
        DROP TABLE #tempSetPagination
    END;

select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
          ,@IDTipoNomina	= IDTipoNomina
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
	Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1 AND IDTipoNomina = @IDTipoNomina
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
	Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1 AND IDTipoNomina = @IDTipoNomina
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
		where c.Codigo in ('309')
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')  
		)
			
		Select     ROW_NUMBER()Over(Order by  
                                    case when @orderByColumn = 'Periodo'			and @orderDirection = 'asc'		then AE.Periodo end ,
                                    case when @orderByColumn = 'Periodo'			and @orderDirection = 'desc'		then AE.Periodo end desc

                                                                 
        )  as [row],
		AE.Periodo, 
		AE.Fecha, 
		AE.ImporteEmpresa, 
		IT.ImporteTrabajador, 
		sum(AE.ImporteEmpresa+ IT.ImporteTrabajador ) as Acumulado 
		into #tempSetPagination
		from AportacionEmpresa AE inner join  ImportacionTrabajador IT
		on AE.Periodo =IT.Periodo
		group by  AE.Periodo, AE.Fecha, AE.ImporteEmpresa, IT.ImporteTrabajador

		   if exists(select top 1 * from @dtPagination)
        BEGIN
            exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
        end
    else 
        begin 
            select  * From #tempSetPagination order by row desc
        end
GO

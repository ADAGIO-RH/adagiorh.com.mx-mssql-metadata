USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Poliza contable para periodos generales de nomina de manera mensual con multiples agrupamientos.
** Autor			: Julio Castillo
** Email			: jcastillo@adagio.com.mx
** FechaCreacion	: 2023-04-09
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [Reportes].[spReportePolizaFiniLiqui_QNA]  (    
		@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
		@IDUsuario int   
	) as   

	declare 
		 @empleados [RH].[dtEmpleados]     
		,@IDPeriodoSeleccionado int=0    
		,@periodo [Nomina].[dtPeriodos]                     
		,@IDTipoNomina int    
        ,@Ejercicio int 
        ,@IDMes int 
		,@fechaIniPeriodo  date       
		,@fechaFinPeriodo  date  
        ,@DescripcionPeriodo varchar(max)  
        ,@DocumentNo varchar(MAX)
        ,@Mes varchar(3)
		 
		
	
	
		select @IDTipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

        select @Ejercicio = CASE WHEN ISNULL(Value,0) = 0 THEN 0 ELSE  Value END
		from @dtFiltros where Catalogo = 'Ejercicio'

       
		Select @IDPeriodoSeleccionado= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')

		
        select @IDMes = IDMes
		from Nomina.tblCatPeriodos  
		where IDPeriodo in  ( 
                                @IDPeriodoSeleccionado
                                       
                            )   

        select @fechaIniPeriodo = CASE WHEN ISNULL(Value,'9999-01-01') = '9999-01-01'  THEN '9999-01-01' ELSE  Value END
		from @dtFiltros where Catalogo = 'FechaIni'
        




        

		/* Se buscan los periodos qe se requieren en la poliza */    
		insert into @periodo  
		select *
			-- IDPeriodo  
			--,IDTipoNomina  
			--,Ejercicio  
			--,ClavePeriodo  
			--,Descripcion  
			--,FechaInicioPago  
			--,FechaFinPago  
			--,FechaInicioIncidencia  
			--,FechaFinIncidencia  
			--,Dias  
			--,AnioInicio  
			--,AnioFin  
			--,MesInicio  
			--,MesFin  
			--,IDMes  
			--,BimestreInicio  
			--,BimestreFin  
			--,Cerrado  
			--,General  
			--,Finiquito  
			--,isnull(Especial,0)  
		from Nomina.tblCatPeriodos  
		where IDPeriodo in  ( 
                               @IDPeriodoSeleccionado                
                            )   and Cerrado = 1   and Finiquito = 1


		/*Fechas del periodo*/
		select top 1 @DescripcionPeriodo = Descripcion from @periodo where General = 1 order by Descripcion asc
        
        /* Descripcion de un campo de la poliza*/
        set @DocumentNo = (Select CONCAT('Fini y Liqui ',lower(Nombre),' ',@Ejercicio) from Utilerias.tblMeses where idmes = @IDMes)
        
        set @Mes = (select LOWER(Nombre) from Utilerias.tblMeses where idmes = @IDMes)
		
		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado & DENTRO DEL PERIODO SELECCIONADO */      
		insert into @empleados 
        --Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@FechaIni = @fechaIniPeriodo, @FechaFin = @fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario 
        exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @IDUsuario = @IDUsuario


		if object_id('tempdb..#percepcionesFini') is not null        
			drop table #percepcionesFini 
        
        if object_id('tempdb..#PercepcionesVyPFini') is not null        
			drop table #PercepcionesVyPFini--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPCFini') is not null        
			drop table #PercepcionesVyPCFini--Percepciones sin CC

        if object_id('tempdb..#percepcionesLiqui') is not null        
			drop table #percepcionesLiqui 
        
        if object_id('tempdb..#PercepcionesVyPLiqui') is not null        
			drop table #PercepcionesVyPLiqui--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPCLiqui') is not null        
			drop table #PercepcionesVyPCLiqui--Percepciones sin CC

		if object_id('tempdb..#deducciones') is not null        
			drop table #deducciones

        


/*********************TABLA TEMPORAL PERCEPCIONES de FINIQUITOS SIN VEX Y PEGAS*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,	
            Concat(Conceptos.CuentaCargo,'-',CentrosCostos.CuentaContable) AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Finiquitos ',LOWER(@Mes),' del ',@Ejercicio)   as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode,
            '' as SourceNo_, 
            'MXN' as CurrencyCode,
            '' as OriginalCurrencyFactor,
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when suc.Descripcion = 'CANCUN' THEN 'CUN' 
                WHEN SUC.Descripcion = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN SUC.Descripcion = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN SUC.Descripcion = 'MAZATLAN' THEN 'MZT'
                WHEN SUC.Descripcion = 'PUERTO VALLARTA' THEN 'PVR'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,suc.Descripcion
            ,Conceptos.CuentaCargo
            ,CentrosCostos.CuentaContable 
			,Empleados.ClaveEmpleado
			,Conceptos.Codigo
			,detallePeriodo.IDPeriodo
			,fac.UUID
            
                      
INTO #percepcionesFini
        FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

                          
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio)-- and (DATEPART(MONTH,fac.Fecha) = @IDMes))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                AND CentrosCostos.cuentacontable not in ('1101','1103')           
				AND detallePeriodo.Importetotal1 <> 0
                and tiposConceptos.Descripcion = 'PERCEPCION' or Conceptos.Codigo in ('180')
                -- and cp.IDPeriodo not in (
                --     select distinct dp.IDPeriodo
                --     from nomina.tblDetallePeriodo dp
                --     inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                --     inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                --     Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                --     inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                --     where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                --     and IDConcepto in (195,196,197)
                -- )
                AND empleados.idempleado not in (
                    select distinct dp.IDEmpleado
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio -- and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                )    
                group by 
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo,
				Empleados.ClaveEmpleado
			   ,Conceptos.Codigo
			   ,detallePeriodo.IDPeriodo
			   ,fac.UUID
            
				

                select*from #percepcionesFini return

     
/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS DESTINATION FINIQUITOS*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Finiquitos ',LOWER(@Mes),' del ',@Ejercicio)   as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID,
            '' as BusinessUnitCode,
            '' as SourceNo_,  
            'MXN' as CurrencyCode, 
            '' as OriginalCurrencyFactor,    
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when suc.Descripcion = 'CANCUN' THEN 'CUN' 
                WHEN SUC.Descripcion = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN SUC.Descripcion = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN SUC.Descripcion = 'MAZATLAN' THEN 'MZT'
                WHEN SUC.Descripcion = 'PUERTO VALLARTA' THEN 'PVR'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,suc.Descripcion
            ,Conceptos.CuentaCargo
            ,CentrosCostos.CuentaContable
                    
INTO #percepcionesVyPFini
       FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                AND tiposConceptos.Descripcion = 'PERCEPCION' 
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable in ('1101','1103') 
                -- and cp.IDPeriodo not in (
                --     select distinct dp.IDPeriodo
                --     from nomina.tblDetallePeriodo dp
                --     inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                --     inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                --     Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                --     inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                --     where Finiquito = 1 and Ejercicio = @Ejercicio and DATEPART(MONTH,fac.Fecha) = @IDMes and IDMes = @IDMes 
                --     and IDConcepto in (195,196,197)
                -- ) 
                AND empleados.idempleado not in (
                    select distinct dp.IDEmpleado
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                )                             
                group by                
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                

/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS CLIENT FINIQUITOS*****************************/		 

SELECT 

            --detallePeriodo.*,Conceptos.Descripcion as w,CentrosCostos.cuentacontable,suc.Descripcion as suc, Conceptos.CuentaCargo
				
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Finiquitos ',LOWER(@Mes),' del ',@Ejercicio)   as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode, 
            '' as SourceNo_, 
            'MXN' as CurrencyCode,  
            '' as OriginalCurrencyFactor,  
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            2 as aaTrxDimID,
            'Client' as aaTrxDim,
            case when CentrosCostos.cuentacontable like '%1101%' then 'VEX'
                when CentrosCostos.cuentacontable like '%1103%' then  'PEGAS' end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
            ,suc.Descripcion  
            ,Conceptos.CuentaCargo
            ,CentrosCostos.CuentaContable

INTO #percepcionesVyPCFini
        FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                AND tiposConceptos.Descripcion = 'PERCEPCION' 
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable in ('1101','1103') 
                -- and cp.IDPeriodo not in (
                --     select distinct dp.IDPeriodo
                --     from nomina.tblDetallePeriodo dp
                --     inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                --     inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                --     Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                --     inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                --     where Finiquito = 1 and Ejercicio = @Ejercicio and DATEPART(MONTH,fac.Fecha) = @IDMes and IDMes = @IDMes 
                --     and IDConcepto in (195,196,197)
                -- )
                AND empleados.idempleado not in (
                    select distinct dp.IDEmpleado
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                )                             
                group by                
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                 

                

---------

/*********************TABLA TEMPORAL PERCEPCIONES de Liquidacione SIN VEX Y PEGAS*****************************/		 

SELECT 
            --detallePeriodo.*,Conceptos.Descripcion as w,CentrosCostos.cuentacontable,suc.Descripcion as suc, Conceptos.CuentaCargo
            @fechaIniPeriodo as PostingDate,	
            Concat(Conceptos.CuentaCargo,'-',CentrosCostos.CuentaContable) AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Liquidaciones ',LOWER(@Mes),' del ',@Ejercicio)   as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode,
            '' as SourceNo_, 
            'MXN' as CurrencyCode,
            '' as OriginalCurrencyFactor,
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when suc.Descripcion = 'CANCUN' THEN 'CUN' 
                WHEN SUC.Descripcion = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN SUC.Descripcion = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN SUC.Descripcion = 'MAZATLAN' THEN 'MZT'
                WHEN SUC.Descripcion = 'PUERTO VALLARTA' THEN 'PVR'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,suc.Descripcion
            ,Conceptos.CuentaCargo
            ,CentrosCostos.CuentaContable 

                      
INTO #percepcionesLiqui
        FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

        /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                AND CentrosCostos.cuentacontable not in ('1101','1103')           
				AND detallePeriodo.Importetotal1 <> 0
                and tiposConceptos.Descripcion = 'PERCEPCION'
                -- and cp.IDPeriodo in (
                --     select distinct dp.IDPeriodo
                --     from nomina.tblDetallePeriodo dp
                --     inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                --     inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                --     Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                --     inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                --     where Finiquito = 1 and Ejercicio = @Ejercicio and DATEPART(MONTH,fac.Fecha) = @IDMes and IDMes = @IDMes 
                --     and IDConcepto in (195,196,197)
                -- ) 
                AND empleados.idempleado in (
                    select distinct dp.IDEmpleado
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                ) 
                group by 
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo

               
               
/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS DESTINATION LIQUIDACIONES*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Liquidaciones ',LOWER(@Mes),' del ',@Ejercicio)   as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID,
            '' as BusinessUnitCode,
            '' as SourceNo_,  
            'MXN' as CurrencyCode, 
            '' as OriginalCurrencyFactor,    
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            Case 
                when suc.Descripcion = 'CANCUN' THEN 'CUN' 
                WHEN SUC.Descripcion = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN SUC.Descripcion = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN SUC.Descripcion = 'MAZATLAN' THEN 'MZT'
                WHEN SUC.Descripcion = 'PUERTO VALLARTA' THEN 'PVR'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,suc.Descripcion
            ,Conceptos.CuentaCargo
            ,CentrosCostos.CuentaContable
                    
INTO #percepcionesVyPLiqui
       FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                AND tiposConceptos.Descripcion = 'PERCEPCION' 
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable in ('1101','1103') 
                -- and cp.IDPeriodo in (
                --     select distinct dp.IDPeriodo
                --     from nomina.tblDetallePeriodo dp
                --     inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                --     inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                --     Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                --     inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                --     where Finiquito = 1 and Ejercicio = @Ejercicio and DATEPART(MONTH,fac.Fecha) = @IDMes and IDMes = @IDMes 
                --     and IDConcepto in (195,196,197)
                -- ) 
                AND empleados.idempleado in (
                    select distinct dp.IDEmpleado
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                )                             
                group by                
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                

/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS CLIENT LIQUIDACIONES*****************************/		 

SELECT 

            --detallePeriodo.*,Conceptos.Descripcion as w,CentrosCostos.cuentacontable,suc.Descripcion as suc, Conceptos.CuentaCargo
				
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Liquidaciones ',LOWER(@Mes),' del ',@Ejercicio)   as [Description],
            SUM ( detallePeriodo.ImporteTotal1 ) AS Amount,
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode, 
            '' as SourceNo_, 
            'MXN' as CurrencyCode,  
            '' as OriginalCurrencyFactor,  
            SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
			'0.00' AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            2 as aaTrxDimID,
            'Client' as aaTrxDim,
            case when CentrosCostos.cuentacontable like '%1101%' then 'VEX'
                when CentrosCostos.cuentacontable like '%1103%' then  'PEGAS' end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
            ,suc.Descripcion  
            ,Conceptos.CuentaCargo
            ,CentrosCostos.CuentaContable 
            
            
            
INTO #percepcionesVyPCLiqui
        FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                AND tiposConceptos.Descripcion = 'PERCEPCION' 
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable in ('1101','1103') 
                and cp.IDPeriodo in (
                    select distinct dp.IDPeriodo
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                ) 
                AND empleados.idempleado in (
                    select distinct dp.IDEmpleado
                    from nomina.tblDetallePeriodo dp
                    inner join nomina.tblCatPeriodos cp on dp.IDPeriodo = cp.IDPeriodo
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo
                    Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo  
                    inner join rh.tblEmpleadosMaster e on e.IDEmpleado = hist.IDEmpleado
                    where Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes) 
                    and IDConcepto in (195,196,197)
                )                             
                group by                
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                 



/*********************TABLA TEMPORAL DEDUCCIONES*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            Case when Conceptos.CuentaAbono = '999999-01' then '999999-01-1001' Else Conceptos.CuentaAbono END  as G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            @DocumentNo as Description,
            - SUM ( detallePeriodo.ImporteTotal1 ) AS Amount, 
            1 as TransactionNo_,
            'nrivera' as UserID, 
            '' as BusinessUnitCode,  
            '' as SourceNo_, 
            'MXN' as CurrencyCode, 
            '' as OriginalCurrencyFactor,          
            '0.00' AS Debit,
			SUM ( detallePeriodo.ImporteTotal1 ) AS Credit,
            @fechainiperiodo as DocumentDate,
            '' as ExternalDocumentNo_,
            '' as sc_Secuence,
            '' as ReasonCode,
            1 as aaTrxDimID,
            'Destination' as aaTrxDim,
            'CUN' as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
            ,'' as Descripcion
            ,Conceptos.CuentaAbono
            ,0000 as CuentaContable
           

            
INTO #deducciones
        FROM Nomina.tblDetallePeriodo detallePeriodo
            inner join @periodo cp on detallePeriodo.IDPeriodo = cp.IDPeriodo
            inner join Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = cp.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
            Inner join Facturacion.TblTimbrado fac on fac.IDHistorialEmpleadoPeriodo = hist.IDHistorialEmpleadoPeriodo                                                   
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   (Finiquito = 1 and Ejercicio = @Ejercicio and (DATEPART(MONTH,fac.Fecha) = @IDMes))
		        AND (tiposConceptos.Descripcion = 'DEDUCCION' or Conceptos.Codigo in ('601','604','607'))
                AND fac.IDEstatusTimbrado = (Select IDEstatusTimbrado from Facturacion.tblCatEstatusTimbrado where Descripcion = 'TIMBRADO')
                AND fac.Actual = 1
                and conceptos.cuentaabono <> ''
				AND detallePeriodo.Importetotal1 <> 0 
                group by 
                Conceptos.CuentaAbono


---------------------------------------------------------
/*Se creara una tabla temporal con IDENTITY para poder generar el SECNUM de la poliza que tiene que repetirse en VEX y PEGAS*/
create table #Tempaqui
(
        ID INT IDENTITY ,--IMPORTANTE
        [PostingDate] date,
        [G_LAccountNo_]varchar(max),
        [DocumentType]varchar(max),
        [DocumentNo_]varchar(max),
        [Description]varchar(max),
        [Amount]varchar(max),
        [TransactionNo_]varchar(max),
        [UserID]varchar(max),
        [BusinessUnitCode]varchar(max),
        [SourceNo_]varchar(max),
        [CurrencyCode]varchar(max),
        [OriginalCurrencyFactor]varchar(max),
        [Debit]varchar(max),
        [Credit]varchar(max),
        [DocumentDate]date,
        [ExternalDocumentNo_]varchar(max),
        [sc_Secuence]varchar(max),
        [ReasonCode]varchar(max),
        [aaTrxDimID]varchar(max),
        [aaTrxDim]varchar(max),
        [Dimension]varchar(max),
        [BATCH_ID]varchar(max),
        descripcion VARCHAR(MAX),
        cuenta VARCHAR(MAX),
        cuentaC VARCHAR(Max),
        
)

/*Insertamos la Union de nuestras tablas temporales a excepcion de la VEX y PEGAS CLIENT para generar numeros consecutivos*/

insert into #Tempaqui
        Select 
        [PostingDate],
        [G_LAccountNo_],
        [DocumentType],
        [DocumentNo_],
        [Description],
        [Amount],
        [TransactionNo_],
        [UserID],
        [BusinessUnitCode],
        [SourceNo_],
        [CurrencyCode],
        [OriginalCurrencyFactor],
        [Debit],
        [Credit],
        [DocumentDate],
        [ExternalDocumentNo_],
        [sc_Secuence],
        [ReasonCode],
        [aaTrxDimID],
        [aaTrxDim],
        [Dimension],
        [BATCH_ID],
        descripcion,
        CuentaCargo,
        CuentaContable
       
FROM
(
Select * from #percepcionesFini
union 
Select * from #percepcionesVyPFini
UNION
Select * from #percepcionesLiqui
union 
Select * from #percepcionesVyPLiqui
UNION
Select * from #deducciones 
) b 
ORDER by Credit
    
set identity_insert #Tempaqui on -- Activamos el ID INSERT para repetir la secuencia de los registros VEX y PEGAS Con un JOIN

Insert into #Tempaqui
(
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
     [Descripcion],
     [Cuenta]
)
SELECT 
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
     [Descripcion],
     [CuentaCargo]
 
FROM 
(
    select 
     t.id, 
     c.*,
     ROW_NUMBER()OVER(Partition by ID order by ID) as rn 
    from #Tempaqui t
        inner join #percepcionesVyPCFini c 
            on t.G_LAccountNo_ = c.G_LAccountNo_ 
            and t.cuenta = c.CuentaCargo
            and t.descripcion = c.Descripcion
            and t.[Description] = c.[Description]
            and t.cuentaC = c.CuentaContable
            
) m


Insert into #Tempaqui
(
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
     [Descripcion],
     [Cuenta]
)
SELECT 
     [ID],
     [PostingDate],
     [G_LAccountNo_],
     [DocumentType],
     [DocumentNo_],
     [Description],
     [Amount],
     [TransactionNo_],
     [UserID],
     [BusinessUnitCode],
     [SourceNo_],
     [CurrencyCode],
     [OriginalCurrencyFactor],
     [Debit],
     [Credit],
     [DocumentDate],
     [ExternalDocumentNo_],
     [sc_Secuence],
     [ReasonCode],
     [aaTrxDimID],
     [aaTrxDim],
     [Dimension],
     [BATCH_ID],
     [Descripcion],
     [CuentaCargo]
 
FROM 
(
    select 
     t.id, 
     c.*,
     ROW_NUMBER()OVER(Partition by ID order by ID) as rn 
    from #Tempaqui t
        inner join #percepcionesVyPCLiqui c 
            on t.G_LAccountNo_ = c.G_LAccountNo_ 
            and t.cuenta = c.CuentaCargo
            and t.descripcion = c.Descripcion
            and t.[Description] = c.[Description]
            and t.cuentaC = c.CuentaContable
            
) k
     


      select 
      FORMAT(PostingDate,'MM/dd/yyyy') as [PostingDate],
      [G_LAccountNo_],
      [DocumentType],
      [DocumentNo_],
      [Description],
      CAST(Amount as decimal(18,2)) as [Amount],
      CAST(TransactionNo_ as int) as [TransactionNo_],
      [UserID],
      [BusinessUnitCode],
      [SourceNo_],
      [CurrencyCode],
      [OriginalCurrencyFactor],
      CAST(Debit as decimal(18,2)) as [Debit],
      CAST(Credit as decimal(18,2)) as [Credit],
      FORMAT(DocumentDate,'MM/dd/yyyy') as [DocumentDate],
      [ExternalDocumentNo_],
      ID * 500 as EntryNo_,
      [sc_Secuence],
      [ReasonCode],
      ID * 500 as SecNo_,
      CAST(aaTrxDimID as int) as [aaTrxDimID],
      [aaTrxDim],
      [Dimension],
      [BATCH_ID]
      from #Tempaqui 
      order by id
GO

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

CREATE PROC [Reportes].[spReportePolizaCCISN]  (    
		@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
		@IDUsuario int   
	) as   

	declare 
		 @empleados [RH].[dtEmpleados]              
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

        select @IDMes = CASE WHEN ISNULL(Value,0) = 0 THEN 0 ELSE  Value END
		from @dtFiltros where Catalogo = 'IDMes'

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
                                Select p.IDPeriodo 
                                    from Nomina.tblCatPeriodos p 
                                        inner join nomina.tblCatTipoNomina tp
                                         on tp.IDTipoNomina = p.IDTipoNomina 
                                    where Ejercicio = @Ejercicio 
                                        and IDMes = @IDMes 
                                        and Cerrado = 1 
                                        and ( General = 1 or Especial = 1 )
                                        and tp.IDCliente = (Select IDCliente from rh.tblCatClientes where Prefijo = 'MX') 
                                       
                            )   



		/*Fechas del periodo*/
		select top 1 @DescripcionPeriodo = Descripcion from @periodo where General = 1 order by Descripcion asc
        
        /* Descripcion de un campo de la poliza*/
        set @DocumentNo = (Select CONCAT('NOMINA ',Nombre,' ',@Ejercicio) from Utilerias.tblMeses where idmes = @IDMes)
        
        set @Mes = (select LOWER(Nombre) from Utilerias.tblMeses where idmes = @IDMes)
		
		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado & DENTRO DEL PERIODO SELECCIONADO */      
		insert into @empleados 
        --Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@FechaIni = @fechaIniPeriodo, @FechaFin = @fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario 
        exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @IDUsuario = @IDUsuario


		if object_id('tempdb..#percepcionesCC') is not null        
			drop table #percepcionesCC 

        if object_id('tempdb..#PercepcionesVyPCC') is not null        
			drop table #PercepcionesVyPCC--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPCLientCC') is not null        
			drop table #PercepcionesVyPCLientCC--Percepciones sin CC

        
        if object_id('tempdb..#percepcionesISN') is not null        
			drop table #percepcionesISN 

        if object_id('tempdb..#PercepcionesVyPISN') is not null        
			drop table #PercepcionesVyPISN--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPClientISN') is not null        
			drop table #PercepcionesVyPClientISN--Percepciones sin CC

    
		if object_id('tempdb..#deducciones') is not null        
			drop table #deducciones

        


/*********************TABLA TEMPORAL CONTRIBUCION SOCIAL*****************************/		 

SELECT 

            
			
            @fechaIniPeriodo as PostingDate,	
            Concat(Conceptos.CuentaCargo,'-',CentrosCostos.CuentaContable) AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Contribucion Social ',@Mes,' del ',@Ejercicio) as [Description],
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
            
                      
INTO #percepcionesCC
        FROM Nomina.tblDetallePeriodo detallePeriodo
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

        /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
		WHERE   CentrosCostos.cuentacontable not in ('1101','1103')           
				AND detallePeriodo.Importetotal1 <> 0
                and conceptos.IDConcepto in (162)  --512 y 540
                group by 
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                


    
                
               
/*********************TABLA TEMPORAL COSTO SOCIAL VEX Y PEGAS DESTINATION*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Contribucion Social ',@Mes,' del ',@Ejercicio) as [Description],
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
            
            
            
INTO #PercepcionesVyPCC
        FROM Nomina.tblDetallePeriodo detallePeriodo
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   conceptos.IDConcepto in (162)  --512 y 540
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable  in ('1101','1103')                             
                group by                
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
               

/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS CLIENT*****************************/		 

SELECT 

            
				
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('Contribucion Social ',@Mes,' del ',@Ejercicio) as [Description],
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
            
            
            
INTO #PercepcionesVyPCLientCC
        FROM Nomina.tblDetallePeriodo detallePeriodo
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
                                  
                   
		WHERE   conceptos.IDConcepto in (162)  --512 y 540       
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable  in ('1101','1103') 
                group by 
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                







/*********************TABLA TEMPORAL ISN*****************************/		 

SELECT 

            
			
            @fechaIniPeriodo as PostingDate,	
            Concat(Conceptos.CuentaCargo,'-',CentrosCostos.CuentaContable) AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('ISN ',@Mes,' del ',@Ejercicio) as [Description],
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
            
                      
INTO #percepcionesISN
        FROM Nomina.tblDetallePeriodo detallePeriodo
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

        /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
		WHERE   CentrosCostos.cuentacontable not in ('1101','1103')           
				AND detallePeriodo.Importetotal1 <> 0
                and conceptos.codigo = '540' 
                group by 
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
                


    
                
               
/*********************TABLA TEMPORAL ISN VEX Y PEGAS DESTINATION*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('ISN ',@Mes,' del ',@Ejercicio) as [Description],
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
            
            
            
INTO #PercepcionesVyPISN
        FROM Nomina.tblDetallePeriodo detallePeriodo
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE   conceptos.codigo = '540'  --512 y 540
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable  in ('1101','1103')                             
                group by                
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
               

/*********************TABLA TEMPORAL ISN VEX Y PEGAS CLIENT*****************************/		 

SELECT 

            
				
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            CONCAT('ISN ',@Mes,' del ',@Ejercicio) as [Description],
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
            
            
            
INTO #PercepcionesVyPClientISN
        FROM Nomina.tblDetallePeriodo detallePeriodo
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
                            Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                                INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
                                  
                   
		WHERE   conceptos.codigo = '540'  --512 y 540       
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable  in ('1101','1103') 
                group by 
                CentrosCostos.CuentaContable,
                suc.Descripcion,
                Conceptos.CuentaCargo
               
/*********************TABLA TEMPORAL DEDUCCIONES COSTO SOCIAL*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            Conceptos.CuentaAbono  as G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            case when Conceptos.Codigo = '540' then CONCAT('ISN ',@Mes,' del ',@Ejercicio)  else  CONCAT('Contribucion Social ',@Mes,' del ',@Ejercicio) END as [Description],
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
            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                    Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto                       
                            INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

		WHERE   conceptos.codigo in ('512','540')
				AND detallePeriodo.Importetotal1 <> 0 
                group by 
                Conceptos.CuentaAbono,
                Conceptos.Codigo 



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
        cuentaC VARCHAR(Max)
        
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
SELECT * from #percepcionesCC
        UNION
Select * from #percepcionesVyPCC
        UNION
SELECT * from #percepcionesISN
        UNION
Select * from #percepcionesVyPISN
        UNION
SELECT * FROM #deducciones 
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
        inner join #PercepcionesVyPCLientCC c 
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
        inner join #PercepcionesVyPClientISN c 
            on t.G_LAccountNo_ = c.G_LAccountNo_ 
            and t.cuenta = c.CuentaCargo
            and t.descripcion = c.Descripcion
            and t.[Description] = c.[Description]
            and t.cuentaC = c.CuentaContable          
) m
     


      select 
      FORMAT(PostingDate,'dd/MM/yyyy') as [PostingDate],
      [G_LAccountNo_],
      [DocumentType],
      [DocumentNo_],
      [Description],
      CAST(Amount as decimal(18,2)) as	[Amount],
      [TransactionNo_],
      [UserID],
      [BusinessUnitCode],
      [SourceNo_],
      [CurrencyCode],
      [OriginalCurrencyFactor],
      CAST(Debit as decimal(18,2)) as [Debit],
      CAST(Credit as decimal(18,2)) as [Credit],
      FORMAT(DocumentDate,'dd/MM/yyyy') as [DocumentDate],
      [ExternalDocumentNo_],
      ID * 500 as EntryNo_,
      [sc_Secuence],
      [ReasonCode],
      ID * 500 as SecNo_,
      [aaTrxDimID],
      [aaTrxDim],
      [Dimension],
      [BATCH_ID]
      from #Tempaqui 
      order by id
GO

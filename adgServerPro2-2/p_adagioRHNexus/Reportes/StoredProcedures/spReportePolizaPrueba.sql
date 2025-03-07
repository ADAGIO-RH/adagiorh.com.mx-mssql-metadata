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
CREATE PROC [Reportes].[spReportePolizaPrueba]  (    
		@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
		@IDUsuario int   
	) as   

	declare 
		 @empleados [RH].[dtEmpleados]  
		,@IDPeriodoSeleccionado int=0     
		,@periodo [Nomina].[dtPeriodos]                     
		,@empleadosTemp [RH].[dtEmpleados]        
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
        
    --------------------------------  
	--Se agrega para conocer si se esta utilizando el reporte--
	--------------------------------
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Seguridad].[tblUsuarios] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.idusuario = @IDUsuario

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reportes].[tblCatReportesBasicos]','[Reportes].[spReportePolizaPrueba]','GENERATE [Reportes].[spReportePolizaPrueba]',@NewJSON,@OldJSON
	---------------------------------

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
		where IDPeriodo in  ( @IDPeriodoSeleccionado  --2502
                                --Select p.IDPeriodo 
                                --    from Nomina.tblCatPeriodos p 
                                --        inner join nomina.tblCatTipoNomina tp
                                --         on tp.IDTipoNomina = p.IDTipoNomina 
                                --    where Ejercicio = @Ejercicio 
                                --        and IDMes = @IDMes 
                                --        and Cerrado = 1 
                                --        and ( General = 1 or Especial = 1 )
                                --        and tp.IDCliente = (Select IDCliente from rh.tblCatClientes where Prefijo = 'MX') 
                                --        and p.Descripcion not like '%AGUINALDO%'      
                            )   



		/*Fechas del periodo*/
		select top 1 @DescripcionPeriodo = Descripcion from @periodo where General = 1 order by Descripcion asc
        
        /* Descripcion de un campo de la poliza*/
        set @DocumentNo = (Select CONCAT('NOMINA ',Nombre,' ',@Ejercicio) from Utilerias.tblMeses where idmes = @IDMes)
        
        set @Mes = (select LOWER(Nombre) from Utilerias.tblMeses where idmes = @IDMes)
		
		/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado & DENTRO DEL PERIODO SELECCIONADO */      
	---	insert into @empleados 
        --Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@FechaIni = @fechaIniPeriodo, @FechaFin = @fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario 
      ---  exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @IDUsuario = @IDUsuario

			insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo =@IDPeriodoSeleccionado --2502--@IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
order by IDEmpleado


	--		begin
	--		select*

	--	from rh.tblEmpleadosMaster e
	--		join ( select hep.*
	--				from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
	--					join Nomina.tblCatPeriodos p on hep.IDPeriodo = 2584
	--			) historiales on e.IDEmpleado = historiales.IDEmpleado
	--		left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
	--	 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
	--		left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
	--		left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
	--		left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
	--		left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
	--		left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
	--		left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
	--		left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
	--		left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
	--		left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
	--		left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa
	--end		
	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario



			if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
			if object_id('tempdb..#tempData') is not null drop table #tempData

				select distinct 
		c.IDConcepto,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		c.Orden as OrdenCalculo,
		case when c.IDTipoConcepto in (1,4) then 1
			 when c.IDTipoConcepto = 2 then 2
			 when c.IDTipoConcepto = 3 then 3
			 when c.IDTipoConcepto = 6 then 4
			 when c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn,
			 c.CuentaAbono,
			 c.CuentaCargo,
			 c.Codigo			 
	into #tempConceptos
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where ccc.IDPais = isnull(151,0) OR ISNULL(151,0) = 0
		) c 
	

	Select
		 c.CuentaAbono
		,c.CuentaCargo
		,c.Codigo
		,p.IDPeriodo as IDPeriodo
		,c.IDConcepto
		,e.ClaveEmpleado	as CLAVE
		,e.IDEmpleado		as IDEmpleado
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,c.Concepto
		,c.OrdenCalculo
		,c.TipoConcepto
		,UPPER(isnull(Timbrado.UUID,'')) as UUID
		--,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		--,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = p.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado 
			
	Group by 
		e.IDEmpleado
		,c.IDConcepto
		,c.CuentaAbono
		,c.CuentaCargo
		,c.Codigo
		,p.IDPeriodo
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Concepto
		,c.OrdenCalculo
		,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
		,e.Division
		,e.CentroCosto
		,Timbrado.UUID
		,Estatustimbrado.Descripcion
		,Timbrado.Fecha
		,c.TipoConcepto
	ORDER BY e.ClaveEmpleado ASC
	--delete from @empleados where IDEmpleado <> 2179
	
		--select*from #tempData where CLAVE='MX00393'
		--return

		if object_id('tempdb..#percepciones') is not null        
			drop table #percepciones 

		if object_id('tempdb..#deducciones') is not null        
			drop table #deducciones

		--if object_id('tempdb..#deducciones2') is not null        
		--	drop table #deducciones2

        if object_id('tempdb..#PercepcionesVyP') is not null        
			drop table #PercepcionesVyP--Percepciones sin CC

        if object_id('tempdb..#PercepcionesVyPC') is not null        
			drop table #PercepcionesVyPC--Percepciones sin CC


/*********************TABLA TEMPORAL PERCEPCIONES*****************************/		 

SELECT 

            
			
            @fechaIniPeriodo as PostingDate,	
            Concat(detalleperiodo.CuentaCargo,'-',CentrosCostos.CuentaContable) AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            Case when Periodo.MesFin = 0 then CONCAT('1ra Nom de ',@Mes,' del ',@Ejercicio) ELSE CONCAT('2da Nom de ',@Mes,' del ',@Ejercicio) end  as [Description],
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
                when e.Sucursal = 'CANCUN' THEN 'CUN' 
                WHEN e.Sucursal  = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN e.Sucursal  = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN e.Sucursal = 'MAZATLAN' THEN 'MZT'
                WHEN e.Sucursal  = 'PUERTO VALLARTA' THEN 'PVR'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,e.Sucursal 
            ,detalleperiodo.CuentaCargo
            ,CentrosCostos.CuentaContable 
            ,Periodo.Descripcion as Pdescripcion 
			--,e.claveempleado
			--,detalleperiodo.Codigo
                      
INTO #percepciones
FROM @periodo Periodo
		INNER JOIN #tempData detalleperiodo with(nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		--LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
		--	on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	 --   INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		--INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

    --    FROM Nomina.tblDetallePeriodo detallePeriodo
    --        INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo  
				--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
    --            INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado 
		--                INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		                    INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = e.IDCentroCosto
  --  --                        Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
  --                              INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

        /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
		WHERE CentrosCostos.cuentacontable not in ('1101','1103')           
				AND detallePeriodo.Importetotal1 <> 0
                and detalleperiodo.TipoConcepto in('PERCEPCION', 'OTROS TIPOS DE PAGOS') AND detalleperiodo.Codigo not in ('168','170')
							--	and e.ClaveEmpleado='MX00393'

                group by 
                CentrosCostos.CuentaContable,
                e.Sucursal,	
                detalleperiodo.CuentaCargo,
                Periodo.Descripcion,
                Periodo.MesFin--,
				--e.claveempleado,
				--detalleperiodo.Codigo


               

			   --select*from #percepciones return
/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS DESTINATION*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            Case when Periodo.MesFin = 0 then CONCAT('1ra Nom de ',@Mes,' del ',@Ejercicio) ELSE CONCAT('2da Nom de ',@Mes,' del ',@Ejercicio) end  as [Description],
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
                when e.Sucursal = 'CANCUN' THEN 'CUN' 
                WHEN e.Sucursal = 'PLAYA DEL CARMEN' THEN 'RIV'
                WHEN e.Sucursal = 'SAN JOSE DEL CABO' THEN 'SJD'
                WHEN e.Sucursal = 'MAZATLAN' THEN 'MZT'
                WHEN e.Sucursal = 'PUERTO VALLARTA' THEN 'PVR'
                end as Dimension,
            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID  
            ,e.Sucursal
            ,detalleperiodo.CuentaCargo
            ,CentrosCostos.CuentaContable
            ,Periodo.Descripcion as Pdescripcion 
			--,e.ClaveEmpleado
			--,detalleperiodo.Codigo
            
            
INTO #percepcionesVyP
FROM @periodo Periodo
		INNER JOIN #tempData detalleperiodo with(nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		--LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
		--	on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	 --   INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		--INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

    --    FROM Nomina.tblDetallePeriodo detallePeriodo
    --        INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo 
				--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
    --            INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado      
    --                INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = e.IDCentroCosto
    --                        Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
    --                            INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto                                 
                       
		WHERE detalleperiodo.TipoConcepto in('PERCEPCION', 'OTROS TIPOS DE PAGOS') AND detalleperiodo.Codigo not in ('168','170')
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable  in ('1101','1103')                             
                group by                
                CentrosCostos.CuentaContable,
                e.Sucursal,
                detalleperiodo.CuentaCargo,
                Periodo.Descripcion,
                Periodo.MesFin--,
				--e.claveempleado,
				--detalleperiodo.Codigo



			--select*from 	#percepcionesVyP
/*********************TABLA TEMPORAL PERCEPCIONES VEX Y PEGAS CLIENT*****************************/		 

SELECT 

            
				
            @fechaIniPeriodo as PostingDate,
            case when CentrosCostos.cuentacontable like '%1101%' then '519100-01-1101'
                when CentrosCostos.cuentacontable like '%1103%' then  '519100-01-1103' 	
            END AS G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            Case when Periodo.MesFin = 0 then CONCAT('1ra Nom de ',@Mes,' del ',@Ejercicio) ELSE CONCAT('2da Nom de ',@Mes,' del ',@Ejercicio) end  as [Description],
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
            ,e.Sucursal  
            ,detalleperiodo.CuentaCargo
            ,CentrosCostos.CuentaContable 
            ,Periodo.Descripcion as Pdescripcion 
            
            
INTO #percepcionesVyPC
FROM @periodo Periodo
		INNER JOIN #tempData detalleperiodo with(nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		--LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
		--	on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	 --   INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		--INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

    --    FROM Nomina.tblDetallePeriodo detallePeriodo
    --        INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo   
				--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
    --            INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado   
				--				   --INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
    --                INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = e.IDCentroCosto
    --                        Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
    --                            INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
                                  
                   
		WHERE detalleperiodo.TipoConcepto in('PERCEPCION', 'OTROS TIPOS DE PAGOS') AND detalleperiodo.Codigo not in ('168','170')     
				AND detallePeriodo.Importetotal1 <> 0
                and CentrosCostos.cuentacontable  in ('1101','1103') 
                group by 
                CentrosCostos.CuentaContable,
                e.Sucursal,
                detalleperiodo.CuentaCargo,
                Periodo.Descripcion,
                Periodo.MesFin

                
--select*from #percepcionesVyPC
--return
/*********************TABLA TEMPORAL DEDUCCIONES*****************************/		 

SELECT 
            @fechaIniPeriodo as PostingDate,
            Case when detalleperiodo.CuentaAbono = '999999-01' then '999999-01-1001' Else detalleperiodo.CuentaAbono END  as G_LAccountNo_,
            ''As DocumentType,
            @DocumentNo as DocumentNo_,
            @DocumentNo as Description,
          case when detalleperiodo.Codigo in ('168','170' ) then (SUM(detallePeriodo.ImporteTotal1))   else -SUM ( detallePeriodo.ImporteTotal1 ) end AS Amount, 
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
            ,detalleperiodo.CuentaAbono
            ,0000 as CuentaContable 
            ,'Periodo.Descripcion' as Pdescripcion 
			--,e.ClaveEmpleado
			--,detalleperiodo.Codigo
			--,Empleados.ClaveEmpleado
			--,Conceptos.Codigo
			--,Empleados.Sucursal
			--,hist.IDHistorialEmpleadoPeriodo

			

            
INTO #deducciones
FROM @periodo Periodo
		INNER JOIN #tempData detalleperiodo with(nolock) on Periodo.IDPeriodo = detalleperiodo.IDPeriodo
		INNER JOIN @empleados e on detalleperiodo.IDEmpleado = e.IDEmpleado
		--LEFT JOIN  Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
		--	on Historial.IDPeriodo = Periodo.IDPeriodo and Historial.IDEmpleado = detalleperiodo.IDEmpleado
	 --   INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		--INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

   --     FROM Nomina.tblDetallePeriodo detallePeriodo
   --         INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo    
			--INNER JOIN  Nomina.tblHistorialesEmpleadosPeriodos hist on hist.IDPeriodo = Periodo.IDPeriodo and hist.IDEmpleado = detallePeriodo.IDEmpleado
   --             INNER JOIN @empleados Empleados on Empleados.IdEmpleado = hist.IdEmpleado                                         
   --                 INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
   --                 Inner Join rh.tblCatSucursales suc on suc.IDSucursal = hist.IDSucursal
                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = e.IDCentroCosto                       
   --                         INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

				WHERE  (detalleperiodo.TipoConcepto = 'DEDUCCION' or detalleperiodo.Codigo = '601' OR (detalleperiodo.TipoConcepto='OTROS TIPOS DE PAGOS' and detalleperiodo.Codigo in( '168','170')))
             and detalleperiodo.cuentaabono <> ''
				AND detallePeriodo.Importetotal1 <> 0 
                group by 
                detalleperiodo.CuentaAbono,  --SI APLICA
				--Empleados.ClaveEmpleado,
				--Empleados.Sucursal,
				--hist.IDHistorialEmpleadoPeriodo,
								detalleperiodo.Codigo  --SI APLICA
								--,e.ClaveEmpleado
--select*from #deducciones return
				 -- CentrosCostos.CuentaContable,
					--suc.Descripcion,
     --           Conceptos.CuentaCargo,
     --           Periodo.Descripcion,
     --           Periodo.MesFin


--SELECT 
--            @fechaIniPeriodo as PostingDate,
--            Case when Conceptos.CuentaAbono = '999999-01' then '999999-01-1001' Else Conceptos.CuentaAbono END  as G_LAccountNo_,
--            ''As DocumentType,
--            @DocumentNo as DocumentNo_,
--            @DocumentNo as Description,
--            - SUM ( detallePeriodo.ImporteTotal1 ) AS Amount, 
--            1 as TransactionNo_,
--            'nrivera' as UserID, 
--            '' as BusinessUnitCode,  
--            '' as SourceNo_, 
--            'MXN' as CurrencyCode, 
--            '' as OriginalCurrencyFactor,          
--            '0.00' AS Debit,
--			SUM ( detallePeriodo.ImporteTotal1 ) AS Credit,
--            @fechainiperiodo as DocumentDate,
--            '' as ExternalDocumentNo_,
--            '' as sc_Secuence,
--            '' as ReasonCode,
--            1 as aaTrxDimID,
--            'Destination' as aaTrxDim,
--            'CUN' as Dimension,
--            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
--            ,'' as Descripcion
--            ,Conceptos.CuentaAbono
--            ,0000 as CuentaContable 
--            ,'Periodo.Descripcion' as Pdescripcion 
			

            
--INTO #deducciones
--        FROM Nomina.tblDetallePeriodo detallePeriodo
--            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
--                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
--                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
--                    Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
--                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto                       
--                            INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

--		WHERE  (tiposConceptos.Descripcion = 'DEDUCCION' or Conceptos.Codigo = '601')
--                and conceptos.cuentaabono <> ''
--				AND detallePeriodo.Importetotal1 <> 0 
--                group by 
--                Conceptos.CuentaAbono 
				
				

--				SELECT 
--            @fechaIniPeriodo as PostingDate2,
--           Case when Conceptos.CuentaAbono = '999999-01' then '999999-01-1001' Else Conceptos.CuentaAbono END  as G_LAccountNo_,
--            ''As DocumentType,
--            @DocumentNo as DocumentNo_,
--            @DocumentNo as Description,
--            - SUM ( detallePeriodo.ImporteTotal1 ) AS Amount, 
--            1 as TransactionNo_,
--            'nrivera' as UserID, 
--            '' as BusinessUnitCode,  
--            '' as SourceNo_, 
--            'MXN' as CurrencyCode, 
--            '' as OriginalCurrencyFactor,          
--            '0.00' AS Debit,
--			SUM ( detallePeriodo.ImporteTotal1 ) AS Credit,
--            @fechainiperiodo as DocumentDate,
--            '' as ExternalDocumentNo_,
--            '' as sc_Secuence,
--            '' as ReasonCode,
--            1 as aaTrxDimID,
--            'Destination' as aaTrxDim,
--            'CUN' as Dimension,
--            CONCAT('Payroll ',@IDMes,' ',@Ejercicio) as BATCH_ID 
--            ,'' as Descripcion
--            ,Conceptos.CuentaAbono
--            ,0000 as CuentaContable 
--            ,'Periodo.Descripcion' as Pdescripcion 
			

            
--INTO #deducciones2
--        FROM Nomina.tblDetallePeriodo detallePeriodo
--            INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo                                                    
--                INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado                                         
--                    INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
--                    Inner Join rh.tblCatSucursales suc on suc.IDSucursal = Empleados.IDSucursal
--                        INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto                       
--                            INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

--		WHERE  (Conceptos.Codigo = '168' )
--		 group by 
--       Conceptos.CuentaAbono,
--	       CentrosCostos.CuentaContable,
--	   suc.Descripcion,
--                Conceptos.CuentaCargo,
--                Periodo.Descripcion,
--                Periodo.MesFin



    --           -- and conceptos.cuentaabono <> ''
				--AND detallePeriodo.Importetotal1 <> 0 
    --            group by 
    --            Conceptos.CuentaAbono,
				--Conceptos.Codigo

			--select*from #deducciones return
			
				
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
        PDescripcion VARCHAR(MAX)
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
        Sucursal as Descripcion,
        CuentaCargo,
        CuentaContable,
        Pdescripcion
FROM
(
SELECT * from #percepciones
        UNION
Select * from #percepcionesVyP
    
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
     Sucursal as [Descripcion],
     [CuentaCargo]
 
FROM 
(
    select 
     t.id, 
     c.*,
     ROW_NUMBER()OVER(Partition by ID order by ID) as rn 
    from #Tempaqui t
        inner join #percepcionesVyPC c 
            on t.G_LAccountNo_ = c.G_LAccountNo_ 
            and t.cuenta = c.CuentaCargo
            and t.descripcion = c.Sucursal
            and t.[Description] = c.[Description]
            and t.cuentaC = c.CuentaContable
            and t.PDescripcion = c.Pdescripcion
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

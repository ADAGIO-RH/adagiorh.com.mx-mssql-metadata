USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

  
CREATE PROC [Reportes].[spReportePolizaSapCLOE](    
		@dtFiltros Nomina.dtFiltrosRH readonly    
	,@IDUsuario int    
) as   

declare 
		@empleados [RH].[dtEmpleados]        
	,@IDPeriodoSeleccionado int=0        
	,@periodo [Nomina].[dtPeriodos]        
	,@configs [Nomina].[dtConfiguracionNomina]        
	,@Conceptos [Nomina].[dtConceptos]        
	,@IDTipoNomina int     
	,@fechaIniPeriodo  date        
	,@fechaFinPeriodo  date    
	,@RazonSocial int   
	,@beneficiario int
	,@periodoSeleccionado int
	
	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
		THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		else 0  
	END 

	set @beneficiario = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'BeneficiarioContratacion'),',')) 
		THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'BeneficiarioContratacion'),','))  
		else 0  
	END 

	/* Se buscan el periodo seleccionado */    
	insert into @periodo  
	select   
			IDPeriodo  
		,IDTipoNomina  
		,Ejercicio  
		,ClavePeriodo  
		,Descripcion  
		,FechaInicioPago  
		,FechaFinPago  
		,FechaInicioIncidencia  
		,FechaFinIncidencia  
		,Dias  
		,AnioInicio  
		,AnioFin  
		,MesInicio  
		,MesFin  
		,IDMes  
		,BimestreInicio  
		,BimestreFin  
		,Cerrado  
		,General  
		,Finiquito  
		,isnull(Especial,0)  
	from Nomina.tblCatPeriodos  
		where ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))       
		
		     
	select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
	insert into @empleados        
		exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	if object_id('tempdb..#tempConceptos') is not null        
		drop table #tempConceptos   
  
       
	if object_id('tempdb..#tempData') is not null        
		drop table #tempData 

	if object_id('tempdb..#beneficiarios') is not null        
		drop table #beneficiarios 

	if object_id('tempdb..#percepciones') is not null        
		drop table #percepciones 

	if object_id('tempdb..#deducciones') is not null        
		drop table #deducciones

	select IDEmpleado, IDRazonSocial , ROW_NUMBER() OVER (PARTITION BY R.IDEMPLEADO ORDER BY R.fechaIni DESC ) AS ORDEN 
		into #beneficiarios
			from [RH].[tblRazonSocialEmpleado] R

	delete from #beneficiarios where orden <> 1

	delete from #beneficiarios where IdRazonSocial <> @beneficiario

	SELECT 
		CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION'THEN 
			[Utilerias].[fnArreglarCuentasSAP] ( Conceptos.CuentaCargo , 2, 
					SUBSTRING ( Conceptos.CuentaCargo  , CHARINDEX ('-' , Conceptos.CuentaCargo   +'-' ) + 1, LEN (Conceptos.CuentaCargo ) + 1 ) )

				WHEN tiposConceptos.Descripcion = 'INFORMATIVO'THEN 
				[Utilerias].[fnArreglarCuentasSAP] ( Conceptos.CuentaCargo , 2, 
					SUBSTRING ( CentrosCostos.CuentaContable , CHARINDEX ('-' , CentrosCostos.CuentaContable +'-') + 1, LEN (CentrosCostos.CuentaContable) + 1 ) )

				WHEN tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'THEN Conceptos.CuentaCargo
				END AS CUENTA,
		CentrosCostos.Codigo as NORMA_REPARTO,
		ISNULL ( SUBSTRING(CentrosCostos.CuentaContable, 1 , CHARINDEX(' ', CentrosCostos.CuentaContable + ' ' ) -1) , 'SIN CUENTA' ) AS CCOSTO,
		--ISNULL ( CentrosCostos.Codigo, '' ) + ' ' + ISNULL ( CentrosCostos.Descripcion ,'' ) AS DESCRIPCION , 
		ISNULL ( CentrosCostos.Descripcion ,'' ) AS DESCRIPCION , 
		ISNULL ( Periodo.Descripcion,'') as NOMBRELARGO,
		Conceptos.Codigo AS IDCONCEPTO,
		Conceptos.Descripcion AS DESCRICPION_CONCEPTO ,
		CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION' THEN 'P' 
				WHEN tiposConceptos.Descripcion = 'DEDUCCION' THEN 'D' 
				ELSE 'C'
				END AS TIPOCONCEPTO,
		SUM ( detallePeriodo.ImporteTotal1 ) AS DEBITO,
		0 AS CREDITO,
		periodo.ClavePeriodo as IDPERIODO,
		Ra.RFC as Subcontratante

	INTO #percepciones
	FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
		INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
			INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
				INNER JOIN #beneficiarios beneficiarios on  beneficiarios.IdEmpleado = Empleados.IdEmpleado -- JOIN PARA FILTRAR BENEFICIARIOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto -- JOIN PARA CENTROS DE COSTO
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
								INNER JOIN RH.tblCatRazonesSociales Ra on Ra.IDRazonSocial = beneficiarios.IDRazonSocial
	WHERE ( ( ( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS'
			OR ( tiposConceptos.Descripcion = 'INFORMATIVO' AND Conceptos.Codigo IN ( '508', '509', '510', '507','540' ,'530' ) ) ) AND
				( Conceptos.CuentaCargo <> '' OR Conceptos.CuentaCargo IS NOT NULL ) )
			AND detallePeriodo.Importetotal1 <> 0 )
	GROUP BY tiposConceptos.Descripcion,
				CentrosCostos.Codigo,
				CentrosCostos.Descripcion,
				CentrosCostos.CuentaContable,
				Conceptos.CuentaCargo,
				Empleados.CentroCosto, 
				Conceptos.Descripcion, 
				Conceptos.IDConcepto,
				Conceptos.Codigo,
				periodo.Descripcion,
				periodo.ClavePeriodo,
				Ra.RFC
	ORDER BY  empleados.CentroCosto, Conceptos.IDConcepto


	SELECT 
	--CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION' THEN Conceptos.CuentaAbono

			CASE WHEN tiposConceptos.Descripcion = 'DEDUCCION' THEN Conceptos.CuentaAbono
				--[Utilerias].[fnArreglarCuentasCloe] ( Conceptos.CuentaAbono , 2, 
				--  SUBSTRING ( CentrosCostos.CuentaContable , CHARINDEX ('-' , CentrosCostos.CuentaContable ) + 1, LEN (CentrosCostos.CuentaContable) + 1 ) )
        

				WHEN tiposConceptos.Descripcion = 'INFORMATIVO'THEN Conceptos.CuentaAbono
			--[Utilerias].[fnArreglarCuentasCloe] ( Conceptos.CuentaAbono , 2, 
				--  SUBSTRING ( CentrosCostos.CuentaContable , CHARINDEX ('-' , CentrosCostos.CuentaContable ) + 1, LEN (CentrosCostos.CuentaContable) + 1 ) )

				WHEN tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO'THEN 
				CASE WHEN Periodo.IDTipoNomina = '4' THEN Conceptos.CuentaAbono--Pago de nómina Semanal
						--[Utilerias].[fnArreglarCuentasCloe] ( Conceptos.CuentaAbono , 3, '002' )
						WHEN Periodo.IDTipoNomina = '5' THEN Conceptos.CuentaAbono--Pago de nómina Quincenal
						--[Utilerias].[fnArreglarCuentasCloe] ( Conceptos.CuentaAbono , 3, '001' )
						END
				END  AS CUENTA,
		CentrosCostos.Codigo as NORMA_REPARTO,
		ISNULL ( SUBSTRING(CentrosCostos.CuentaContable, 1 , CHARINDEX(' ', CentrosCostos.CuentaContable + ' ' ) -1) , 'SIN CUENTA' ) AS CCOSTO,
		--ISNULL ( CentrosCostos.Codigo, '' ) + ' ' + ISNULL ( CentrosCostos.Descripcion ,'' ) AS DESCRIPCION , 
		ISNULL ( CentrosCostos.Descripcion ,'' ) AS DESCRIPCION ,
		ISNULL ( Periodo.Descripcion,'') as NOMBRELARGO,
		Conceptos.Codigo AS IDCONCEPTO,
		Conceptos.Descripcion AS DESCRICPION_CONCEPTO ,
		CASE WHEN tiposConceptos.Descripcion = 'PERCEPCION' THEN 'P' 
				WHEN tiposConceptos.Descripcion = 'DEDUCCION' THEN 'D' 
				ELSE 'C'
				END AS TIPOCONCEPTO,
		0 AS DEBITO,
		SUM ( detallePeriodo.ImporteTotal1 ) AS CREDITO,
		periodo.ClavePeriodo as IDPERIODO,
		Ra.RFC as Subcontratante
	INTO #deducciones
	FROM Nomina.tblDetallePeriodo detallePeriodo	-- DETALLE DE PERIODO
		INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo -- JOIN CONTRA EL PERIODO
			INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado -- JOIN CONTRA EMPLEADOS
				INNER JOIN #beneficiarios beneficiarios on  beneficiarios.IdEmpleado = Empleados.IdEmpleado -- JOIN PARA FILTRAR BENEFICIARIOS
					INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto --JOIN PARA CONCEPTOS
						INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto -- JOIN PARA CENTROS DE COSTO
							INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto
								INNER JOIN RH.tblCatRazonesSociales Ra on Ra.IDRazonSocial = beneficiarios.IDRazonSocial
	WHERE ( ( ( tiposConceptos.Descripcion = 'DEDUCCION' /*OR tiposConceptos.Descripcion = 'PERCEPCION'*/ OR tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO' 
			OR ( tiposConceptos.Descripcion = 'INFORMATIVO' AND Conceptos.Codigo IN ( '508', '509', '510', '507', '540', '530' ) ) ) AND
				( Conceptos.CuentaAbono <> '' OR Conceptos.CuentaAbono IS NOT NULL ) )
				--AND ( Conceptos.CuentaCargo  IS NOT NULL OR Conceptos.CuentaCargo <> '' ) )
					AND detallePeriodo.Importetotal1 <> 0 )
	GROUP BY tiposConceptos.Descripcion,
				CentrosCostos.Codigo,
				CentrosCostos.Descripcion,
				CentrosCostos.CuentaContable,
				Conceptos.CuentaAbono,
			-- Conceptos.CuentaCargo,
				Empleados.CentroCosto, 
				Conceptos.Descripcion, 
				Conceptos.IDConcepto,
				Conceptos.Codigo,
				periodo.Descripcion,
				periodo.ClavePeriodo,
				Periodo.IDTipoNomina,
				Ra.RFC
		
	ORDER BY  empleados.CentroCosto, Conceptos.IDConcepto


	SELECT * from 
		#percepciones 
			UNION
				SELECT * FROM #deducciones
GO

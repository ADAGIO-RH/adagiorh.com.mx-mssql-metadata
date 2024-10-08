USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReportePolizaSapRUGGED](    
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
		,@patronal int
		,@periodoSeleccionado int
		,@DeduccionesEnNegativo bit = 0
	;

	set @IDTipoNomina = 
		case when exists (Select top 1 cast(item as int) 
						from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
			then (Select top 1 cast(item as int) 
				from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		else 0 end 

	set @patronal = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) 
		THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
		else 0  
	END 

	set @DeduccionesEnNegativo = 
		case when exists (Select top 1 cast(item as bit) 
						from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'DeduccionesEnNegativo'),',')) 
			then (Select top 1 cast(item as bit) 
				from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'DeduccionesEnNegativo'),','))  
		else 0 end 

	/* Se buscan el periodo seleccionado */    
	insert into @periodo  
	select   *
		--IDPeriodo  
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
		where ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
			or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))    

	/*Fechas del periodo*/
	select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo 
		
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado & DENTRO DEL PERIODO SELECCIONADO */      
	insert into @empleados 
    --Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@FechaIni = @fechaIniPeriodo, @FechaFin = @fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario 
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	if object_id('tempdb..#percepciones') is not null drop table #percepciones;
	if object_id('tempdb..#deducciones') is not null drop table #deducciones;
	if object_id('tempdb..#PercepcionesSCC') is not null drop table #PercepcionesSCC; --Percepciones sin CC

/*********************TABLA TEMPORAL PERCEPCIONES*****************************/		 

	SELECT 
		Conceptos.CuentaCargo AS Account,	
		ISNULL ( SUBSTRING(CentrosCostos.CuentaContable, 1 , CHARINDEX(' ', CentrosCostos.CuentaContable + ' ' ) -1) , 'SIN CUENTA' ) AS CostCenter,
		SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
		'0.00' AS Credit,
		Conceptos.Descripcion as Description
	INTO #percepciones
	FROM Nomina.tblDetallePeriodo detallePeriodo
		INNER JOIN @periodo Periodo							on  detallePeriodo.IDPeriodo = periodo.IDPeriodo	-- JOIN CONTRA EL PERIODO
		INNER JOIN @empleados Empleados						on Empleados.IdEmpleado = detallePeriodo.IdEmpleado	-- JOIN CONTRA EMPLEADOS
		INNER JOIN Nomina.tblCatConceptos Conceptos			on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN RH.tblCatCentroCosto CentrosCostos		on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

    /*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
	WHERE ( 
			( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS' ) 
			AND ( Conceptos.CuentaCargo <> '' OR Conceptos.CuentaCargo IS NOT NULL ) 
		)
		AND (Conceptos.IDConcepto not in (192))
		AND Conceptos.CuentaCargo not in( '210002','210075') 
		AND detallePeriodo.Importetotal1 <> 0
    group by 
        Conceptos.CuentaCargo,
        CentrosCostos.CuentaContable,
        Conceptos.Descripcion

/*********************TABLA TEMPORAL DEDUCCIONES*****************************/		 

	SELECT 
		Conceptos.CuentaAbono AS Account,
		'' AS CostCenter,
		'0.00' AS Debit,
		case 
			when @DeduccionesEnNegativo = 1 and tiposConceptos.Descripcion in ('DEDUCCION','CONCEPTOS DE PAGO') then SUM (detallePeriodo.ImporteTotal1 ) * -1 
		else SUM ( detallePeriodo.ImporteTotal1 )  end AS Credit,
		Conceptos.Descripcion as [Description]
	INTO #deducciones
	FROM Nomina.tblDetallePeriodo detallePeriodo
		INNER JOIN @periodo Periodo							on detallePeriodo.IDPeriodo = periodo.IDPeriodo		-- JOIN CONTRA EL PERIODO
		INNER JOIN @empleados Empleados						on Empleados.IdEmpleado = detallePeriodo.IdEmpleado	-- JOIN CONTRA EMPLEADOS
		INNER JOIN Nomina.tblCatConceptos Conceptos			on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN RH.tblCatCentroCosto CentrosCostos		on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

	/*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
	WHERE ( ( ( tiposConceptos.Descripcion = 'DEDUCCION'  OR tiposConceptos.Descripcion = 'CONCEPTOS DE PAGO' )
		AND (Conceptos.IDConcepto not in (202)) --Vales de despensa
		AND ( Conceptos.CuentaAbono <> '' OR Conceptos.CuentaAbono IS NOT NULL ) )
		AND detallePeriodo.Importetotal1 <> 0 )	
	group by 
		Conceptos.CuentaAbono,
		Conceptos.Descripcion,
		tiposConceptos.Descripcion 

---------------------------------------------------------
	SELECT 
		Conceptos.CuentaCargo AS Account,	
		'' AS CostCenter,
		SUM ( detallePeriodo.ImporteTotal1 ) AS Debit,
		'0.00' AS Credit,
		Conceptos.Descripcion as [Description]
	INTO #percepcionesSCC
	FROM Nomina.tblDetallePeriodo detallePeriodo
		INNER JOIN @periodo Periodo on  detallePeriodo.IDPeriodo = periodo.IDPeriodo		-- JOIN CONTRA EL PERIODO
		INNER JOIN @empleados Empleados on Empleados.IdEmpleado = detallePeriodo.IdEmpleado	-- JOIN CONTRA EMPLEADOS
		INNER JOIN Nomina.tblCatConceptos Conceptos on Conceptos.IDConcepto = detallePeriodo.IdConcepto
		INNER JOIN RH.tblCatCentroCosto CentrosCostos on CentrosCostos.IDCentroCosto = Empleados.IDCentroCosto
		INNER JOIN Nomina.tblCatTipoConcepto tiposConceptos on tiposConceptos.IDTipoConcepto = Conceptos.IDTipoConcepto 

	/*Aqui seleccionamos todos los conceptos que vamos a utilizar en la tabla de #percepciones*/                      
	WHERE ( ( ( tiposConceptos.Descripcion = 'PERCEPCION' OR tiposConceptos.Descripcion = 'OTROS TIPOS DE PAGOS' ) 
		AND ( Conceptos.CuentaCargo <> '' OR Conceptos.CuentaCargo IS NOT NULL ) )
		AND (Conceptos.IDConcepto not in (192)) 
		AND Conceptos.CuentaCargo in ('210002','210075')
		AND detallePeriodo.Importetotal1 <> 0 )	

	group by 
		Conceptos.CuentaCargo,
		Conceptos.Descripcion

    SELECT * from #percepciones
    UNION
	SELECT * FROM #deducciones 
    UNION
	SELECT * FROM #percepcionesSCC 
    ORDER BY Credit	
        
GO

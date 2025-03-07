USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReporteAguinaldo_Excel_Personal_Con_Impuesto](
  @dtFiltros Nomina.dtFiltrosRH readonly    
 ,@IDUsuario int    
) as    
    
declare @empleados [RH].[dtEmpleados]        
 ,@IDPeriodoSeleccionado int=0        
 ,@periodo [Nomina].[dtPeriodos]        
 ,@configs [Nomina].[dtConfiguracionNomina]        
 ,@Conceptos [Nomina].[dtConceptos]        
 ,@IDTipoNomina int     
 ,@fechaIni  date        
 ,@fechaFin  date  
 ,@FechaIniVigencia date
 ,@FechaFinVigencia date
 ,@Incidencias varchar(max)
 ,@Ausentismos varchar(max)
 ,@Ejercicio int
 ,@Afectar Varchar(10) = 'FALSE'
 ,@IDPeriodoInicial int
 ,@IDConceptoAguinaldo int
 ,@TipoIncapacidad varchar(max)
 ;    


 DECLARE 
		@ClaveEmpleado varchar(20) 
		,@IDEmpleado int 
		,@i int = 0 
		,@Codigo varchar(20) = '130' 
		,@IDConcepto int 
		--,@dtDetallePeriodoLocal [Nomina].[dtDetallePeriodo] 
		,@IDPeriodo int 
		--,@IDTipoNomina int 
		--,@Ejercicio int 
		,@ClavePeriodo varchar(20) 
		,@DescripcionPeriodo	varchar(250) 
		,@FechaInicioPago date 
		,@FechaFinPago date 
		,@FechaInicioIncidencia date 
		,@FechaFinIncidencia	date 
		,@Dias int 
		,@AnioInicio bit 
		,@AnioFin bit 
		,@MesInicio bit 
		,@MesFin bit 
		,@IDMes int 
		,@BimestreInicio bit 
		,@BimestreFin bit 
		,@General bit 
		,@Finiquito bit 
		,@Especial bit 
		,@Cerrado bit 
		,@PeriodicidadPago Varchar(100)
		,@isPreviewFiniquito bit 
		,@IDCalculo int              
		,@PeriodicidadesPagoDias int 
		,@IDConcepto005 int --- DIAS PAGADOS
		,@IDConcepto002 int --- DIAS VACACIONES
		,@IDPais int
		,@DiasAguinaldoExcento int = 30  
		,@UMA Decimal(18,2) 
	;
  
  

  select top 1 @IDConceptoAguinaldo = IDConcepto from Nomina.tblCatConceptos where Codigo = '130' -- AGUINALDO

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
					  else 0  
					END  
 
	set @Ejercicio = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))  
					  else DATEPART(YEAR, GETDATE()) 
					END  
	set @fechaIni = cast(@Ejercicio as varchar(4))+'-01-01';
	set @fechaFin = cast(@Ejercicio as varchar(4))+'-12-31';
  
	set @FechaIniVigencia = case when exists (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) THEN (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
					  else getdate() 
					END  
	set @FechaFinVigencia = case when exists (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) THEN (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  
					  else getdate() 
					END  
  
  	set @Incidencias = case when exists (Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'),',')) THEN ((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'))  
					  else ''
					END  
  	set @Ausentismos = case when exists (Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')) THEN ((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'))  
					  else ''
					END 
	 set @TipoIncapacidad = case when exists (Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'),',')) THEN ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'))  
					  else ''
					END 

	set @IDPeriodoInicial = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
					  else 0  
					END  
	set @Afectar = case when exists (Select top 1 cast(item as varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),',')) THEN (Select top 1 cast(item as Varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),','))  
					  else 'FALSE' 
					END  

			if object_id('tempdb..#TempCatTiposPrestacionesDetalle') is not null
				drop table #TempCatTiposPrestacionesDetalle

				select * 
					into #TempCatTiposPrestacionesDetalle
				from RH.tblCatTiposPrestacionesDetalle
  
 -- /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@FechaIniVigencia, @Fechafin = @FechaFinVigencia ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     


		/* Variables Para el Calculo*/            
  DECLARE @IDPeriodicidadPagoMensual int,            
       @IDPeriodicidadPagoPeriodo int    



	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from nomina.tblcatperiodos 
 
	select top 1 @IDConcepto=IDConcepto from nomina.tblcatconceptos where Codigo='130'; 
 	select top 1 @IDConcepto005=IDConcepto from nomina.tblcatconceptos where Codigo='005'; 
	select top 1 @IDConcepto002=IDConcepto from nomina.tblcatconceptos where Codigo='002'; 

	DECLARE
		@Concepto_IDConcepto int
		,@Concepto_Codigo varchar(20)
		,@Concepto_Descripcion varchar(100)
		,@Concepto_IDTipoConcepto int
		,@Concepto_Estatus bit
		,@Concepto_Impresion bit
		,@Concepto_IDCalculo int
		,@Concepto_CuentaAbono varchar(50)
		,@Concepto_CuentaCargo  varchar(50)
		,@Concepto_bCantidadMonto bit
		,@Concepto_bCantidadDias bit
		,@Concepto_bCantidadVeces bit
		,@Concepto_bCantidadOtro1 bit
		,@Concepto_bCantidadOtro2 bit
		,@Concepto_IDCodigoSAT int
		,@Concepto_NombreProcedure varchar(200)
		,@Concepto_OrdenCalculo int
		,@Concepto_LFT bit
		,@Concepto_Personalizada bit
		,@Concepto_ConDoblePago bit;
		
		
	select top 1 
		@Concepto_IDConcepto = IDConcepto 
		,@Concepto_Codigo  = Codigo 
		,@Concepto_Descripcion = Descripcion
		,@Concepto_IDTipoConcepto = IDTipoConcepto 
		,@Concepto_Estatus = Estatus 
		,@Concepto_Impresion = Impresion 
		,@Concepto_IDCalculo = IDCalculo 
		,@Concepto_CuentaAbono = CuentaAbono 
		,@Concepto_CuentaCargo = CuentaCargo 
		,@Concepto_bCantidadMonto = bCantidadMonto
		,@Concepto_bCantidadDias = bCantidadDias
		,@Concepto_bCantidadVeces = bCantidadVeces
		,@Concepto_bCantidadOtro1 = bCantidadOtro1
		,@Concepto_bCantidadOtro2 = bCantidadOtro2 
		,@Concepto_IDCodigoSAT = IDCodigoSAT
		,@Concepto_NombreProcedure = NombreProcedure 
		,@Concepto_OrdenCalculo = OrdenCalculo
		,@Concepto_LFT = LFT
		,@Concepto_Personalizada = Personalizada 
		,@Concepto_ConDoblePago = ConDoblePago
	from Nomina.tblCatConceptos where Codigo=@Codigo;	



	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina


	select top 1 @IDPeriodicidadPagoMensual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Mensual'  
	
    -- Saca Periodicidad de Pago y Dias del periodo    
	Select TOP 1 
		 @IDPeriodicidadPagoPeriodo = tn.IDPeriodicidadPago            
		,@PeriodicidadesPagoDias = case when pp.Descripcion = 'Semanal'		then 7              
										when pp.Descripcion = 'Catorcenal'	then 14              
										when pp.Descripcion = 'Quincenal'	then 15              
										when pp.Descripcion = 'Mensual'		then 30              
										when pp.Descripcion = 'Decenal'		then 10              
									else 1              
									END 
		,@IDPais = tn.IDPais
	from Nomina.tblCatTipoNomina tn            
		left join sat.tblCatPeriodicidadesPago pp             
		on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago                    
	where IDTipoNomina = @IDTipoNomina     

	
	IF NOT EXISTS(Select *             
				from Nomina.tbltablasImpuestos  TI            
					INNER JOIN Nomina.tblDetalleTablasImpuestos DTI            
					on DTI.IDTablaImpuesto = TI.IDTablaImpuesto    
					INNER JOIN Nomina.tblCatTipoCalculoISR CTCI    
					on CTCI.IDCalculo = TI.IDCalculo      
				WHERE TI.Ejercicio = @Ejercicio
				AND TI.IDPais = @IDPais
				AND CTCI.Codigo = 'ISR_SUELDOS'            
				AND TI.IDPeriodicidadPago = (select top 1 IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Mensual' )            
	)            
	BEGIN            
		RAISERROR('La tabla de ISR para esta periodicidad de pago Mensual y Ejercicio no existe.',16,1);            
	END  


	if object_id('tempdb..#TempISRGratificacionesAnuales') is not null drop table #TempISRGratificacionesAnuales;     
	if object_id('tempdb..#TempISRGratificacionesAnualFinal') is not null drop table #TempISRGratificacionesAnualFinal;    
	if object_id('tempdb..#TempISRTotal') is not null drop table #TempISRTotal;    
	if object_id('tempdb..#tempAguinaldoGravado') is not null drop table #tempAguinaldoGravado;    

 	 /* @configs: Contiene todos los parametros de configuración de la nómina. */ 
 	 /* @empleados: Contiene todos los trabajadores a calcular.*/ 
 
	/* 
	Descomenta esta parte de código si necesitas recorrer la lista de trabajadores 
 
	select @i=min(RowNumber) from @dtempleados; 
 
	while exists(select 1 from @empleados where RowNumber >= @i) 
	begin 
 		select @IDEmpleado=IDEmpleado, @ClaveEmpleado=ClaveEmpleado from @dtempleados where RowNumber =@i; 
 		print @ClaveEmpleado 
 		select @i=min(RowNumber) from @empleados where RowNumber > @i; 
	end;  
	*/ 


CREATE TABLE #TempISRGratificacionesAnualFinal  
	(  
		IDEmpleado int,  
		IDConcepto int,  
		IDPeriodo int,  
		ISR142 Decimal(28,4)  
	)  

	select dp.IDEmpleado as IDEmpleado                   
     ,SUM(dp.ImporteGravado) as Gravado           
		into #tempAguinaldoGravado
	from nomina.tblDetallePeriodo dp            
		inner join Nomina.tblCatConceptos c            
		on dp.IDConcepto = c.IDConcepto      
			and c.IDPais = @IDPais 
		inner join Nomina.tblCatTipoCalculoISR ti            
		on ti.IDCalculo = c.IDCalculo            
		inner join Nomina.tblCatTipoConcepto TC    
		on TC.IDTipoConcepto = c.IDTipoConcepto    
	where ti.Codigo = 'ISR_AGUINALDO_PTU'            
	and tc.Descripcion = 'PERCEPCION'      
	Group by dp.IDEmpleado  






	
		if object_id('tempdb..#TempDatosAfectar') is not null
				drop table #TempDatosAfectar
	
	
	-----INICIO  CALCULO IMPORTE DE AGUINALDO---
	
		if object_id('tempdb..#TempAguinaldoAI') is not null
			drop table #TempAguinaldoAI

	select
		  Empleados.IDEmpleado
		, Empleados.ClaveEmpleado as [Clave]
		,ImporteAguinaldo = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin))) * Empleados.SalarioDiario		
		into #TempAguinaldoAI
	from @empleados Empleados
		left join RH.tblCatDepartamentos depto with(nolock)
			on Empleados.IDDepartamento = depto.IDDepartamento
		left join RH.tblCatSucursales Suc with(nolock)
			on Empleados.IDSucursal = Suc.IDSucursal
		left join RH.tblCatPuestos Puestos with(nolock)
			on Empleados.IDPuesto = Puestos.IDPuesto
		left join RH.tblCatTiposPrestaciones TP with(nolock)
			on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD
			on Empleados.IDTipoPrestacion = TPD.IDTipoPrestacion
			and TPD.Antiguedad = CEILING([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)) 
	ORDER BY Empleados.ClaveEmpleado ASC

	-----FIN  CALCULO IMPORTE DE AGUINALDO---

	--select*from #TempAguinaldoAI order by Clave
	--return


	--- EVALUACION DE EXENTOS Y GRAVADOS DE IMPORTE TOTAL DE AGUINALDO ---

	IF object_ID('TEMPDB..#TempValoresGeneral') IS NOT NULL DROP TABLE #TempValoresGeneral
	IF object_ID('TEMPDB..#TempValoresAg') IS NOT NULL DROP TABLE #TempValoresAg

	set @Ejercicio='2024'
	
	select top 1 @UMA = UMA   
     from Nomina.tblSalariosMinimos  
     Where YEAR(Fecha) = @Ejercicio  
     order by fecha desc  
 

 --select @UMA,@Ejercicio

 --return
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN (ISNULL(DTLocal.CantidadDias,0) * CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
																																			ELSE ISNULL(cf.SueldoFiniquito,0) END)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE 
						(CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
							 ELSE ISNULL(cf.SueldoFiniquito,0) END) * ISNULL(cf.DiasAguinaldo,0)
				END Valor
			,AcumuladoAguinaldo.ImporteGravado AImporteGravado  
			,AcumuladoAguinaldo.ImporteExento AImporteExento  
			,AcumuladoAguinaldo.ImporteTotal1 AImporteTotal1  
			,AcumuladoAguinaldo.ImporteTotal2 AImporteTotal2  
			
			--,ImporteGravado =  CASE WHEN AImporteExento >= (@DiasAguinaldoExcento*@UMA) THEN @importeaguinaldobruto
			--				   WHEN @importeaguinaldobruto <= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) THEN 0
			--				   WHEN @importeaguinaldobruto >= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) then @importeaguinaldobruto - ((@DiasAguinaldoExcento*@UMA) - AImporteExento)
			--			ELSE 0
			--			END,  
			--ImporteExcento = CASE WHEN AImporteExento >= (@DiasAguinaldoExcento*@UMA) THEN 0	
			--				   WHEN Valor <= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) THEN Valor
			--				   WHEN Valor >= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) then ((@DiasAguinaldoExcento*@UMA) - AImporteExento)
			--			ELSE 0
			--			end
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							  
		INTO #TempValoresGeneral
		FROM @empleados Empleados
			Left Join Nomina.tblDetallePeriodo DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join Nomina.tblControlFiniquitos cf
				on cf.IDEmpleado = Empleados.IDEmpleado
				and cf.IDPeriodo = @IDPeriodo
			CROSS APPLY Nomina.fnObtenerAcumuladoPorConcepto(Empleados.IDEmpleado,59,@Ejercicio) as AcumuladoAguinaldo  
			

	--select	Clave,Empleados.IDEmpleado,IAT.ImporteAguinaldo,(@DiasAguinaldoExcento*@UMA) as MAX_exento, ImporteGravado =  CASE WHEN 0 >= (@DiasAguinaldoExcento*@UMA) THEN IAT.ImporteAguinaldo --aguinaldo valor
	--						   WHEN IAT.ImporteAguinaldo <= ((@DiasAguinaldoExcento*@UMA) - 0) THEN 0
	--						   WHEN IAT.ImporteAguinaldo >= ((@DiasAguinaldoExcento*@UMA) - 0) then IAT.ImporteAguinaldo - ((@DiasAguinaldoExcento*@UMA) - 0)  --aguinaldo valor
	--					ELSE 0
	--					end,

	--						ImporteExcento = CASE WHEN 0 >= (@DiasAguinaldoExcento*@UMA) THEN 0	
	--						   WHEN IAT.ImporteAguinaldo <= ((@DiasAguinaldoExcento*@UMA) - 0) THEN IAT.ImporteAguinaldo
	--						   WHEN IAT.ImporteAguinaldo >= ((@DiasAguinaldoExcento*@UMA) - 0) then ((@DiasAguinaldoExcento*@UMA) - 0)
	--					ELSE 0
	--					end

	--						FROM @empleados Empleados
		
	--	--Left Join Nomina.tblDetallePeriodo DTLocal
	--	--		on Empleados.IDEmpleado = DTLocal.IDEmpleado
	--	--Left Join #TempValoresGeneral vg on  vg.IDEmpleado = Empleados.IDEmpleado
	--	left join #TempAguinaldoAI IAT on IAT.IDEmpleado = Empleados.IDEmpleado
	--	return




	SELECT  distinct  Empleados.ClaveEmpleado,Empleados.IDEmpleado,IAT.ImporteAguinaldo,
	
	ImporteGravado =  CASE WHEN ACUMA.AImporteExento >= (@DiasAguinaldoExcento*@UMA) THEN IAT.ImporteAguinaldo --aguinaldo valor
							   WHEN IAT.ImporteAguinaldo <= ((@DiasAguinaldoExcento*@UMA) - ACUMA.AImporteExento) THEN 0
							   WHEN IAT.ImporteAguinaldo >= ((@DiasAguinaldoExcento*@UMA) - ACUMA.AImporteExento) then IAT.ImporteAguinaldo - ((@DiasAguinaldoExcento*@UMA) - ACUMA.AImporteExento)  --aguinaldo valor
						ELSE 0
						END,  
	ImporteExcento = CASE WHEN ACUMA.AImporteExento >= (@DiasAguinaldoExcento*@UMA) THEN 0	
							   WHEN IAT.ImporteAguinaldo <= ((@DiasAguinaldoExcento*@UMA) - ACUMA.AImporteExento) THEN IAT.ImporteAguinaldo
							   WHEN IAT.ImporteAguinaldo >= ((@DiasAguinaldoExcento*@UMA) - ACUMA.AImporteExento) then ((@DiasAguinaldoExcento*@UMA) - ACUMA.AImporteExento)
						ELSE 0
						end
INTO #TempValoresAg
		FROM @empleados Empleados
		
		--Left Join Nomina.tblDetallePeriodo DTLocal
		--		on Empleados.IDEmpleado = DTLocal.IDEmpleado
		inner Join #TempValoresGeneral ACUMA on  ACUMA.IDEmpleado = Empleados.IDEmpleado
		inner join #TempAguinaldoAI IAT on IAT.IDEmpleado = Empleados.IDEmpleado

--select distinct *from #TempValoresAg  
	--ImporteGravado =  CASE WHEN AImporteExento >= (@DiasAguinaldoExcento*@UMA) THEN @importeaguinaldobruto
	--						   WHEN @importeaguinaldobruto <= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) THEN 0
	--						   WHEN @importeaguinaldobruto >= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) then @importeaguinaldobruto - ((@DiasAguinaldoExcento*@UMA) - AImporteExento)
	--					ELSE 0
	--					END,  
	--				ImporteExcento = CASE WHEN AImporteExento >= (@DiasAguinaldoExcento*@UMA) THEN 0	
	--						   WHEN Valor <= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) THEN Valor
	--						   WHEN Valor >= ((@DiasAguinaldoExcento*@UMA) - AImporteExento) then ((@DiasAguinaldoExcento*@UMA) - AImporteExento)
	--					ELSE 0
		
		
		--- FINALIZA EVALUACION DE EXENTOS Y GRAVADOS DE IMPORTE TOTAL DE AGUINALDO ---

		----CALCULO DE IMPUESTO 301A (ART 174 REGLAMENTO PTU AGUINALDO)---
BEGIN            
		select e.IDEmpleado as IDEmpleado            
		   ,@IDConcepto as IDConcepto            
		   ,@IDPeriodo as IDPeriodo  
		   ,e.SalarioDiario  
		   ,@Ejercicio ejercicio        
		   ,Nomina.fnISRGratificacionesAnuales(@IDPeriodicidadPagoMensual,(isnull(e.SalarioDiario,0)*30.4),@Ejercicio,@IDPais ) ISRSalarioOrdinario            
		   ,aguinaldo.ImporteGravado GRAVADO            
		   ,case when isnull(aguinaldo.ImporteGravado,0) > 0 THEN Nomina.fnISRGratificacionesAnuales(@IDPeriodicidadPagoMensual,((e.SalarioDiario*30.4)+(aguinaldo.ImporteGravado/365*30.4)),@Ejercicio,@IDPais) ELSE 0 END ISR142          
		   , ((e.SalarioDiario*30.4)+(aguinaldo.ImporteGravado/365*30.4)) base          
		   , (e.SalarioDiario*30.4) ordi          
		into #TempISRGratificacionesAnuales             
		from @empleados e 
			left join #TempValoresAg aguinaldo
				on e.IDEmpleado = aguinaldo.IDEmpleado
		
        --select * from #TempISR142            
            
		insert into #TempISRGratificacionesAnualFinal(IDEmpleado,IDConcepto,IDPeriodo,ISR142)  
        select IDEmpleado,IDConcepto,IDPeriodo,ISR142 = CASE WHEN GRAVADO > 0 then ((((ISR142 - ISRSalarioOrdinario)/((GRAVADO/365)*30.4)))*GRAVADO) ELSE 0 END            
        from  #TempISRGratificacionesAnuales   
		where GRAVADO > 0          
	 


	 CREATE TABLE #TempISRTotal    
    (    
		IDEmpleado int,    
		ISRTotal Decimal(18,4)    
    )     
             
    insert into #TempISRTotal(IDEmpleado,ISRTotal)    
    SELECT t.IDEmpleado, SUM(t.ISRNormal)     
    FROM (    
    SELECT ISRGRatificacionesAnuales.IDEmpleado    
        ,ISRGRatificacionesAnuales.ISR142 as ISRNormal    
    FROM #TempISRGratificacionesAnualFinal ISRGRatificacionesAnuales    
    ) T    
    GROUP BY t.IDEmpleado    
	--ISR GRATIFICACIONES ANUALES  
 

 --------FINALIZA CALCULO DE IMPUESTO 301A (ART 174 REGLAMENTO PTU AGUINALDO)---

--select*From #TempISRTotal  return

	select
		  Empleados.IDEmpleado
		, Empleados.ClaveEmpleado as [Clave]
		, Empleados.NOMBRECOMPLETO as [NOMBRE COMPLETO]
		, depto.Codigo +' - '+ depto.Descripcion as [DEPTO]
		,empleados.TipoNomina AS [TIPO NOMINA]
		, Suc.Codigo +' - '+ Suc.Descripcion as [SUCURSAL]
		, Puestos.Codigo +' - '+ Puestos.Descripcion as [PUESTO]
		, tp.Codigo +' - '+tp.Descripcion as [PRESTACION]
		, Empleados.Empresa as [RAZON SOCIAL]
		, FORMAT(Empleados.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
		, [Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin) as [ANIOS CUMPLIDOS]
		, CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin) + 1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+ 1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END [DIAS TRABAJADOS EJERCICIO]
		, [Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [INCAPACIDADES]
		, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [INCIDENCIAS]
		, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [AUSENTISMOS]

		, [DIAS A PAGAR] = ((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			   +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			   ))
		, [DIAS PRESTACION AGUINALDO] = TPD.DiasAguinaldo

		,[DIAS A PAGAR AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			   ))

		,[SALARIO DIARIO] = Empleados.SalarioDiario

		,[SALARIO DIARIO REAL] = Empleados.SalarioDiarioReal

		,[IMPORTE AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin))) * Empleados.SalarioDiario

		,[IMPORTE AGUINALDO REAL] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin))) * Empleados.SalarioDiarioReal
			,[ISR_REGLAMENTO_AGUINALDO_PTU] = ISNULL(ISR.ISRTotal,0)
			,[TOTAL A PAGAR] = 
			ISNULL(
			(CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin))) * Empleados.SalarioDiario- isnull(ISR.ISRTotal,0) , 0)



		into #TempDatosAfectar
	from @empleados Empleados
		left join RH.tblCatDepartamentos depto with(nolock)
			on Empleados.IDDepartamento = depto.IDDepartamento
		left join RH.tblCatSucursales Suc with(nolock)
			on Empleados.IDSucursal = Suc.IDSucursal
		left join RH.tblCatPuestos Puestos with(nolock)
			on Empleados.IDPuesto = Puestos.IDPuesto
		left join RH.tblCatTiposPrestaciones TP with(nolock)
			on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD
			on Empleados.IDTipoPrestacion = TPD.IDTipoPrestacion
			and TPD.Antiguedad = CEILING([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)) 
		left join #TempISRTotal isr on isr.idempleado= empleados.idempleado 
	ORDER BY Empleados.ClaveEmpleado ASC

	SELECT 
		[Clave]
		, [NOMBRE COMPLETO]
		, [DEPTO]
		,[TIPO NOMINA]
		, [SUCURSAL]
		, [PUESTO]
		, [PRESTACION]
		, [RAZON SOCIAL]
		, [FECHA ANTIGUEDAD]
		, [ANIOS CUMPLIDOS]
		, [DIAS TRABAJADOS EJERCICIO]
		, [INCAPACIDADES]
		, [INCIDENCIAS]
		, [AUSENTISMOS]
		, [DIAS A PAGAR]
		, [DIAS PRESTACION AGUINALDO] 
		, [DIAS A PAGAR AGUINALDO] 
		, [SALARIO DIARIO] 
		, [SALARIO DIARIO REAL]
		, [IMPORTE AGUINALDO]
		, [IMPORTE AGUINALDO REAL]
		, [ISR_REGLAMENTO_AGUINALDO_PTU]
		, [TOTAL A PAGAR]
	FROM #TempDatosAfectar
	ORDER BY Clave ASC

	IF(@Afectar = 'TRUE')
	BEGIN
		MERGE Nomina.tblDetallePeriodo AS TARGET
		USING #TempDatosAfectar AS SOURCE
			ON TARGET.IDPeriodo = @IDPeriodoInicial
				and TARGET.IDConcepto = @IDConceptoAguinaldo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.[IMPORTE AGUINALDO] ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoAguinaldo,  
			isnull(SOURCE.[IMPORTE AGUINALDO] ,0)
			)
		;
	END

	END
GO

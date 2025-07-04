USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: ISR CAUSADO
** Autor			: Aneudy Abreu | Jose Román,
** Email			: aneudy.abreu@adagio.com.mx | jose.roman@adagio.com.mx
** FechaCreacion	: 2019-08-12
** Paremetros		:              
** Versión 1.2 

** DataTypes Relacionados: 
  @dtconfigs [Nomina].[dtConfiguracionNomina]  
  @dtempleados [RH].[dtEmpleados]  
  @dtConceptos [Nomina].[dtConceptos]  
  @dtPeriodo [Nomina].[dtPeriodos]  
  @dtDetallePeriodo [Nomina].[dtDetallePeriodo] 


  VARIABLES A REEMPLAZAR (SIN LOS ESPACIOS)

  {{ DescripcionConcepto }}
  {{ CodigoConcepto }}

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROC [Nomina].[spConcepto_079_TELECT_PATY]( 
	@dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
	,@dtempleados [RH].[dtEmpleados] READONLY 
	,@dtConceptos [Nomina].[dtConceptos] READONLY 
	,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
	,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY
) 
AS 
BEGIN 

	DECLARE 
		@ClaveEmpleado varchar(20) 
		,@IDEmpleado int 
		,@i int = 0 
		,@Codigo varchar(20) = '079' 
		,@IDConcepto int 
		,@IDConceptoSubsidio int             
		,@dtDetallePeriodoLocal [Nomina].[dtDetallePeriodo]             
		,@dtDetallePeriodoSubSidio [Nomina].[dtDetallePeriodo] 
		,@IDPeriodo int 
		,@IDTipoNomina int 
		,@Ejercicio int 
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
		,@IDConcepto301 int --- ISR
		,@IDConcepto007 int --Septimo Dia
		,@IDConcepto550 int --TotalPercepciones
		,@ISRProporcional int
		,@ISRProporcionalFiniquitos int
		,@IDPais int
		,@IDCalculoISRSueldos int
		,@SalarioMinimo decimal(18,2)
		,@SalarioMinimoFronterizo decimal(18,2)
		,@IDConcepto008 INT
		,@IDConcepto009 int --Permisos con goce

	;

	/* Variables Para el Calculo*/            
	DECLARE @IDPeriodicidadPagoMensual int,            
			@IDPeriodicidadPagoPeriodo int    

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConcepto005=IDConcepto from @dtConceptos where Codigo='005'; 
	select top 1 @IDConcepto002=IDConcepto from @dtConceptos where Codigo='002'; 
	select top 1 @IDConcepto301=IDConcepto from @dtConceptos where Codigo='301'; 
	select top 1 @IDConcepto007=IDConcepto from @dtConceptos where Codigo='007';  
	select top 1 @IDConcepto550=IDConcepto from @dtConceptos where Codigo='550';  
	select top 1 @IDConcepto009=IDConcepto from @dtConceptos where Codigo='009'; 
	select top 1 @IDConcepto008=IDConcepto from @dtConceptos where Codigo='008';

	Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina with(nolock)  
	where Configuracion = 'ISRProporcional'

	Select top 1 @ISRProporcionalFiniquitos = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina with(nolock) 
	where Configuracion = 'ISRProporcionalFiniquito'

	select top 1 @SalarioMinimo = SalarioMinimo, @SalarioMinimoFronterizo = SalarioMinimoFronterizo
	from Nomina.tblsalariosminimos 
	where YEAR(Fecha) >= YEAR(@FechaInicioPago) order by Fecha desc


 
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
	from @dtConceptos where Codigo=@Codigo;
		
	insert into @dtDetallePeriodoLocal 
	select * from @dtDetallePeriodo where IDConcepto=@IDConcepto 
 
 	select top 1 @isPreviewFiniquito = cast(isnull(valor,0) as bit) 
	from @dtconfigs
	where Configuracion = 'isPreviewFiniquito'

	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina

	select top 1 @IDPeriodicidadPagoMensual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago with(nolock)  where Descripcion = 'Mensual'  

	select top 1 @IDCalculoISRSueldos = IDCalculo       
		from Nomina.tblCatTipoCalculoISR  with(nolock)      
		WHERE Codigo = 'ISR_SUELDOS'   


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
	from Nomina.tblCatTipoNomina tn with(nolock)            
		left join sat.tblCatPeriodicidadesPago pp with(nolock)              
		on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago                    
	where IDTipoNomina = @IDTipoNomina     

	-- Valida si tabla de ISR de la periodicidad existe    
	IF NOT EXISTS(Select *             
				from Nomina.tbltablasImpuestos  TI with(nolock)            
					INNER JOIN Nomina.tblDetalleTablasImpuestos DTI with(nolock)             
						on DTI.IDTablaImpuesto = TI.IDTablaImpuesto    
					INNER JOIN Nomina.tblCatTipoCalculoISR CTCI with(nolock)    
						on CTCI.IDCalculo = TI.IDCalculo      
				WHERE TI.Ejercicio = @Ejercicio            
					AND CTCI.Codigo = 'ISR_SUELDOS'
					AND TI.IDPais = @IDPais
					AND TI.IDPeriodicidadPago = @IDPeriodicidadPagoPeriodo            
		)            
	BEGIN            
		RAISERROR('La tabla de ISR para esta periodicidad de pago y Ejercicio no existe.',16,1);            
	END 

	IF NOT EXISTS(Select *             
				from Nomina.tbltablasImpuestos  TI with(nolock)             
					INNER JOIN Nomina.tblDetalleTablasImpuestos DTI with(nolock)            
					on DTI.IDTablaImpuesto = TI.IDTablaImpuesto    
					INNER JOIN Nomina.tblCatTipoCalculoISR CTCI with(nolock)    
					on CTCI.IDCalculo = TI.IDCalculo      
				WHERE TI.Ejercicio = @Ejercicio   
				AND CTCI.Codigo = 'ISR_SUELDOS' 
				AND TI.IDPais = @IDPais
				AND TI.IDPeriodicidadPago = (select top 1 IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Mensual' )            
	)            
	BEGIN            
		RAISERROR('La tabla de ISR para esta periodicidad de pago Mensual y Ejercicio no existe.',16,1);            
	END  

	-- Valida si tabla de ISR de la periodicidad existe  
	-- Verificacion de Tabla Temporal de GRAVADO Y DIAS    
	if object_id('tempdb..#TempGravadoPeriodo') is not null drop table #TempGravadoPeriodo;     
	if object_id('tempdb..#TempDiasPeriodo') is not null drop table #TempDiasPeriodo;     
	if object_id('tempdb..#TempISRNormal') is not null drop table #TempISRNormal;     
	if object_id('tempdb..#TempISRGratificacionesAnuales') is not null drop table #TempISRGratificacionesAnuales;     
	if object_id('tempdb..#TempISRGratificacionesAnualFinal') is not null drop table #TempISRGratificacionesAnualFinal;    
	if object_id('tempdb..#TempISRTotal') is not null drop table #TempISRTotal;    
	if object_id('tempdb..#TempISRAjusta') is not null drop table #TempISRAjusta; 
	if object_id('tempdb..#TempGravadoPeriodoTotalFiniquito') is not null drop table #TempGravadoPeriodoTotalFiniquito; 
	if object_id('tempdb..#TempISRNormalFiniquito') is not null drop table #TempISRNormalFiniquito; 
	if object_id('tempdb..#tempISRFinalFiniquito') is not null drop table tempISRFinalFiniquito; 

	IF(@General = 1 or @Especial = 1)
	BEGIN
		--SACAR GRAVADO DEL PERIODO     
		select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as Gravado
		   ,CAST(0.00 as Decimal(18,2))  as AcumGravPeriodosAnteriores
		into #TempGravadoPeriodo         
		from @dtDetallePeriodo dp            
			inner join @dtConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			inner join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'      
		group by dp.IDEmpleado     
		--SACAR GRAVADO DEL PERIODO  




		update GP
			set GP.AcumGravPeriodosAnteriores = Acum.ImporteGravado
		From #TempGravadoPeriodo GP
			Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](GP.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) Acum

		--select * from #TempGravadoPeriodo
		-- Elimina lo registros de los colaboradores que no tiene Importe gravado en el periodo
		delete dtl
		from @dtDetallePeriodoLocal dtl
			left join #TempGravadoPeriodo tgp on dtl.IDEmpleado = tgp.IDEmpleado 
		WHERE tgp.IDEmpleado is null or tgp.Gravado = 0

		--ISR NORMAL    
		Select gp.IDEmpleado    
			, 
			--CASE WHEN isnull(S.Fronterizo,0) = 1 AND isnull(dtEmpleados.SalarioDiario,0) <= isnull(@SalarioMinimoFronterizo,0) and isnull(ts.Descripcion,'Fijo') = 'Fijo'THEN 0
			--	   WHEN isnull(S.Fronterizo,0) = 0 AND isnull(dtEmpleados.SalarioDiario,0) <= isnull(@SalarioMinimo,0) and isnull(ts.Descripcion,'Fijo') = 'Fijo' THEN 0
			--	ELSE
					CASE WHEN @ISRProporcional in (0,1,2,3) THEN [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo,gp.Gravado,(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0) + ISNULL(dtPermisosConGoce.ImporteTotal1,0) + ISNULL(dtDiasPendientes.ImporteTotal1,0)),@Ejercicio, @MesFin, @IDPais,0)
						  WHEN @ISRProporcional = 4 THEN 
									CASE WHEN @MesFin = 1 THEN [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoMensual,(gp.Gravado + gp.AcumGravPeriodosAnteriores),0,@Ejercicio, @MesFin,@IDPais,0) - ISNULL(AcumISR.ImporteTotal1,0)
										 ELSE [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo,(gp.Gravado),0,@Ejercicio, @MesFin,@IDPais,0)
										 END
						  WHEN @ISRProporcional = 5 then [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo
																				,(gp.Gravado+(select top 1 ImporteGravado from [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorEjercicioTipoISR](GP.IDEmpleado,1,@Ejercicio,2)))
																				,(
																					isnull(dtDiasPagados.ImporteTotal1,0)
																					+isnull(dtDiasVacaciones.ImporteTotal1,0)
																					+isnull(dtSeptimoDia.ImporteTotal1,0)
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto005,@Ejercicio))
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto002,@Ejercicio))
																					+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto007,@Ejercicio))
																				)
																				,@Ejercicio
																				,@MesFin
																				,@IDPais,0) -  +(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto,@Ejercicio))
					  ELSE 0
					 END 
			-- END
			 as ISR 
			 ,gp.AcumGravPeriodosAnteriores
			 ,gp.Gravado
			 ,AcumISR.ImporteTotal1 AcumISR
		into #TempISRNormal    
		from #TempGravadoPeriodo GP   
			left join @dtDetallePeriodo dtDiasPagados
				on gp.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- Dias Pagados
			left join @dtDetallePeriodo dtDiasVacaciones
				on gp.IDEmpleado = dtDiasVacaciones.IDEmpleado
					and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- Dias Vacaciones
			left join @dtDetallePeriodo dtSeptimoDia
				on dtSeptimoDia.IDEmpleado = gp.IDEmpleado
					and dtSeptimoDia.IDConcepto = @IDConcepto007
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](GP.IDEmpleado,@IDConcepto,@IDMes,@Ejercicio)  as AcumISR --Acumulado ISR Causado
			left join @dtEmpleados dtEmpleados
				on GP.IDEmpleado = dtEmpleados.IDEmpleado
			left join RH.tblCatSucursales s with(nolock)
				on s.IDSucursal = dtEmpleados.IDSucursal
			left join RH.tblTipoTrabajadorEmpleado tte with(nolock)
				on tte.IDEmpleado = dtEmpleados.IDEmpleado
			left join imss.tblcatTipoSalario ts with(nolock)
				on tte.IDTipoSalario = ts.IDTipoSalario
			left join  @dtDetallePeriodo dtPermisosConGoce
			on dtPermisosConGoce.IDEmpleado = gp.IDEmpleado
				and dtPermisosConGoce.IDConcepto = @IDConcepto009   --Permisos Con Goce
			left join  @dtDetallePeriodo dtDiasPendientes
			on dtDiasPendientes.IDEmpleado = gp.IDEmpleado
				and dtDiasPendientes.IDConcepto = @IDConcepto008 
		where gp.Gravado > 0 
    
		--print 'ALGO'

		--select * from #TempISRNormal
		--ISR GRATIFICACIONES ANUALES    
          
		CREATE TABLE #TempISRTotal    
		(    
			IDEmpleado int,    
			ISRTotal Decimal(18,4)    
		)     
             
		insert into #TempISRTotal(IDEmpleado,ISRTotal)    
		SELECT t.IDEmpleado, SUM(t.ISR)     
		FROM (    
		SELECT ISRNormal.IDEmpleado,    
			ISRNormal.ISR     
			from #TempISRNormal ISRNormal    
		) T    
		GROUP BY t.IDEmpleado    
		--ISR GRATIFICACIONES ANUALES  

		MERGE @dtDetallePeriodoLocal AS TARGET            
		USING #TempISRTotal AS SOURCE            
			ON TARGET.IDPeriodo = @IDPeriodo          
			and TARGET.IDConcepto = @IDConcepto           
			and TARGET.IDEmpleado = SOURCE.IDEmpleado                
		WHEN MATCHED Then            
			update            
			Set                 
			TARGET.ImporteTotal1  = SOURCE.ISRTotal                  
		WHEN NOT MATCHED BY TARGET THEN             
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)            
			VALUES(SOURCE.IDEmpleado,@IDPeriodo,@IDConcepto,Source.ISRTotal)
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;      
	END ELSE 
	IF(@Finiquito = 1)
	BEGIN
		--SACAR GRAVADO DEL PERIODO     

		--SACAR GRAVADO DEL PERIODO     
		select dp.IDEmpleado as IDEmpleado                   
		   ,SUM(dp.ImporteGravado) as Gravado
		   ,CAST(0.00 as Decimal(18,2))  as AcumGravPeriodosAnteriores
		into #TempGravadoPeriodoFiniquito         
		from @dtDetallePeriodo dp            
			inner join @dtConceptos c            
				on dp.IDConcepto = c.IDConcepto   
				and c.IDPais = @IDPais
			inner join Nomina.tblCatTipoCalculoISR ti with (nolock)            
				on ti.IDCalculo = c.IDCalculo            
			inner join Nomina.tblCatTipoConcepto TC with (nolock)    
				on TC.IDTipoConcepto = c.IDTipoConcepto    
		where ti.Codigo = 'ISR_SUELDOS' 
			and tc.Descripcion = 'PERCEPCION'      
		group by dp.IDEmpleado     
		--SACAR GRAVADO DEL PERIODO  

		update GP
			set GP.AcumGravPeriodosAnteriores = Acum.ImporteGravado
		From #TempGravadoPeriodoFiniquito GP
			Cross Apply [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorMesTipoISR](GP.IDEmpleado,1,@IDMes,@Ejercicio,@IDCalculoISRSueldos) Acum

		--select * from #TempGravadoPeriodo
		-- Elimina lo registros de los colaboradores que no tiene Importe gravado en el periodo
		delete dtl
		from @dtDetallePeriodoLocal dtl
			left join #TempGravadoPeriodoFiniquito tgp on dtl.IDEmpleado = tgp.IDEmpleado 
		WHERE tgp.IDEmpleado is null or tgp.Gravado = 0
		--SACAR GRAVADO DEL PERIODO     

		-- Elimina lo registros de los colaboradores que no tiene Importe gravado en el periodo

		--ISR NORMAL    
		Select gp.IDEmpleado    
			--,[Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoMensual,gp.Gravado,30.4,@Ejercicio,0,@IDPais) as ISR    
			,CASE WHEN @ISRProporcionalFiniquitos in (0,1,2,3) THEN [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo,gp.Gravado,(isnull(dtDiasPagados.ImporteTotal1,0)+isnull(dtDiasVacaciones.ImporteTotal1,0)+isnull(dtSeptimoDia.ImporteTotal1,0) + ISNULL(dtPermisosConGoce.ImporteTotal1,0) + ISNULL(dtDiasPendientes.ImporteTotal1,0)),@Ejercicio, @MesFin, @IDPais,1)
				  WHEN @ISRProporcionalFiniquitos = 4 THEN 
							CASE WHEN @MesFin = 1 THEN [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoMensual,(gp.Gravado + gp.AcumGravPeriodosAnteriores),0,@Ejercicio, @MesFin,@IDPais,1) - ISNULL(AcumISR.ImporteTotal1,0)
								 ELSE [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo,(gp.Gravado),0,@Ejercicio, @MesFin,@IDPais,1)
								 END
				  WHEN @ISRProporcionalFiniquitos = 5 then [Nomina].[fnCoreISRSUELDOS](@IDPeriodicidadPagoPeriodo
																		,(gp.Gravado+(select top 1 ImporteGravado from [Nomina].[fnObtenerAcumuladoPorTipoConceptoPorEjercicioTipoISR](GP.IDEmpleado,1,@Ejercicio,2)))
																		,(
																			isnull(dtDiasPagados.ImporteTotal1,0)
																			+isnull(dtDiasVacaciones.ImporteTotal1,0)
																			+isnull(dtSeptimoDia.ImporteTotal1,0)
																			+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto005,@Ejercicio))
																			+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto002,@Ejercicio))
																			+(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto007,@Ejercicio))
																		)
																		,@Ejercicio
																		,@MesFin
																		,@IDPais,1) -  +(select top 1 ImporteTotal1 from [Nomina].[fnObtenerAcumuladoPorConcepto](GP.IDEmpleado,@IDConcepto,@Ejercicio))
			  ELSE 0
			 END as ISR 
		into #TempISRNormalFiniquito    
		from #TempGravadoPeriodoFiniquito GP   
			left join @dtDetallePeriodo dtDiasPagados
				on gp.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- Dias Pagados
			left join @dtDetallePeriodo dtDiasVacaciones
				on gp.IDEmpleado = dtDiasVacaciones.IDEmpleado
					and dtDiasVacaciones.IDConcepto = @IDConcepto002 -- Dias Vacaciones
			left join @dtDetallePeriodo dtSeptimoDia
				on dtSeptimoDia.IDEmpleado = gp.IDEmpleado
					and dtSeptimoDia.IDConcepto = @IDConcepto007
			left join  @dtDetallePeriodo dtPermisosConGoce
			on dtPermisosConGoce.IDEmpleado = gp.IDEmpleado
				and dtPermisosConGoce.IDConcepto = @IDConcepto009   --Permisos Con Goce
			left join  @dtDetallePeriodo dtDiasPendientes
			on dtDiasPendientes.IDEmpleado = gp.IDEmpleado
				and dtDiasPendientes.IDConcepto = @IDConcepto008 
			Cross apply Nomina.[fnObtenerAcumuladoPorConceptoPorMes](GP.IDEmpleado,@IDConcepto,@IDMes,@Ejercicio)  as AcumISR --Acumulado ISR Causado
		where gp.Gravado > 0 

		select t.IDEmpleado, (t.ISR) ISR
			into #tempISRFinalFiniquito
		from #TempISRNormalFiniquito t
			Cross Apply Nomina.fnObtenerAcumuladoPorConceptoPorMes(t.IDEmpleado,@IDConcepto301,@IDMes,@Ejercicio) ac

		MERGE @dtDetallePeriodoLocal AS TARGET            
		USING #tempISRFinalFiniquito AS SOURCE            
			ON TARGET.IDPeriodo = @IDPeriodo          
			and TARGET.IDConcepto = @IDConcepto           
			and TARGET.IDEmpleado = SOURCE.IDEmpleado                
		WHEN MATCHED Then            
			update            
			Set                 
			TARGET.ImporteTotal1  = SOURCE.ISR                  
		WHEN NOT MATCHED BY TARGET THEN             
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)            
			VALUES(SOURCE.IDEmpleado,@IDPeriodo,@IDConcepto,Source.ISR)
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;      
	END
    
	--update @dtDetallePeriodoLocal
	--	set ImporteTotal1 = 0.00
	--where CantidadOtro2 = -1

	update @dtDetallePeriodoLocal
		set ImporteTotal1 = CASE WHEN CantidadOtro2 = -1 THEN 0.00
								 WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(CantidadMonto,0) > 0 THEN ISNULL(CantidadMonto,0)
								ELSE ImporteTotal1
							END
    
	Select  *
	from @dtDetallePeriodoLocal              
		where (isnull(ImporteTotal1,0)) > 0 

		
	--Select * from @dtDetallePeriodoLocal  
 --	where 
	--	   isnull(CantidadMonto,0)	<> 0	 
	--	or isnull(CantidadDias,0)	<> 0	 
	--	or isnull(CantidadVeces,0)	<> 0	 
	--	or isnull(CantidadOtro1,0)	<> 0	 
	--	or isnull(CantidadOtro2,0)	<> 0	 
	--	or isnull(ImporteGravado,0) <> 0		 
	--	or isnull(ImporteExcento,0) <> 0		 
	--	or isnull(ImporteOtro,0)	<> 0	 
	--	or isnull(ImporteTotal1,0)	<> 0	 
	--	or isnull(ImporteTotal2,0)	<> 0 
END;
GO

USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: IMSS PAGAR
** Autor			: Aneudy Abreu					| Jose Román,
** Email			: aneudy.abreu@adagio.com.mx	| jose.roman@adagio.com.mx
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
CREATE PROC [Nomina].[spConcepto_801]
( @dtconfigs [Nomina].[dtConfiguracionNomina] READONLY 
 ,@dtempleados [RH].[dtEmpleados] READONLY 
 ,@dtConceptos [Nomina].[dtConceptos] READONLY 
 ,@dtPeriodo [Nomina].[dtPeriodos] READONLY 
 ,@dtDetallePeriodo [Nomina].[dtDetallePeriodo] READONLY) 
AS 
BEGIN 

	DECLARE 
		@ClaveEmpleado varchar(20) 
		,@IDEmpleado int 
		,@i int = 0 
		,@Codigo varchar(20) = '801' 
		,@IDConcepto int 
		,@dtDetallePeriodoLocal [Nomina].[dtDetallePeriodo] 
		,@dtDetallePeriodoLocalParaImss [Nomina].[dtDetallePeriodo]
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
		
		,@UMA decimal(18,4)            
		,@Tope25UMA decimal(18,4)            
		,@Tope3UMA decimal(18,4)   
		,@SalarioMinimo decimal(18,4)
		,@IDConceptoDiasVigencia int  
		,@IDConceptoIncapacidades int 
		,@IDConceptoSeptimoDia int  
		,@IDConceptoAusentismos int            
		,@IDConceptoDiasCotizados int          
		,@IDConceptoFaltas int  
		,@json nvarchar(max)
		,@IDDatoExtraConceptosGravar int
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select @IDConceptoDiasVigencia=IDConcepto from @dtConceptos where Codigo= '001'             
	select @IDConceptoIncapacidades=IDConcepto from @dtConceptos where Codigo= '003'             
	select @IDConceptoAusentismos=IDConcepto from @dtConceptos where Codigo= '004'             
	select @IDConceptoDiasCotizados=IDConcepto from @dtConceptos where Codigo= '006' 
	select @IDConceptoSeptimoDia=IDConcepto from @dtConceptos where Codigo= '007' 
 
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
 
 	select top 1 @isPreviewFiniquito = cast(isnull(valor,0) as bit) from @dtconfigs
	 where Configuracion = 'isPreviewFiniquito'

	select @PeriodicidadPago = PP.Descripcion from Nomina.tblCatTipoNomina TN
		Inner join [Sat].[tblCatPeriodicidadesPago] PP
			on TN.IDPEriodicidadPAgo = PP.IDPeriodicidadPago
	Where TN.IDTipoNomina = @IDTipoNomina
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
 
		/* Inicio de segmento para programar el cuerpo del concepto*/
	  IF object_ID('TEMPDB..#TempDetalle') IS NOT NULL
   DROP TABLE #TempDetalle
   CREATE TABLE #TempDetalle(
    IDEmpleado int,
    IDPeriodo int,
    IDConcepto int,
    CantidadDias Decimal(18,2) null,
    CantidadMonto Decimal(18,2) null,
    CantidadVeces Decimal(18,2) null,
    CantidadOtro1 Decimal(18,2) null,
    CantidadOtro2 Decimal(18,2) null,
    ImporteGravado Decimal(18,2) null,
    ImporteExcento Decimal(18,2) null,
    ImporteTotal1 Decimal(18,2) null,
    ImporteTotal2 Decimal(18,2) null,
    Descripcion varchar(255) null,
    IDReferencia int null
   );

   --DUSGEM***********************************************

   --{"esmx":{"Nombre":"CONCEPTOS_GRAVAR"},"enus":{"Nombre":"CONCEPTOS_GRAVAR"}}
   select @IDDatoExtraConceptosGravar = IDDatoExtra from App.tblCatDatosExtras with (nolock) where IDTipoDatoExtra = 'centrosCostos' and IDInputType = 'Texto' and JSON_VALUE(Traduccion,'$.esmx.Nombre') = 'CONCEPTOS_GRAVAR'

	insert into @dtDetallePeriodoLocalParaImss 
	select dp.* from @dtDetallePeriodo dp
		inner join @dtConceptos c
			on c.IDConcepto = dp.IDConcepto
		left join @dtempleados Empleados
			on Empleados.IDEmpleado = dp.IDEmpleado
		left join App.tblValoresDatosExtras ConceptosGravar with (nolock) 
				on ConceptosGravar.IDReferencia = Empleados.IDCentroCosto
				and ConceptosGravar.IDDatoExtra = @IDDatoExtraConceptosGravar
		where ImporteGravado <> 0 
			and c.Codigo in (select cast (item as varchar(20)) from App.split(ConceptosGravar.Valor,',') )
			
	IF object_ID('TEMPDB..#TempNuevoIntegrado') IS NOT NULL
	DROP TABLE #TempNuevoIntegrado
    CREATE TABLE #TempNuevoIntegrado(
		IDEmpleado int,
		Sumatoria int
	)

	insert into #TempNuevoIntegrado
		select IDEmpleado, sum (ImporteGravado) from @dtDetallePeriodoLocalParaImss
			group by IDEmpleado

	IF object_ID('TEMPDB..#Prestaciones') IS NOT NULL DROP TABLE #Prestaciones;
		IF object_ID('TEMPDB..#PrestacionEmpleado') IS NOT NULL DROP TABLE #PrestacionEmpleado;

		select top 1
			@json = [Data]
			from App.tblCatDatosExtras 
			where JSON_VALUE ( Traduccion,'$.esmx.Nombre') = 'prestaciones pagar'
				and IDTipoDatoExtra = 'centrosCostos'

		select *
			into #Prestaciones
			from OPENJSON(@json) with (
				ID varchar (max) '$.ID',
				Prestaciones int '$.Nombre'
			);

		select 
			em.IDEmpleado
			--,em.IDCentroCosto
			--,vde.Valor
			,p.Prestaciones Prestacion
			into #PrestacionEmpleado
			from @dtempleados em
				inner join [App].[tblValoresDatosExtras] vde
					on vde.IDReferencia = em.IDCentroCosto
				inner join #Prestaciones p
					on p.ID = vde.Valor

	--DUSGEM***********************************************


	--------------------------------------------------------------

	select e.*, Antiguedad = case when DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago) = 0 then 1             
			else DATEDIFF(YEAR,e.FechaAntiguedad,@FechaFinPago)             
			end            
			, e.SalarioDiario * 30.4  as SalarioMensual            
			, DiasCotizados = isnull(DC.ImporteTotal1,0)             
			, DiasVigencia = isnull(dp.ImporteTotal1,0)            
			, DiasFaltas =  case 
								when  ISNULL(AcumAusentismos.ImporteTotal1,0) >= 7 then 0     
								when  ISNULL(Ausentismos.ImporteTotal1,0) <= (7 - ISNULL(AcumAusentismos.ImporteTotal1,0)) then ISNULL(Ausentismos.ImporteTotal1,0)
								when ISNULL(Ausentismos.ImporteTotal1,0) >= (7 - ISNULL(AcumAusentismos.ImporteTotal1,0)) then ISNULL(Ausentismos.ImporteTotal1,0) - (7 - ISNULL(AcumAusentismos.ImporteTotal1,0))

									--CASE WHEN (ISNULL(AcumAusentismos.ImporteTotal1,0) + ISNULL(Ausentismos.ImporteTotal1,0)) >= 7 THEN  7   
									--	ELSE (ISNULL(AcumAusentismos.ImporteTotal1,0) + ISNULL(Ausentismos.ImporteTotal1,0))    
									--END    
							else 0    
							end           
			, DiasIncapacidad = isnull(inca.ImporteTotal1,0)            
			,dp.CantidadMonto    
			,Ausentismos.ImporteTotal1  as Faltas   
			,AcumAusentismos.ImporteTotal1   as  AcumFaltas   
			, (Select top 1 Prima             
				from [RH].[tblHistorialPrimaRiesgo]             
				where IDRegPatronal= e.IDRegPatronal    
				and DATEFROMPARTS( Anio, mes, 1 )   <= DATEFROMPARTS ( @Ejercicio, @IDMes, 1 ) --- BUG CORREGIDO PARA TOMA DE PRIMA DE RIESGO
				--and Anio <= @Ejercicio														-- JOSE ROMAN 2023-01-23
				--and Mes <= @IDMes            
				order by Anio desc,Mes desc) as PrimaRiesgo            
			,PorcentajesPago.*   
			,Case when ISNULL(app.CantidadOtro2,0) = -1 THEN 0 Else 1 END Aplica  
			,ISNULL(TTE.IDTipoPension,1) as IDTipoPension -- SI NO TIENE PENSION EL TIPO 1 ES LA OPCION DE SIN PENSION
			
			--Que este valor de cuenta contable se traiga sobre el JSON
			,
			case when  ISNULL( PE.Prestacion , 0 ) > 0 THEN
				( ( ISNULL( PE.Prestacion, 18 )  / 365.00 ) *  ISNULL ( e.SalarioDiario , 0 ) ) + ISNULL ( e.SalarioDiario , 0 ) + ( CASE WHEN ( isnull(DC.ImporteTotal1,0) ) > 0 THEN  isnull(tni.Sumatoria,0) / ( isnull(DC.ImporteTotal1,0)) ELSE 0 END ) 
			--	( ( ISNULL( PE.Prestacion, 18 )  / 365.00 ) *  ISNULL ( e.SalarioDiario , 0 ) ) + ISNULL ( e.SalarioDiario , 0 ) + ( CASE WHEN ( isnull(DC.ImporteTotal1,0) + isnull(SDia.ImporteTotal1,0) ) > 0 THEN  isnull(tni.Sumatoria,0) / ( isnull(DC.ImporteTotal1,0) + isnull(SDia.ImporteTotal1,0)) ELSE 0 END ) 
			else
				isnull(e.SalarioIntegrado,0) + ( CASE WHEN isnull(DC.ImporteTotal1,0) > 0 THEN isnull(tni.Sumatoria,0) /  isnull(DC.ImporteTotal1,0) ELSE 0 END) 
			END as SalarioVariableDusgem
			----DUSGEM
			
			
			--isnull(e.SalarioIntegrado,0) + ( isnull(tni.Sumatoria,0) /  isnull(DC.ImporteTotal1,0) ) as SalarioVariableDusgem
		INTO #IntegradoTotal										-- JOSE ROMAN 2023-05-18
		from @dtempleados E    
			Left Join RH.tblTipoTrabajadorEmpleado TTE 
				on E.IDEmpleado = TTE.IDEmpleado
			left join @dtDetallePeriodo app 
				on e.IDEmpleado = app.IDEmpleado 
					and app.IDConcepto = @IDConcepto          
			left join @dtDetallePeriodo dp 
				on e.IDEmpleado = dp.IDEmpleado 
					and dp.IDConcepto = @IDConceptoDiasVigencia            
			left join @dtDetallePeriodo inca
				on e.IDEmpleado = inca.IDEmpleado 
					and inca.IDConcepto = @IDConceptoIncapacidades            
			left join @dtDetallePeriodo Ausentismos 
				on e.IDEmpleado = Ausentismos.IDEmpleado 
					and Ausentismos.IDConcepto = @IDConceptoAusentismos     
			left join #TempNuevoIntegrado tni 
				on e.IDEmpleado = tni.IDEmpleado
			--Dusgem
			left join #PrestacionEmpleado PE
					on PE.IDEmpleado = e.IDEmpleado
			--Dusgem
			--left join @dtDetallePeriodo Faltas on e.IDEmpleado = Faltas.IDEmpleado and Faltas.IDConcepto = @IDConceptoFaltas            
			left join @dtDetallePeriodo DC on e.IDEmpleado = DC.IDEmpleado and DC.IDConcepto = @IDConceptoDiasCotizados    
			left join @dtDetallePeriodo SDia on e.IDEmpleado = SDia.IDEmpleado and SDia.IDConcepto = @IDConceptoSeptimoDia  
			Cross Apply [Nomina].[fnObtenerAcumuladoPorConceptoPorMes](e.IDEmpleado,@IDConceptoAusentismos,@IDMes,@Ejercicio) AcumAusentismos           
			--Cross Apply [Nomina].[fnObtenerAcumuladoPorConceptoPorMes](e.IDEmpleado,@IDConceptoFaltas,@IDMes,@Ejercicio) AcumFaltas          
			,(select top 1 *            
				from [IMSS].[tblCatPorcentajesPago]            
				where Fecha <= @FechaFinPago            
				order by Fecha desc) as PorcentajesPago  


---------------------------------------------- | PRESTACIONES | ----------------------------------------------

	IF object_ID('TEMPDB..#PrestacionesSuperiores') IS NOT NULL DROP TABLE #PrestacionesSuperiores;
	IF object_ID('TEMPDB..#PagoFiscal') IS NOT NULL DROP TABLE #PagoFiscal;
	IF object_ID('TEMPDB..#PrestacionesFiscalSuperiores') IS NOT NULL DROP TABLE #PrestacionesFiscalSuperiores;

	Declare
		@jsonPrestacionesSuperiores nvarchar(max)
		,@jsonFiscal nvarchar(max)
		,@IDDatoExtraDespensa_Ex int
		,@IDDatoExtraDespensa_Grav int
	;


		select top 1
			@jsonPrestacionesSuperiores = [Data]
			from App.tblCatDatosExtras 
			where JSON_VALUE ( Traduccion,'$.esmx.Nombre') = 'prestaciones_superiores'     
				and IDTipoDatoExtra = 'centrosCostos'
			
			select *
			into #PrestacionesSuperiores
			from OPENJSON(@jsonPrestacionesSuperiores) with (
				ID varchar (max) '$.ID',
				PrestacionesSuperiores varchar(10) '$.Nombre'
			);

		select top 1
			@jsonFiscal = [Data]
			from App.tblCatDatosExtras 
			where JSON_VALUE ( Traduccion,'$.esmx.Nombre') = 'FISCAL 100%'   
				and IDTipoDatoExtra = 'centrosCostos'
			
			select *
			into #PagoFiscal
			from OPENJSON(@jsonFiscal) with (
				ID varchar (max) '$.ID',
				PagoFiscal varchar(10) '$.Nombre'
			);

	--select * from #PagoFiscal
	--select * from #PrestacionesSuperiores

	select 
		e.IDEmpleado
		,PF.PagoFiscal
		,PS.PrestacionesSuperiores
		into #PrestacionesFiscalSuperiores
		from @dtempleados e
			inner join App.tblValoresDatosExtras vdeSuperiores
				on vdeSuperiores.IDReferencia = e.IDCentroCosto
			inner join #PrestacionesSuperiores PS
				on PS.ID = vdeSuperiores.Valor
			inner join App.tblValoresDatosExtras vdeFiscal
				on vdeFiscal.IDReferencia = e.IDCentroCosto
			inner join #PagoFiscal PF
				on PF.ID = vdeFiscal.Valor

	Declare
		@IDTipoNominaQuincenal int
	;

	select @IDTipoNominaQuincenal = IDTipoNomina from Nomina.tblCatTipoNomina where Descripcion = 'PROYECTOS QUINCENAL'
	
	select top 1             
			@UMA  = UMA            
			,@Tope25UMA = UMA * 25            
			,@Tope3UMA  = UMA *3   
			,@SalarioMinimo = SalarioMinimo         
			from Nomina.TblSalariosMinimos            
			where Fecha <= @FechaFinPago            
			order by Fecha desc 

	IF( ( @General = 1 ) and (@IDTipoNomina <> @IDTipoNominaQuincenal ) )
	BEGIN
		

		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN ISNULL(DTLocal.CantidadOtro2 , 0) = -1 THEN 0
						WHEN ( ( @Concepto_bCantidadMonto  = 1 ) and ( ISNULL(DTLocal.CantidadMonto,0) > 0 ) ) OR
							 ( ( @Concepto_bCantidadDias   = 1 ) and ( ISNULL(DTLocal.CantidadDias,0)  > 0 ) )
							
							THEN ( ISNULL(DTLocal.CantidadDias,0) * ISNULL ( Empleados.SalarioDiario , 0 ) ) + ISNULL(DTLocal.CantidadMonto,0)		
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	 
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	 
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	 
				ELSE 
					CASE WHEN (Prestaciones.PagoFiscal = 'NO' AND Prestaciones.PrestacionesSuperiores = 'SI') THEN 
					
											--CASE WHEN IMSS.SalarioDiario + IMSS.SalarioVariable > @SalarioMinimo THEN 
												(imss.SalarioVariableDusgem * imss.PrestacionesDineroObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))           
											--END 
											+
											--CASE WHEN IMSS.SalarioDiario + IMSS.SalarioVariable > @SalarioMinimo THEN          
												(imss.SalarioVariableDusgem * imss.GMPensionadosObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))   
											--END
											+
											--CASE WHEN IMSS.SalarioDiario +  IMSS.SalarioVariable > @SalarioMinimo THEN            
												(imss.SalarioVariableDusgem * imss.InvalidezVidaObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) +isnull(imss.DiasIncapacidad,0)))
											--END
											+
											--CASE WHEN Imss.SalarioDiario + IMSS.SalarioVariable <= @SalarioMinimo THEN 0 else            
												(imss.SalarioVariableDusgem * imss.CesantiaVejezObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) +isnull(imss.DiasIncapacidad,0))) 
											--END
											+
											case when imss.SalarioVariableDusgem > @Tope3UMA then 
												((imss.SalarioVariableDusgem-@Tope3UMA) * imss.ExcedenteObrera) * (imss.DiasCotizados- isnull(imss.DiasIncapacidad,0)) 
											else 0 
											end 
						ELSE 0
					END
				END Valor
			,CASE WHEN (Prestaciones.PagoFiscal = 'NO' AND Prestaciones.PrestacionesSuperiores = 'SI') THEN  isnull(imss.SalarioVariableDusgem,0) ELSE 0 END as SalarioVariableDusgem
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							 
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							 
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							 
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #IntegradoTotal imss
				on Empleados.IDEmpleado = imss.IDEmpleado
			left join #PrestacionesFiscalSuperiores Prestaciones
				on Prestaciones.IDEmpleado = Empleados.IDEmpleado

		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		--IF(ISNULL(@Concepto_LFT,0) = 1)
		BEGIN
			insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
			Select IDEmpleado,
				IDPeriodo,
				IDConcepto,
				CantidadDias ,
				CantidadMonto,
				CantidadVeces,
				CantidadOtro1,
				CantidadOtro2 = SalarioVariableDusgem,
				ImporteGravado = 0.00,
				ImporteExcento = 0.00,
				ImporteTotal1 = Valor,
				ImporteTotal2 = 0.00,
				Descripcion = '',
				IDReferencia = NULL
			FROM #TempValores
		END
		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
	END ELSE
	IF (@Finiquito = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA FINIQUITOS AQUÍ */
		
			IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN ISNULL(DTLocal.CantidadOtro2 , 0) = -1 THEN 0
						WHEN ( ( @Concepto_bCantidadMonto  = 1 ) and ( ISNULL(DTLocal.CantidadMonto,0) > 0 ) ) OR
							 ( ( @Concepto_bCantidadDias   = 1 ) and ( ISNULL(DTLocal.CantidadDias,0)  > 0 ) )
							
							THEN ( ISNULL(DTLocal.CantidadDias,0) * ISNULL ( Empleados.SalarioDiario , 0 ) ) + ISNULL(DTLocal.CantidadMonto,0)		
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	 
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	 
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	 
				ELSE 
					--CASE WHEN (Prestaciones.PagoFiscal = 'NO' AND Prestaciones.PrestacionesSuperiores = 'SI') THEN 
					
											--CASE WHEN IMSS.SalarioDiario + IMSS.SalarioVariable > @SalarioMinimo THEN 
												(imss.SalarioVariableDusgem * imss.PrestacionesDineroObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))           
											--END 
											+
											--CASE WHEN IMSS.SalarioDiario + IMSS.SalarioVariable > @SalarioMinimo THEN          
												(imss.SalarioVariableDusgem * imss.GMPensionadosObrera) * (imss.DiasCotizados - isnull(imss.DiasIncapacidad,0))   
											--END
											+
											--CASE WHEN IMSS.SalarioDiario +  IMSS.SalarioVariable > @SalarioMinimo THEN            
												(imss.SalarioVariableDusgem * imss.InvalidezVidaObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) +isnull(imss.DiasIncapacidad,0)))
											--END
											+
											--CASE WHEN Imss.SalarioDiario + IMSS.SalarioVariable <= @SalarioMinimo THEN 0 else            
												(imss.SalarioVariableDusgem * imss.CesantiaVejezObrera) * (imss.DiasCotizados- (isnull(case when imss.DiasFaltas > 7 then 7 else imss.DiasFaltas end,0) +isnull(imss.DiasIncapacidad,0))) 
											--END
											+
											case when imss.SalarioVariableDusgem > @Tope3UMA then 
												((imss.SalarioVariableDusgem-@Tope3UMA) * imss.ExcedenteObrera) * (imss.DiasCotizados- isnull(imss.DiasIncapacidad,0)) 
											else 0 
											end 
						--ELSE 0
					--END
				END Valor
			,CASE WHEN (Prestaciones.PagoFiscal = 'NO' AND Prestaciones.PrestacionesSuperiores = 'SI') THEN  isnull(imss.SalarioVariableDusgem,0) ELSE 0 END as SalarioVariableDusgem
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							 
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							 
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							 
		INTO #TempValoresFiniquitos
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #IntegradoTotal imss
				on Empleados.IDEmpleado = imss.IDEmpleado
			left join #PrestacionesFiscalSuperiores Prestaciones
				on Prestaciones.IDEmpleado = Empleados.IDEmpleado

		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		--IF(ISNULL(@Concepto_LFT,0) = 1)
		BEGIN
			insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)
			Select IDEmpleado,
				IDPeriodo,
				IDConcepto,
				CantidadDias ,
				CantidadMonto,
				CantidadVeces,
				CantidadOtro1,
				CantidadOtro2 = SalarioVariableDusgem,
				ImporteGravado = 0.00,
				ImporteExcento = 0.00,
				ImporteTotal1 = Valor,
				ImporteTotal2 = 0.00,
				Descripcion = '',
				IDReferencia = NULL
			FROM #TempValoresFiniquitos
		END
	END ELSE
	IF (@Especial = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA ESPECIALES AQUÍ */
		/*
		MERGE @dtDetallePeriodoLocal AS TARGET
		USING #TempValoresEspeciales AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDConcepto = @Concepto_IDConcepto
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.ImporteTotal1  = SOURCE.Valor
		WHEN NOT MATCHED BY TARGET THEN
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor)
		WHEN NOT MATCHED BY SOURCE THEN
			DELETE;
		*/
		PRINT 0
	END;
		MERGE @dtDetallePeriodoLocal AS TARGET
		USING #TempDetalle AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				and TARGET.IDConcepto = @Concepto_IDConcepto
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.CantidadMonto ,0)
			 ,TARGET.CantidadDias   = isnull(SOURCE.CantidadDias  ,0)
			 ,TARGET.CantidadVeces  = isnull(SOURCE.CantidadVeces ,0)
			 ,TARGET.CantidadOtro1  = isnull(SOURCE.CantidadOtro1 ,0)
			 ,TARGET.CantidadOtro2  = isnull(SOURCE.CantidadOtro2 ,0)
			 ,TARGET.ImporteTotal1  = ISNULL(SOURCE.ImporteTotal1 ,0)
			 ,TARGET.ImporteTotal2  = ISNULL(SOURCE.ImporteTotal2 ,0)
			 ,TARGET.ImporteGravado = ISNULL(SOURCE.ImporteGravado,0)
			 ,TARGET.ImporteExcento = ISNULL(SOURCE.ImporteExcento,0)
			 ,TARGET.Descripcion	= SOURCE.Descripcion
			 ,TARGET.IDReferencia	= NULL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT(IDEmpleado,IDPeriodo,IDConcepto,
			CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2,
			ImporteTotal1,ImporteTotal2, ImporteGravado,ImporteExcento,Descripcion,IDReferencia
			 
			)
			VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,
			isnull(SOURCE.CantidadMonto ,0),isnull(SOURCE.CantidadDias  ,0),isnull(SOURCE.CantidadVeces ,0)
			,isnull(SOURCE.CantidadOtro1 ,0),isnull(SOURCE.CantidadOtro2 ,0),
			ISNULL(SOURCE.ImporteTotal1 ,0),ISNULL(SOURCE.ImporteTotal2 ,0),ISNULL(SOURCE.ImporteGravado,0)
			,ISNULL(SOURCE.ImporteExcento,0),SOURCE.Descripcion, NULL
			)
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;
	Select * from @dtDetallePeriodoLocal
 		where
		   isnull(CantidadMonto,0)	<> 0	
		or isnull(CantidadDias,0)	<> 0	
		or isnull(CantidadVeces,0)	<> 0	
		or isnull(CantidadOtro1,0)	<> 0	
		or isnull(CantidadOtro2,0)	<> 0	
		or isnull(ImporteGravado,0) <> 0		
		or isnull(ImporteExcento,0) <> 0		
		or isnull(ImporteOtro,0)	<> 0	
		or isnull(ImporteTotal1,0)	<> 0	
		or isnull(ImporteTotal2,0)	<> 0
END;
GO

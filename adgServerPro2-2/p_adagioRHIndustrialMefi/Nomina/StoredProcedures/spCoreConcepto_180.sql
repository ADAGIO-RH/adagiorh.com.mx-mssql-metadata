USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: SUBSIDIO PARA EL EMPLEO
** Autor			: Aneudy Abreu | Jose Romá,
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
CREATE PROC [Nomina].[spCoreConcepto_180]
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
		,@Codigo varchar(20) = '180' 
		,@IDConcepto int 
		,@dtDetallePeriodoLocal [Nomina].[dtDetallePeriodo] 
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
		,@Concepto_078 varchar(20) = '078' --SUBISIDIO CAUSADO
		,@Concepto_079 varchar(20) = '079' --ISR CAUSADO
		,@Concepto_184 varchar(20) = '184' --ISR CAUSADO
		,@IDConcepto_078 int
		,@IDConcepto_079 int
		,@IDConcepto_184 int
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConcepto_078=IDConcepto from @dtConceptos where Codigo=@Concepto_078; 
	select top 1 @IDConcepto_079=IDConcepto from @dtConceptos where Codigo=@Concepto_079; 
	select top 1 @IDConcepto_184=IDConcepto from @dtConceptos where Codigo=@Concepto_184; 
 
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

	IF object_ID('TEMPDB..#TempValores') IS NOT NULL
		DROP TABLE #TempValores
 
 	if object_id('tempdb..#TempIndemnizacion') is not null      
		drop table #TempIndemnizacion; 

		select 
			dp.IDEmpleado as IDEmpleado
			,@IDConcepto as IDConcepto
			,@IDPeriodo as IDPeriodo
			,isnull(SUM(dp.ImporteTotal1),0) as ImporteTotal1  
		into #TempIndemnizacion      
		from @dtempleados e
			left join @dtDetallePeriodo dp      
			on e.IDEmpleado = dp.IDEmpleado
			inner join @dtConceptos c      
				on dp.IDConcepto = c.IDConcepto      
			inner join Nomina.tblCatTipoCalculoISR ti      
				on ti.IDCalculo = c.IDCalculo      
		where ti.Codigo = 'ISR_INDEMNIZACIONES'      
			and C.IDTipoConcepto = 1 -- PERCEPCIONES     
		Group by dp.IDEmpleado 
 
	SELECT
		Empleados.IDEmpleado,
		@IDPeriodo as IDPeriodo,
		@Concepto_IDConcepto as IDConcepto,
		CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
				 WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
				 WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
				 WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
				 WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
		  ELSE 0
				--CASE WHEN isnull(dpSubsidio.ImporteTotal1,0) = 0 OR isnull(indemnizacion.ImporteTotal1,0) > 0 THEN 0
				--ELSE
				--case when isnull(dpSubsidio.ImporteTotal1,0) > isnull(dpISR.ImporteTotal1,0) then isnull(dpSubsidio.ImporteTotal1,0) - isnull(dpISR.ImporteTotal1,0)
				--     else 0.00
				--	 end  -- Función personalizada																			  
				--END
		  END Valor	,
		  isnull(dpSubsidio.ImporteTotal1,0) sub,
		  isnull(dpISR.ImporteTotal1,0) isr
		INTO #TempValores
		FROM @dtempleados Empleados
			left join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join @dtDetallePeriodo dpSubsidio
				on Empleados.IDEmpleado = dpSubsidio.IDEmpleado and dpSubsidio.IDConcepto = @IDConcepto_078
			left join @dtDetallePeriodo dpISR
				on Empleados.IDEmpleado = dpISR.IDEmpleado and dpISR.IDConcepto = @IDConcepto_079
			left join @dtDetallePeriodo c_184
				on Empleados.IDEmpleado = c_184.IDEmpleado and c_184.IDConcepto = @IDConcepto_184
			left join #TempIndemnizacion indemnizacion
				on indemnizacion.IDEmpleado = Empleados.IDEmpleado
		where isnull(c_184.ImporteTotal1, 0) = 0
 
			
			DELETE #TempValores
			where IDEmpleado in (
				select IDEmpleado from #TempIndemnizacion
				where isnull(ImporteTotal1,0) > 0
			)


		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
 
 --select * from #TempValores
 
		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
 
	  /* Fin de segmento para programar el cuerpo del concepto*/
 
 
		MERGE @dtDetallePeriodoLocal AS TARGET
			USING #TempValores AS SOURCE
				ON TARGET.IDPeriodo = SOURCE.IDPeriodo
					and TARGET.IDConcepto = @Concepto_IDConcepto
					and TARGET.IDEmpleado = SOURCE.IDEmpleado
			WHEN MATCHED Then
				update
					Set TARGET.ImporteTotal1  = SOURCE.Valor
					, TARGET.ImporteGravado  = 0.00
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado, IDPeriodo, IDConcepto, ImporteGravado, ImporteTotal1)
				VALUES(SOURCE.IDEmpleado, SOURCE.IDPeriodo, @Concepto_IDConcepto, 0.00, Source.Valor)
			WHEN NOT MATCHED BY SOURCE THEN 
				DELETE;
 

	--HUGO ARTURO GUAJARDO PEREZ 09/OCTUBRE/2020
	--Este cambio se debe aplicar en todas las bases ya que corrige el error de timbrado por falta de tener el concepto 180 en CEROS

	Select * from @dtDetallePeriodoLocal  
	where IDEmpleado in(select  IDEmpleado from RH.tblEmpleadosMaster where IDTipoRegimen not in (select  IDTipoRegimen from Sat.tblCatTiposRegimen where Descripcion like '%Asimilados%'))
 	----------------------------------------------------------------------------------------------------------------------------------------------

	--where 
		--(isnull(CantidadMonto,0)+		 
		--isnull(CantidadDias,0)+		 
		--isnull(CantidadVeces,0)+		 
		--isnull(CantidadOtro1,0)+		 
		--isnull(CantidadOtro2,0)+		 
		--isnull(ImporteGravado,0)+		 
		--isnull(ImporteExcento,0)+		 
		--isnull(ImporteOtro,0)+		 
		--isnull(ImporteTotal1,0)+		 
		--isnull(ImporteTotal2,0) ) > 0	 
END;
GO

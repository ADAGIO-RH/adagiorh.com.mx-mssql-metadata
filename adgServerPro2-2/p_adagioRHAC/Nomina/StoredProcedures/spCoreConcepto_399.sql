USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: AJUSTE DEL NETO
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
CREATE PROC [Nomina].[spCoreConcepto_399]
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
		,@Codigo varchar(20) = '399' 
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
		,@Ajusta int
		,@ConceptosExcluidos varchar(1000) = '500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,519,520,521'; 
		
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @Ajusta = cast(Valor as int) from Nomina.tblConfiguracionNomina where Configuracion = 'Ajusta'

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

 
	 if OBJECT_ID('tempdb..#tempPercepciones') is not null  
    drop table #tempPercepciones;  
  
  select e.IDEmpleado  
     ,dp.IDPeriodo  
     ,sum(dp.ImporteGravado) as ImporteGravado  
     ,sum(dp.ImporteExcento) as ImporteExcento  
     ,sum(dp.ImporteOtro) as ImporteOtro  
     ,sum(dp.ImporteTotal1) as ImporteTotal1  
     ,sum(dp.ImporteTotal2) as ImporteTotal2  
   into #tempPercepciones    
  from   
    @dtempleados E  
    inner join   
   @dtDetallePeriodo DP  
    on E.IDEmpleado = dp.IDEmpleado  
    and DP.IDPeriodo = @IDPeriodo  
   inner join @dtConceptos c  
    on DP.IDConcepto = C.IDConcepto  
   Inner join Nomina.tblCatTipoConcepto TipoConcepto  
    on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto  
     and TipoConcepto.Descripcion in( 'PERCEPCION','OTROS TIPOS DE PAGOS')  
	 and c.Estatus = 1
	  and c.Codigo <> '199'
  GROUP BY e.IDEmpleado,dp.IDPeriodo 


    if OBJECT_ID('tempdb..#tempDeducciones') is not null  
    drop table #tempDeducciones;  
  
  select e.IDEmpleado  
     ,dp.IDPeriodo  
       
     ,sum(dp.ImporteGravado) as ImporteGravado  
     ,sum(dp.ImporteExcento) as ImporteExcento  
     ,sum(dp.ImporteOtro) as ImporteOtro  
     ,sum(dp.ImporteTotal1) as ImporteTotal1  
     ,sum(dp.ImporteTotal2) as ImporteTotal2  
   into #tempDeducciones    
  from   
    @dtempleados E  
    inner join   
   @dtDetallePeriodo DP  
    on E.IDEmpleado = dp.IDEmpleado  
    and DP.IDPeriodo = @IDPeriodo  
   inner join Nomina.tblCatConceptos c  
    on DP.IDConcepto = C.IDConcepto  
   Inner join Nomina.tblCatTipoConcepto TipoConcepto  
    on c.IDTipoConcepto = TipoConcepto.IDTipoConcepto  
     and TipoConcepto.Descripcion in( 'DEDUCCION')  
     and c.Codigo  not in (select Item from App.split(@ConceptosExcluidos,','))  
	 and c.Estatus = 1
	  and c.Codigo <> '399'
  GROUP BY e.IDEmpleado,dp.IDPeriodo  


 
	IF object_ID('TEMPDB..#TempValores') IS NOT NULL
		DROP TABLE #TempValores
 
 
	SELECT
		Empleados.IDEmpleado,
		@IDPeriodo as IDPeriodo,
		@Concepto_IDConcepto as IDConcepto,
		CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0
			 ELSE 
				case when Nomina.fnAjustaNeto(ISNULL(percepciones.ImporteTotal1,0),ISNULL(deducciones.ImporteTotal1,0),ISNULL(@Ajusta,0)) >= 0 THEN Nomina.fnAjustaNeto(ISNULL(percepciones.ImporteTotal1,0),ISNULL(deducciones.ImporteTotal1,0),ISNULL(@Ajusta,0)) -- Función personalizada																			  
					ELSE 0
					end
		  END Valor																							  
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #tempPercepciones percepciones
				on Empleados.IDEmpleado = percepciones.IDEmpleado
			left join #tempDeducciones deducciones
				on Empleados.IDEmpleado = deducciones.IDEmpleado
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
 
 
 
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
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteTotal1)
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@Concepto_IDConcepto,Source.Valor)
			WHEN NOT MATCHED BY SOURCE THEN 
				DELETE;
 
 

	Select * from @dtDetallePeriodoLocal  
 	where 
		(isnull(CantidadMonto,0)<> 0 OR		 
		isnull(CantidadDias,0)<> 0 OR			 
		isnull(CantidadVeces,0)<> 0 OR			 
		isnull(CantidadOtro1,0)<> 0 OR			 
		isnull(CantidadOtro2,0)<> 0 OR			 
		isnull(ImporteGravado,0)<> 0 OR			 
		isnull(ImporteExcento,0)<> 0 OR			 
		isnull(ImporteOtro,0)<> 0 OR			 
		isnull(ImporteTotal1,0)<> 0 OR			 
		isnull(ImporteTotal2,0)<> 0  ) 
END;
GO

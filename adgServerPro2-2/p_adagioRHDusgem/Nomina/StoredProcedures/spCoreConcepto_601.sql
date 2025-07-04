USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: TRANSFERENCIA ELECTRONICA
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
CREATE PROC [Nomina].[spCoreConcepto_601]
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
		,@Codigo varchar(20) = '601' 
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
		,@IDConceptoTotalPercepciones int  
		,@IDConceptoTotalDeducciones int  
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConceptoTotalPercepciones=IDConcepto from @dtConceptos where Codigo='550'; --Total de Percepciones  
     select top 1 @IDConceptoTotalDeducciones=IDConcepto from @dtConceptos where Codigo='560'; --Total de Deducciones  
   
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


	DECLARE  
   @IDConceptoTransferencia int  
  ,@IDConceptoCheque int  
  ,@IDConceptoEfectivo int  
  ,@IDConceptoFiniquitoTransferencia int  
  ,@IDConceptoFiniquitoCheque int  
  ,@IDConceptoFiniquitoEfectivo int  
  select top 1 @IDConceptoTransferencia  = IDConcepto from @dtConceptos where Codigo='601';   
  select top 1 @IDConceptoCheque = IDConcepto from @dtConceptos where Codigo='602';   
  select top 1 @IDConceptoEfectivo = IDConcepto from @dtConceptos where Codigo='603';   
  select top 1 @IDConceptoFiniquitoTransferencia = IDConcepto from @dtConceptos where Codigo='604';   
  select top 1 @IDConceptoFiniquitoCheque = IDConcepto from @dtConceptos where Codigo='605';   
  select top 1 @IDConceptoFiniquitoEfectivo = IDConcepto from @dtConceptos where Codigo='606';   
   

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

	

 if OBJECT_ID('tempdb..#tempPagoEmpleado') is not null  
    drop table #tempPagoEmpleado;  
 IF(ISNULL(@Finiquito,0)= 0)  
 BEGIN

	 select e.IDEmpleado  
      ,@IDPeriodo as IDPeriodo  
      ,isnull(DPPercepcion.ImporteGravado,0.00) - isnull(DPDeduccion.ImporteGravado,0.00) as ImporteGravado  
      ,isnull(DPPercepcion.ImporteExcento,0.00) - isnull(DPDeduccion.ImporteExcento,0.00) as ImporteExcento  
      ,isnull(DPPercepcion.ImporteOtro,0.00) - isnull(DPDeduccion.ImporteOtro,0.00) as ImporteOtro  
      ,isnull(DPPercepcion.ImporteTotal1,0.00) - isnull(DPDeduccion.ImporteTotal1,0.00) as ImporteTotal1  
      ,isnull(DPPercepcion.ImporteTotal2,0.00) - isnull(DPDeduccion.ImporteTotal2,0.00) as ImporteTotal2  
   into #tempPagoEmpleado  
   from @dtempleados e  
    INNER join RH.tblPagoEmpleado PE   
     on e.IDEmpleado = PE.IDEmpleado  
     and pe.IDConcepto = @IDConceptoTransferencia  
    Left JOIN @dtDetallePeriodo DPPercepcion  
     on e.IDEmpleado = DPPercepcion.IDEmpleado  
      and DPPercepcion.IDConcepto = @IDConceptoTotalPercepciones  
    Left JOIN @dtDetallePeriodo DPDeduccion  
     on e.IDEmpleado = DPDeduccion.IDEmpleado  
      and DPDeduccion.IDConcepto = @IDConceptoTotalDeducciones  
   where e.IDEmpleado not in (Select IDEmpleado from Nomina.tblControlFiniquitos f inner join Nomina.tblCatEstatusFiniquito ef on ef.IDEStatusFiniquito = f.IDEStatusFiniquito where f.IDPeriodo = @IDPeriodo and ef.Descripcion = 'Aplicar')  
  

    
   MERGE @dtDetallePeriodoLocal AS TARGET  
      USING #tempPagoEmpleado AS SOURCE  
      ON TARGET.IDPeriodo = SOURCE.IDPeriodo  
        and TARGET.IDConcepto = @IDConcepto  
        and TARGET.IDEmpleado = SOURCE.IDEmpleado  
      WHEN MATCHED Then  
      update  
      Set       
      TARGET.ImporteGravado  = SOURCE.ImporteGravado  
      ,TARGET.ImporteExcento  = SOURCE.ImporteExcento  
      ,TARGET.ImporteOtro  = SOURCE.ImporteOtro  
      ,TARGET.ImporteTotal1  = SOURCE.ImporteTotal1  
      ,TARGET.ImporteTotal2  = SOURCE.ImporteTotal2  
      WHEN NOT MATCHED BY TARGET THEN   
      INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteGravado,ImporteExcento,ImporteOtro,ImporteTotal1,ImporteTotal2)  
      VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@IDConcepto,Source.ImporteGravado,Source.ImporteExcento,Source.ImporteOtro,Source.ImporteTotal1,Source.ImporteTotal2)  
     WHEN NOT MATCHED BY SOURCE THEN   
     DELETE;   
END

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
		isnull(ImporteTotal2,0) <> 0)	 
END;
GO

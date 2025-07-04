USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: FESTIVO LABORADO
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
CREATE PROC [Nomina].[spConcepto_117]
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
		,@Codigo varchar(20) = '117' 
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
		,@UMA decimal(18,2)  
		,@SalarioMinimo Decimal(18,2)  
		,@UMASExentas int = 5  
		,@PorcentajeExcento Decimal(18,2) = 0.5 -- Variable para saber la constante del porcentaje exento de descanso Obligatorio  
		,@PorcentajeDescansoObligatorio Decimal(18,2)  = 2 -- cantidad en veces por la que se multiplica el sueldo diario para descanso Obligatorio  
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
 
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

	    
  select top 1 @UMA = UMA , @SalarioMinimo = SalarioMinimo -- Aqui se obtiene el valor de la UMA del catalogo de Salarios minimos  
   from Nomina.tblSalariosMinimos  
   where Year(Fecha) = @Ejercicio  
   ORder by Fecha Desc   
    
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

	    BEGIN /* Determina la fechas de inicio y fin para buscar las incidencias tomando en cuenta los movimientos afiliatorios del colaborador en el periodo */  
			  IF object_ID('tempdb..#TempMovimientos') IS NOT NULL DROP TABLE #TempMovimientos;    
        
			  select m.*,TipoMovimiento.Codigo, ROW_NUMBER()over(partition by m.IDEmpleado order by  m.Fecha desc) as [Row]    
			  into #TempMovimientos    
			  from @dtempleados e    
			   join IMSS.tblMovAfiliatorios m on e.IDEmpleado = m.IDEmpleado    
			   left join IMSS.tblCatTipoMovimientos TipoMovimiento on m.IDTipoMovimiento = TipoMovimiento.IDTipoMovimiento    
				and TipoMovimiento.Codigo <>'M' and m.Fecha <= @FechaFinIncidencia    
  
			  delete from #TempMovimientos where [Row] <> 1  
  
			  IF object_ID('tempdb..#TempFechasHabiles') IS NOT NULL DROP TABLE #TempFechasHabiles;    
  
			  select Movimientos.IDEmpleado  
			   ,FechaInicio =CASE  WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha  
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN @FechaInicioIncidencia  
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia  
				ELSE @FechaInicioIncidencia    
				END    
			   ,FechaFin =CASE WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN Movimientos.Fecha  
				--WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha  
				--WHEN ( Movimientos.Fecha <= @FechaInicioIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN @FechaInicioIncidencia  
				ELSE @FechaFinIncidencia    
				END    
			  INTO #TempFechasHabiles  
			  from #TempMovimientos Movimientos  
		END;  
  
		 IF object_ID('TEMPDB..#TempFestivosLaborados') IS NOT NULL DROP TABLE #TempFestivosLaborados  
  
		  select e.IDEmpleado, COUNT(*) as qty    
			into #TempFestivosLaborados    
		  From @dtempleados e  
			  inner join Asistencia.tblIncidenciaEmpleado IE on e.IDEmpleado = ie.IDEmpleado  
			  inner join #TempFechasHabiles fechas on fechas.IDEmpleado = e.IDEmpleado  
		  Where         
		   IE.IDIncidencia = 'DF'      
			   AND IE.Fecha Between fechas.FechaInicio and fechas.FechaFin        
			   AND IE.Autorizado = 1     
		  GROUP BY e.IDEmpleado  


	  IF object_ID('TEMPDB..#TempDetalle') IS NOT NULL  DROP TABLE #TempDetalle  
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
	   
	   Declare 
		@IDTipoNominaSE int
	;

	select @IDTipoNominaSE = IDTipoNomina from Nomina.tblCatTipoNomina with (nolock) where Descripcion = 'QUINCENAL SERVICIOS'

	IF( (@General = 1 OR @Finiquito = 1) and @IDTipoNomina <> @IDTipoNominaSE)
		BEGIN  
  
			IF @UMA is null OR ISNULL(@UMA,0) = 0  
			BEGIN  
				RAISERROR ('El valor de la UMA para este ejercicio no ha sido capturado', 16, 1);  
				RETURN 1;  
			END   
  
      
			IF @SalarioMinimo is null OR ISNULL(@SalarioMinimo,0) = 0  
			BEGIN  
				RAISERROR ('El valor del Salario Mínimo para este ejercicio no ha sido capturado', 16, 1);  
				RETURN 1;  
			END   
			
			IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		SELECT  
			  Empleados.IDEmpleado,  
			  @IDPeriodo as IDPeriodo,  
			  @Concepto_IDConcepto as IDConcepto,  
			  CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0  
				ELSE  
			   CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)      
				  WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN (((CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
																									ELSE ISNULL(cf.SueldoFiniquito,0) END)*@PorcentajeDescansoObligatorio) * ISNULL(DTLocal.CantidadDias,0))   
				  WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)     
				  WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)     
				  WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)     
				 ELSE   
				  (((CASE WHEN @isPreviewFiniquito = 0 THEN Empleados.SalarioDiario
						ELSE ISNULL(cf.SueldoFiniquito,0) END)*@PorcentajeDescansoObligatorio) * DF.qty)    
                        
				 END  
				END Valor ,  
				CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN null  
				ELSE  
			   CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN null     
				  WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN Cast(cast(ISNULL(DTLocal.CantidadDias,0) as int) as Varchar(MAX)) + ' Dia(s)'   
				  WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN null     
				  WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN null     
				  WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN null     
				 ELSE   
				  Cast(cast(ISNULL(DF.qty,0) as int) as Varchar(MAX)) + ' Dia(s)'                   
				 END  
				END Descripcion  
				 ,DF.qty DiasCalendario  
				,Empleados.SalarioDiario 
				,ISNULL(cf.SueldoFiniquito,0) as SueldoFiniquito
				,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			   ,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			   ,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  
			   ,CASE WHEN ((isnull(DTLocal.CantidadOtro2,0) = -1) ) THEN 0  
				ELSE  
			   CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)      
				  WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)   
				  WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)     
				  WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)     
				  WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)     
				 ELSE   
				  ( DF.qty)    
				 END  
				END as CantidadOtro1  
			   ,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2                             
		INTO #TempValores  
		FROM @dtempleados Empleados  
			Left Join @dtDetallePeriodoLocal DTLocal  
				on Empleados.IDEmpleado = DTLocal.IDEmpleado  
			left join #TempFestivosLaborados DF  
				on DF.IDEmpleado = Empleados.IDEmpleado  
			left join Nomina.tblControlFiniquitos cf
				on cf.IDEmpleado = Empleados.IDEmpleado
				and cf.IDPeriodo = @IDPeriodo
 
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
				 IF(ISNULL(@Concepto_LFT,0) = 1)  
		   BEGIN  
				insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)  
				Select IDEmpleado,   
					  IDPeriodo,  
					  IDConcepto,  
					  CantidadDias ,  
					  CantidadMonto,  
					  CantidadVeces,  
					  CantidadOtro1,  
					  CantidadOtro2,  
					  ImporteGravado =  --Salario Minimo   
						  CASE WHEN SalarioDiario <= @SalarioMinimo THEN  0
							 
						   ELSE  -- Mayor al salario minimo  
							CASE WHEN ISNULL(Valor,0) > 0  and  Valor/2 <= (@UMA * @UMASExentas) THEN Valor/2 
							  WHEN ISNULL(Valor,0) > 0  and  Valor/2 > (@UMA * @UMASExentas) THEN Valor - (@UMA * @UMASExentas)  
							ELSE 0  
							END  
							END,  
  
					  ImporteExcento =      --Salario Minimo   
						  CASE WHEN SalarioDiario <= @SalarioMinimo THEN  valor
							 
						   ELSE  -- Mayor al salario minimo  
							CASE WHEN ISNULL(Valor,0) > 0  and  Valor / 2 <= (@UMA * @UMASExentas) THEN Valor/2  
							  WHEN ISNULL(Valor,0) > 0  and  Valor/2 > (@UMA * @UMASExentas) THEN (@UMA * @UMASExentas)  
							ELSE 0  
							END  
             
					   END  
					  ,  
					  ImporteTotal1 = Valor,  
					  ImporteTotal2 = 0.00,  
					  Descripcion,  
					  IDReferencia = NULL  
				FROM #TempValores  
		   END 

		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
 

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
		(isnull(CantidadMonto,0)+		 
		isnull(CantidadDias,0)+		 
		isnull(CantidadVeces,0)+		 
		isnull(CantidadOtro1,0)+		 
		isnull(CantidadOtro2,0)+		 
		isnull(ImporteGravado,0)+		 
		isnull(ImporteExcento,0)+		 
		isnull(ImporteOtro,0)+		 
		isnull(ImporteTotal1,0)+		 
		isnull(ImporteTotal2,0) ) > 0	 
END;
GO

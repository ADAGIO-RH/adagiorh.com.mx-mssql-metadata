USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	/*
		NO MOVER ESTE SP ***( ARTURO )
		STORE PROCEDURE IMPORTANTE
	*/


/**************************************************************************************************** 
** Descripción		: PLAN DE PENSION
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
CREATE PROC [Nomina].[spConcepto_198]
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
		,@Codigo varchar(20) = '198' 
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
		,@IDConcepto005 int  /*Días Pagados*/
        ,@IDConcepto007 int  /*Sé´ptimo Día*/
		,@ConceptosExcluidos varchar(1000) = '500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,519,520'  
		,@IDConcepto017 int -- Festivo Laborado pensión
		,@IDConcepto018 int -- Descanso Laborado pensión
		,@IDConcepto019 int -- Prima Dominical
		,@IDConcepto020 int -- Vacaciones pensión
		,@IDConcepto021 int -- Prima Vacacional pensión
		,@IDConcepto030 int -- Aguinaldo pensión
		,@IDConcepto032 int -- Indemnización Pensión (90 Dias)
		,@IDConcepto033 int -- Indemnización Pensión (20 Dias x Años)
		,@IDConcepto034 int -- Prima Antiguedad Pensión
		,@IDConcepto010 int -- Tiempo Extra Pensión
		,@IDConcepto035 int -- Vales de Despensa Pensión
		,@IDConcepto036 int -- Bono de Productividad Pensión
		,@IDConcepto061 int -- Fondo de Ahorro Empresa Pensión
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select @IDConcepto005=IDConcepto from @dtConceptos where Codigo = '005'
	select @IDConcepto007=IDConcepto from @dtConceptos where Codigo = '007'

	select @IDConcepto017=IDConcepto from @dtConceptos where Codigo = '017'
	select @IDConcepto018=IDConcepto from @dtConceptos where Codigo = '018'
	select @IDConcepto018=IDConcepto from @dtConceptos where Codigo = '019'
	select @IDConcepto020=IDConcepto from @dtConceptos where Codigo = '020'
	select @IDConcepto021=IDConcepto from @dtConceptos where Codigo = '021'
	select @IDConcepto030=IDConcepto from @dtConceptos where Codigo = '030'
	select @IDConcepto032=IDConcepto from @dtConceptos where Codigo = '032'
	select @IDConcepto033=IDConcepto from @dtConceptos where Codigo = '033'
	select @IDConcepto034=IDConcepto from @dtConceptos where Codigo = '034'
	select @IDConcepto010=IDConcepto from @dtConceptos where Codigo = '010'

	--Conceptos Exclusivos para Surfax Interna
	select @IDConcepto035=IDConcepto from @dtConceptos where Codigo = '035'
	select @IDConcepto036=IDConcepto from @dtConceptos where Codigo = '036'
	select @IDConcepto061=IDConcepto from @dtConceptos where Codigo = '061'


 
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
		--,dp.IDPeriodo  
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
							and c.Codigo not in( '198', '184', '185','146','168','169','118','400','401','402')
			and c.Estatus = 1
	GROUP BY e.IDEmpleado  

	--Este codigo concatena los cocneptos a excluir de las deducciones para la pension
	declare @str varchar(max)
	declare @ConceptosExcluidos1 varchar(max)

	SELECT @str = isnull(@str +',', '') + a.Codigo
	FROM (select Codigo from Nomina.tblCatConceptos where ( IDTipoConcepto = 2 and Codigo not in ('301','301A','301B','301C','302','303','384','385') ) ) a

	SELECT @ConceptosExcluidos1 = @str + ',' + @ConceptosExcluidos

	Declare @strEspecial varchar(max) 
	Declare @ConceptosExcluidos2 varchar(max) 
	SELECT @strEspecial = isnull(@strEspecial +',', '') + a.Codigo
	FROM (select Codigo from Nomina.tblCatConceptos where ( IDTipoConcepto = 2 ) ) a

	
	SELECT @ConceptosExcluidos2 = @strEspecial + ',' + @ConceptosExcluidos


	if OBJECT_ID('tempdb..#tempDeducciones') is not null  
		drop table #tempDeducciones;  
  
	select e.IDEmpleado  
	  
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
						and TipoConcepto.Descripcion in('DEDUCCION')  
							and c.Codigo  not in (select Item from App.split(@ConceptosExcluidos1,','))  
							
								and c.Estatus = 1
			WHERE e.ClaveEmpleado not in ('ADG0001','ADG0009','ADG0003','ADG0010') 
	GROUP BY e.IDEmpleado  

	if OBJECT_ID('tempdb..#tempDeduccionesEspeciales') is not null  
		drop table #tempDeduccionesEspeciales;  
  
	select e.IDEmpleado  
	  
		,sum(dp.ImporteGravado) as ImporteGravado  
		,sum(dp.ImporteExcento) as ImporteExcento  
		,sum(dp.ImporteOtro) as ImporteOtro  
		,sum(dp.ImporteTotal1) as ImporteTotal1  
		,sum(dp.ImporteTotal2) as ImporteTotal2  
	into #tempDeduccionesEspeciales    
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
						and TipoConcepto.Descripcion in('DEDUCCION')  
							and c.Codigo  not in (select Item from App.split(@ConceptosExcluidos2,','))  
							
								and c.Estatus = 1
			WHERE e.ClaveEmpleado in ('ADG0001','ADG0009','ADG0003','ADG0010') 
	GROUP BY e.IDEmpleado  

	insert into #tempDeducciones
	select * from #tempDeduccionesEspeciales

	if OBJECT_ID('tempdb..#tempInfoPension') is not null  
		drop table #tempInfoPension;  
  

	select e.IDEmpleado  
		--,dp.IDPeriodo  
		,sum(dp.ImporteGravado) as ImporteGravado  
		,sum(dp.ImporteExcento) as ImporteExcento  
		,sum(dp.ImporteOtro) as ImporteOtro  
		,sum(dp.ImporteTotal1) as ImporteTotal1  
		,sum(dp.ImporteTotal2) as ImporteTotal2  
	into #tempInfoPension    
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
					
			where  c.Estatus = 1
			 and c.Codigo in( '016','017', '018','019', '020', '021','022','023', '030', '032', '033', '034','010', '036', '037', '038', '039', '040')
	GROUP BY e.IDEmpleado  


 
	IF(@General = 1 OR @Finiquito = 1 or @Especial = 1)
	BEGIN
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE		WHEN @Concepto_bCantidadOtro2  = 1 and ISNULL(DTLocal.CantidadOtro2,0) = -1 THEN 0	--CORRECTA
						WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)
			ELSE
				CASE WHEN Empleados.IDCliente = 13 THEN  --Cuando se calcule Surfax Interna
					ISNULL(dtVales.ImporteTotal1,0) + ISNULL(dtBonoProd.ImporteTotal1,0) + ISNULL(dtFondoAhorroEmp.ImporteTotal1,0)
				ELSE
					CASE WHEN ( ISNULL ( Empleados.SalarioDiarioReal , 0 ) <> 0 )  THEN --SI EL EMPLEADO TIENE SDR CARGADO
						( ISNULL ( Empleados.SalarioDiarioReal , 0 ) *( ISNULL ( dtDiasPagados.ImporteTotal1 , 0 ) + ISNULL (dtSeptimoDia.ImporteTotal1,0 ) ) ) --TOTAL DE PLAN PRIVADO DE PENSIONES ( SDR * DIAS PAGADOS )
					  - ( ISNULL ( tempPercepciones.Importetotal1 , 0  )  - ISNULL ( tempDeducciones.Importetotal1 , 0  ) )-- MENOS TOTAL DE SUELDOS Y SALARIOS
					  + ( ISNULL ( DTLocal.CantidadOtro1 , 0 ) ) + isnull(tempPension.ImporteTotal1,0) --SI QUIEREN RESTAR PONENE CANTIDAD EN NEGATIVO AQUI
					ELSE
						0
					END
				END
			END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							  
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left join #tempPercepciones tempPercepciones
				on Empleados.Idempleado = tempPercepciones.idEmpleado
			left join #tempDeducciones tempDeducciones
				on Empleados.Idempleado = tempDeducciones.idEmpleado
			Left Join @dtDetallePeriodo dtDiasPagados
				on Empleados.IDEmpleado = dtDiasPagados.IDEmpleado
					and dtDiasPagados.IDConcepto = @IDConcepto005 -- DIAS PAGADOS
						and dtDiasPagados.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtSeptimoDia
				on Empleados.IDEmpleado = dtSeptimoDia.IDEmpleado
					and dtSeptimoDia.IDConcepto = @IDConcepto007 -- SEPTIMO DIA
						and dtSeptimoDia.IDPeriodo = @IDPeriodo
			-- Sección de Conceptos Exclusivos para Surfax Interna
			Left Join @dtDetallePeriodo dtVales
				on Empleados.IDEmpleado = dtVales.IDEmpleado
					and dtVales.IDConcepto = @IDConcepto035 -- Vales de Despensa Pensión
						and dtVales.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtBonoProd
				on Empleados.IDEmpleado = dtBonoProd.IDEmpleado
					and dtBonoProd.IDConcepto = @IDConcepto036 -- Bono De Productividad
						and dtBonoProd.IDPeriodo = @IDPeriodo
			Left Join @dtDetallePeriodo dtFondoAhorroEmp
				on Empleados.IDEmpleado = dtFondoAhorroEmp.IDEmpleado
					and dtFondoAhorroEmp.IDConcepto = @IDConcepto061 -- Fondo de Ahorro Empresa
						and dtFondoAhorroEmp.IDPeriodo = @IDPeriodo			
			left join #tempInfoPension tempPension
				on tempPension.IDEmpleado = Empleados.IDEmpleado
 
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
		--IF(ISNULL(@Concepto_LFT,0) = 1)  
		--BEGIN  
			insert into #TempDetalle(IDEmpleado,IDPeriodo,IDConcepto,CantidadDias,CantidadMonto,CantidadVeces,CantidadOtro1,CantidadOtro2,ImporteGravado,ImporteExcento,ImporteTotal1,ImporteTotal2,Descripcion,IDReferencia)  
			Select IDEmpleado,   
				IDPeriodo,  
				IDConcepto,  
				CantidadDias ,  
				CantidadMonto,  
				CantidadVeces,  
				CantidadOtro1,  
				CantidadOtro2,  
				ImporteGravado = 0.00,  
				ImporteExcento = Valor,  
				ImporteTotal1 = Valor,  
				ImporteTotal2 = 0.00,  
				Descripcion = '',  
				IDReferencia = NULL  
			FROM #TempValores  
		--END

		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
 

	END

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

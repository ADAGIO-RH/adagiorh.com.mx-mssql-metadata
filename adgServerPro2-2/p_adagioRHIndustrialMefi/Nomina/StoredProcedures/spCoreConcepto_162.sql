USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: DEV. FONDO DE AHORRO EMPRESA
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
2023-03-10          Javier Peña         [CHANGE] Se modifico la manera en la que se identifica el periodo de pago del FA
                                        para hacer la devolución. Ahora solamente busca si el periodo actual esta marcado como
                                        periodo de dev. de algun periodo de FA.
                                        [CHANGE] Se elimino el descuento de los prestamos pendientes al calcular el total a devolver 
                                        debido a que el prestamo se descuenta de manera independiente en el concepto 310
2023-05-22         Javier Peña          [CHANGE] Se agregó condición para que al consultar acumulados se busque en periodos del mismo tipo de nómina 
                                        que el del fondo de ahorro
***************************************************************************************************/
CREATE PROC [Nomina].[spCoreConcepto_162]
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
		,@Codigo varchar(20) = '162' 
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

		,@FechaInicioFondoAhorro date
		,@FechaFinFondoAhorro date

		,@IDFondoAhorro int

		,@IDPeriodoInicial	   int
		,@IDPeriodoFinal	   int 
		,@IDPeriodoPagoFondoAhorro int

		,@ConceptoAportacionEmpresa		varchar(10) = '308'
		,@ConceptoAportacionTrabajador	varchar(10) = '309'

		,@ConceptoFondoAhorroEmpresa	varchar(10) = '161'
		,@IDConceptoFondoAhorroEmpresa	int

		,@ConceptoDevolucionEmpresa		varchar(10) = '162'
		,@ConceptoDevolucionTrabajador  varchar(10) = '163'

		,@ConceptoRetirosEmpresa		varchar(10) = '165'
		,@ConceptoRetirosTrabajador		varchar(10) = '166'

		,@ConceptoPrestamoFondoAhorro	varchar(10) = '310' -- PRÉSTAMO DE FONDO DE AHORRO

		,@FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-12-31'

		,@TotalAportacionesEmpresa		decimal(18,2)
		,@TotalAportacionesTrabajador	decimal(18,2)
		
		,@TotalDevolucionesEmpresa		decimal(18,2)
		,@TotalDevolucionesTrabajador	decimal(18,2)

		,@TotalRetirosEmpresa			decimal(18,2)
		,@TotalRetirosTrabajador		decimal(18,2)
		
		,@TotalAcumulado				decimal(18,2)
		,@TotalPrestamosFondoAhorro		decimal(18,2)
		,@TotalSaldoPendienteADescontar	decimal(18,2)
        ,@EjercicioFA int 

		
	;

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 
 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConceptoFondoAhorroEmpresa=IDConcepto from @dtConceptos where Codigo=@ConceptoFondoAhorroEmpresa; 
 
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

	IF object_ID('TEMPDB..#TempDetalle') IS NOT NULL DROP TABLE #TempDetalle  
     
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

/*	select 
		@IDFondoAhorro = IDFondoAhorro
		,@IDPeriodoPagoFondoAhorro = IDPeriodoPago
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio

	select 
		@IDFondoAhorro = cfa.IDFondoAhorro
		,@FechaIni = cpInicial.FechaInicioPago
		,@FechaFin = ISNULL(cpFinal.FechaFinPago,'9999-12-31')
	from Nomina.tblCatFondosAhorro cfa
		left join Nomina.tblCatPeriodos cpInicial on cfa.IDPeriodoInicial = cpInicial.IDPeriodo 
		left join Nomina.tblCatPeriodos cpFinal on cfa.IDPeriodoFinal = cpFinal.IDPeriodo 
		left join Nomina.tblCatPeriodos cpPago on cfa.IDPeriodoPago = cpPago.IDPeriodo 
	where @FechaInicioPago between cpInicial.FechaInicioPago and ISNULL(cpFinal.FechaFinPago,'9999-12-31')
		and ISNULL(cpPago.Cerrado,0) = 0
*/

IF(@Finiquito = 0)
BEGIN
    select 
        top 1
		 @IDFondoAhorro = IDFondoAhorro
		,@IDPeriodoPagoFondoAhorro = IDPeriodoPago
        ,@EjercicioFA = cfa.Ejercicio
	from Nomina.tblCatFondosAhorro CFA with (nolock)
        left join Nomina.tblCatPeriodos cpInicial on cfa.IDPeriodoInicial = cpInicial.IDPeriodo 
	    left join Nomina.tblCatPeriodos cpFinal on cfa.IDPeriodoFinal = cpFinal.IDPeriodo 
	    left join Nomina.tblCatPeriodos cpPago on cfa.IDPeriodoPago = cpPago.IDPeriodo 
	--where CFA.IDTipoNomina = @IDTipoNomina and CFA.Ejercicio = @Ejercicio
        where CFA.IDPeriodoPago = @IDPeriodo AND  CFA.IDTipoNomina = @IDTipoNomina
        and ISNULL(cpPago.Cerrado,0) = 0
END 
ELSE 
BEGIN 
select 
        top 1
		 @IDFondoAhorro = IDFondoAhorro
		,@IDPeriodoPagoFondoAhorro = IDPeriodoPago
        ,@EjercicioFA = cfa.Ejercicio
	from Nomina.tblCatFondosAhorro CFA with (nolock)
        left join Nomina.tblCatPeriodos cpInicial on cfa.IDPeriodoInicial = cpInicial.IDPeriodo 
	    left join Nomina.tblCatPeriodos cpFinal on cfa.IDPeriodoFinal = cpFinal.IDPeriodo 
	    left join Nomina.tblCatPeriodos cpPago on cfa.IDPeriodoPago = cpPago.IDPeriodo 
	--where CFA.IDTipoNomina = @IDTipoNomina and CFA.Ejercicio = @Ejercicio
        where @FechaInicioPago between cpInicial.FechaInicioPago and ISNULL(cpFinal.FechaFinPago,'9999-12-31')
		and ISNULL(cpPago.Cerrado,0) = 0
        AND CFA.IDTipoNomina = @IDTipoNomina
END


IF OBJECT_ID('tempdb..#TempHistorialTipoNomina') IS NOT NULL DROP TABLE #TempHistorialTipoNomina;

    
		Select 
		    PE.IDTipoNominaEmpleado,
			PE.IDEmpleado,
			c.IDCliente,
			PE.IDTipoNomina,
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin,
            DATEPART(YEAR,FechaIni) AS EjercicioFechaIni,
            DATEPART(YEAR,FechaFin) AS EjercicioFechaFin
		INTO #TempHistorialTipoNomina
        From RH.tblTipoNominaEmpleado PE with(nolock)
			Inner join Nomina.tblCatTipoNomina P with(nolock)
				on PE.IDTipoNomina = P.IDTipoNomina
			Inner join RH.tblCatClientes c  with(nolock)
				on p.IDCliente = c.IDCliente
            Inner join @dtempleados e on pe.IDEmpleado = e.IDEmpleado
		ORDER BY PE.FechaIni Desc


        select 

		 cfa.IDFondoAhorro
        ,TNE.IDEmpleado
		,cfa.IDTipoNomina
		,tn.Descripcion as TipoNomina
		,cfa.Ejercicio
		,cfa.IDPeriodoInicial
		,p.Descripcion as PeriodoInicial
		,isnull(cfa.IDPeriodoFinal,0) as IDPeriodoFinal
		,UPPER(isnull(pp.Descripcion,'SIN ASIGNAR')) as PeriodoFinal		
        ,ROW_NUMBER()OVER(partition by TNE.IDEmpleado ORDER BY TNE.fechaini) as RN
        ,ROW_NUMBER()OVER(partition by TNE.IDEmpleado ORDER BY TNE.fechaini desc) as RN2
        ,p.FechaInicioPago
        ,pp.FechaFinPago
        ,cfa.IDPeriodoPago
        ,ppago.Descripcion
        ,ppago.Cerrado
into #TempHistorilFondoAhorro
	from Nomina.tblCatFondosAhorro cfa with(nolock)
		join Nomina.tblCatTipoNomina tn with(nolock) 
            on cfa.IDTipoNomina = tn.IDTipoNomina
		join Nomina.tblCatPeriodos p with(nolock) 
            on cfa.IDPeriodoInicial = p.IDPeriodo    
		left join Nomina.tblCatPeriodos pp with(nolock) 
            on cfa.IDPeriodoFinal = pp.IDPeriodo
		left join Nomina.tblCatPeriodos ppago with(nolock) 
            on cfa.IDPeriodoPago = ppago.IDPeriodo 
        join #TempHistorialTipoNomina TNE 
            ON TNE.IDTipoNomina=CFA.IDTipoNomina
    WHERE tne.FechaFin > p.FechaInicioPago
    and cfa.Ejercicio = @EjercicioFA 
    and (ppago.Cerrado = 0 or ppago.Cerrado is null)


    

   

    if object_id('tempdb..#tempPeriodosPago') is not null drop table #tempPeriodosPago;

    SELECT ISNULL(IDPeriodoPago,0) AS IDPeriodoPago
    INTO #tempPeriodosPago
    FROM Nomina.tblCatFondosAhorro


	if (isnull(@IDFondoAhorro,0) = 0) return;

	if object_id('tempdb..#tempPrestamos') is not null drop table #tempPrestamos;

	--select @IDPeriodoInicial = IDPeriodoInicial
	--	  ,@IDPeriodoFinal = IDPeriodoFinal
	--from Nomina.tblCatFondosAhorro with (nolock)
	--where IDFondoAhorro = @IDFondoAhorro

	--select @FechaIni=FechaInicioPago	from [Nomina].[tblCatPeriodos] with (nolock) where IDPeriodo = @IDPeriodoInicial
	--select @FechaFin=FechaFinPago		from [Nomina].[tblCatPeriodos] with (nolock) where IDPeriodo = @IDPeriodoFinal
	
	--set @FechaFin = isnull(@FechaFin,'9999-12-31')

	IF object_ID('TEMPDB..#TempTotalDeApartaciones') IS NOT NULL		DROP TABLE #TempTotalDeApartaciones
	IF object_ID('TEMPDB..#TempTotalDeDevoluciones') IS NOT NULL		DROP TABLE #TempTotalDeDevoluciones
	IF object_ID('TEMPDB..#TempTotalDeRetiros') IS NOT NULL				DROP TABLE #TempTotalDeRetiros
	IF object_ID('TEMPDB..#TempTotalPrestamosFondoAhorro') IS NOT NULL	DROP TABLE #TempTotalPrestamosFondoAhorro

	DECLARE @tempTotalesFondo TABLE(    
		IDEmpleado					int,
		TotalAportaciones			decimal(18,2), 
		TotalDevoluciones			decimal(18,2),
		TotalRetiros				decimal(18,2),    
		-- TotalPrestamosFondoAhorro	decimal(18,2),
		TotalADevolver				as isnull(TotalAportaciones,0.00) - (isnull(TotalDevoluciones,0.00)+isnull(TotalRetiros,0.00)/*+isnull(TotalPrestamosFondoAhorro,0.00)*/)
	);

	IF ((@IDPeriodo = ISNULL(@IDPeriodoPagoFondoAhorro,0)) or (@Finiquito = 1 and @isPreviewFiniquito = 1))
	BEGIN
		-- TOTAL DE APORTACIONES EMPRESA Y COLABORADOR
		Select DP.IDEmpleado as IDEmpleado,  
			ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
			ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
			ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
			ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
		INTO #TempTotalDeApartaciones
		from Nomina.tblDetallePeriodo DP with (nolock)  
			Inner join @dtEmpleados e on DP.IDEmpleado = e.IDEmpleado
			Inner join Nomina.tblCatPeriodos P with (nolock) on DP.IDPeriodo = P.IDPeriodo AND P.Cerrado = 1  
			Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto
            Inner join #TempHistorilFondoAhorro thtn on thtn.IDEmpleado = e.IDEmpleado and thtn.RN = 1 
            Inner join #TempHistorilFondoAhorro thtn2 on thtn2.IDEmpleado = e.IDEmpleado and thtn2.RN2 = 1
		where c.Codigo in (select item from app.Split(@ConceptoAportacionEmpresa+','+@ConceptoAportacionTrabajador,','))  
			and p.FechaFinPago between thtn.FechaInicioPago and thtn2.FechaFinPago 
            --and p.IDTipoNomina=@IDTipoNomina
        -- and p.IDPeriodo not in(SELECT IDPeriodoPago FROM #tempPeriodosPago)
		group by DP.IDEmpleado

		
      

		-- TOTAL DEVOLUCIONES EMPRESA Y COLABORADOR
		Select DP.IDEmpleado as IDEmpleado,  
			ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
			ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
			ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
			ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
		INTO #TempTotalDeDevoluciones
		from Nomina.tblDetallePeriodo DP with (nolock)  
			Inner join @dtEmpleados e on DP.IDEmpleado = e.IDEmpleado
			Inner join Nomina.tblCatPeriodos P with (nolock) on DP.IDPeriodo = P.IDPeriodo AND P.Cerrado = 1  
			Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
            Inner join #TempHistorilFondoAhorro thtn on thtn.IDEmpleado = e.IDEmpleado and thtn.RN = 1 
            Inner join #TempHistorilFondoAhorro thtn2 on thtn2.IDEmpleado = e.IDEmpleado and thtn2.RN2 = 1
		where c.Codigo in (select item from app.Split(@ConceptoDevolucionEmpresa+','+@ConceptoDevolucionTrabajador,','))  
			and p.FechaFinPago between thtn.FechaInicioPago and thtn2.FechaFinPago  
            --and p.IDTipoNomina=@IDTipoNomina
            and p.IDPeriodo not in(SELECT IDPeriodoPago FROM #tempPeriodosPago)
		group by DP.IDEmpleado

		-- TOTAL RETIROS EMPRESA Y COLABORADOR
		Select DP.IDEmpleado as IDEmpleado,  
			ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
			ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
			ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
			ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
		INTO #TempTotalDeRetiros
		from Nomina.tblDetallePeriodo DP with (nolock)  
			Inner join @dtEmpleados e on DP.IDEmpleado = e.IDEmpleado
			Inner join Nomina.tblCatPeriodos P with (nolock) on DP.IDPeriodo = P.IDPeriodo AND P.Cerrado = 1  
			Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
            Inner join #TempHistorilFondoAhorro thtn on thtn.IDEmpleado = e.IDEmpleado and thtn.RN = 1 
            Inner join #TempHistorilFondoAhorro thtn2 on thtn2.IDEmpleado = e.IDEmpleado and thtn2.RN2 = 1
		where c.Codigo in (select item from app.Split(@ConceptoRetirosEmpresa+','+@ConceptoRetirosTrabajador,','))  
			and p.FechaFinPago between thtn.FechaInicioPago and thtn2.FechaFinPago  
           -- and p.IDTipoNomina=@IDTipoNomina
            and p.IDPeriodo not in(SELECT IDPeriodoPago FROM #tempPeriodosPago)
		group by DP.IDEmpleado

		-- select IDEmpleado,sum(Balance) as TotalPrestamosFondoAhorro
		-- INTO #TempTotalPrestamosFondoAhorro
		-- from (
		-- 	select     
		-- 		p.IDEmpleado
		-- 		,P.MontoPrestamo - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		-- 	from [Nomina].[tblPrestamos] p    
		-- 	inner join [Nomina].[tblCatTiposPrestamo] TP with (nolock) on p.IDTipoPrestamo = TP.IDTipoPrestamo
		-- 	inner join [Nomina].[tblPrestamosFondoAhorro] pfa with (nolock) on p.IDPrestamo = pfa.IDPrestamo
		-- 	inner join [Nomina].[tblCatEstatusPrestamo] EP  with (nolock) on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
		-- 	inner join @dtEmpleados e on P.IDEmpleado = e.IDEmpleado    
		-- 	where (pfa.IDFondoAhorro = @IDFondoAhorro)  
		-- 		and TP.IDTipoPrestamo = 6
		-- 		and p.IDEstatusPrestamo in (2,1,3)
		-- 	--order by p.FechaCreacion desc  
		-- ) prestamos
		-- group by IDEmpleado

		insert @tempTotalesFondo
		select 
			e.IDEmpleado
			,isnull(totalAportaciones.ImporteTotal1,0)					as TotalAportaciones
			,isnull(totalDevoluciones.ImporteTotal1,0)					as TotalDevoluciones
			,isnull(totalRetiros.ImporteTotal1,0)						as TotalRetiros
			--,isnull(totalPrestamos.TotalPrestamosFondoAhorro,0)			as TotalPrestamosFondoAhorro
		from @dtEmpleados e
			left join #TempTotalDeApartaciones		  totalAportaciones on e.IDEmpleado = totalAportaciones.IDEmpleado
			left join #TempTotalDeDevoluciones		  totalDevoluciones on e.IDEmpleado = totalDevoluciones.IDEmpleado
			left join #TempTotalDeRetiros			  totalRetiros		on e.IDEmpleado = totalRetiros.IDEmpleado
			--left join #TempTotalPrestamosFondoAhorro  totalPrestamos	on e.IDEmpleado = totalPrestamos.IDEmpleado 
		order by e.IDEmpleado



END 

	IF((@IDPeriodo = @IDPeriodoPagoFondoAhorro))
	BEGIN
		IF object_ID('TEMPDB..#TempValores') IS NOT NULL DROP TABLE #TempValores
 
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE fondo.TotalADevolver / 2.00																	  
				END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							  
		INTO #TempValores
		FROM @dtempleados Empleados
			left join @tempTotalesFondo fondo on Empleados.IDEmpleado = fondo.IDEmpleado
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
 
		/* Inicio de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* @Concepto_LFT, @Concepto_Personalizada, @Concepto_ConDoblePago*/
		
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
		--IF(ISNULL(@Concepto_LFT,0) = 1)  
		--BEGIN  
		--END

		/* FIN de segmento para programar las opciones de LFT, Personalizada, Doble Paga*/
		/* Fin de segmento para programar el cuerpo del concepto*/
	END ELSE
	IF (@Finiquito = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA FINIQUITOS AQUÍ */
		
		IF object_ID('TEMPDB..#TempValoresFiniquito') IS NOT NULL DROP TABLE #TempValoresFiniquito
 
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE (fondo.TotalADevolver / 2.00) + isnull(DTFondoAhorroEmpresa.ImporteTotal1,0.00)
				END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							  
		INTO #TempValoresFiniquito
		FROM @dtempleados Empleados
			left join @tempTotalesFondo fondo on Empleados.IDEmpleado = fondo.IDEmpleado
			left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			left Join @dtDetallePeriodo DTFondoAhorroEmpresa
				on Empleados.IDEmpleado = DTFondoAhorroEmpresa.IDEmpleado
					and DTFondoAhorroEmpresa.IDConcepto = @IDConceptoFondoAhorroEmpresa
				
		
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
		FROM #TempValoresFiniquito  

	END ELSE
	IF (@Especial = 1)
	BEGIN
		/* AGREGAR CÓDIGO PARA ESPECIALES AQUÍ */
	IF object_ID('TEMPDB..#TempValoresEspeciales') IS NOT NULL DROP TABLE #TempValoresEspeciales
 
		SELECT
			Empleados.IDEmpleado,
			@IDPeriodo as IDPeriodo,
			@Concepto_IDConcepto as IDConcepto,
			CASE WHEN @Concepto_bCantidadMonto  = 1 and ISNULL(DTLocal.CantidadMonto,0) > 0 THEN ISNULL(DTLocal.CantidadMonto,0)		  
						WHEN @Concepto_bCantidadDias  = 1 and ISNULL(DTLocal.CantidadDias,0)  > 0 THEN ISNULL(DTLocal.CantidadDias,0)	  
						WHEN @Concepto_bCantidadVeces = 1 and ISNULL(DTLocal.CantidadVeces,0) > 0 THEN ISNULL(DTLocal.CantidadVeces,0)	  
						WHEN @Concepto_bCantidadOtro1 = 1 and ISNULL(DTLocal.CantidadOtro1,0) > 0 THEN ISNULL(DTLocal.CantidadOtro1,0)	  
						WHEN @Concepto_bCantidadOtro2 = 1 and ISNULL(DTLocal.CantidadOtro2,0) > 0 THEN ISNULL(DTLocal.CantidadOtro2,0)	  
				ELSE 0 -- Función personalizada																			  
				END Valor
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto  
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias  
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							  
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							  
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							  
		INTO #TempValoresEspeciales
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
		
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
				ImporteGravado = 0.00,  
				ImporteExcento = Valor,  
				ImporteTotal1 = Valor,  
				ImporteTotal2 = 0.00,  
				Descripcion = '',  
				IDReferencia = NULL  
			FROM #TempValoresEspeciales  
		END
	
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

USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE PROC [Reportes].[spReporteBasicoCostoPersonalAbraham](
		 @dtFiltros [Nomina].[dtFiltrosRH]  READONLY
		,@IDUsuario INT	
	) AS

	SET NOCOUNT ON;
		IF 1=0 
	BEGIN
		SET FMTONLY OFF
	END


	declare
		 @FechaInicioPago date	-- = '2019-03-01'
		,@FechaFinPago date		-- = '2019-04-15'
		,@IDTipoNomina int		-- = 4
		,@dtEmpleados [RH].[dtEmpleados]
		,@UMA decimal(18,4)        
		,@Tope25UMA decimal(18,4)        
		,@Tope3UMA decimal(18,4) 
		,@FinDeAno Date
		,@Homologa varchar(10)
		,@SalarioMinimo float
		,@Ejercicio int 
		,@IDMes int


		SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
		SET @FechaInicioPago = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
		SET @FechaFinPago = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
		set @FinDeAno = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)

		set @Ejercicio = DATEPART ( YEAR, @FechaInicioPago )
		set @IDMes		= DATEPART ( MONTH, @FechaInicioPago )
         
		select top 1         
			 @UMA  = UMA        
			,@Tope25UMA = UMA * 25        
			,@Tope3UMA  = UMA *3    
			,@SalarioMinimo = SalarioMinimo    
		from Nomina.TblSalariosMinimos with (nolock)        
			where Fecha <= @FechaFinPago        
		order by Fecha desc   

		
		if object_id('tempdb..#temporal') is not null drop table #temporal;
		if object_id('tempdb..#tablaPreLlenada') is not null drop table #tablaPreLlenada;


		create table #tempEmpleadosFinal(
			IDEmpleado	int
			--,ClaveEmpleado varchar(20)
			--,NombreCompleto varchar(max)
			--,FechaIngreso  date
			--,Sucursal varchar(255)
			--,Departamento	 varchar(255)
			--,Puesto			 varchar(255)
			--,TipoContratacion varchar(255)
			,SalarioDiario money
			,SalarioIntegrado money
			,IDConcepto varchar(20)
			,Concepto varchar(100) 
			,Valor money
		);
	
		insert @dtEmpleados
		exec [RH].[spBuscarEmpleados] @FechaIni = @FechaInicioPago, @FechaFin = @FechaFinPago, @IDTipoNomina = @IDTipoNomina,@IDUsuario = @IDUsuario


		SELECT  
			ClaveEmpleado		AS	[CLAVE],
			NOMBRECOMPLETO		AS	[NOMBRE COMPLETO],
			FechaAntiguedad		AS	[INGRESO],
			Departamento		AS	[DEPARTAMENTO],
			Puesto				AS	[PUESTO],
			SalarioDiario * 30	AS	[S. MENSUAL],
			/*CASE WHEN ( ( SalarioDiario * 30 ) * 0.13 ) > ( ( ( @UMA * 10 * 0.13 ) *365 ) / 12 ) THEN
				( ( ( @UMA * 10 * 0.13 ) *365 ) / 12 ) 
			ELSE	
				( ( SalarioDiario * 30 ) * 0.13 )
			END AS [FONDO AHORRO],
			@UMA * 30	AS [VALES],*/
			( Asistencia.fnBuscarDiasAguinaldoProporcionales(e.IDEmpleado,e.IDTipoPrestacion,e.FechaAntiguedad, @FinDeAno ) * e.SalarioDiario ) / 12  as [AGUINALDO],
			( ( PD.DiasVacaciones * E.SalarioDiario ) * pd.PrimaVacacional ) / 12 as [PRIMA VACACIONAL],
			e.SalarioIntegrado as [INTEGRADO],

			(Select top 1 Prima             
				from [RH].[tblHistorialPrimaRiesgo]             
				where IDRegPatronal= e.IDRegPatronal            
				and Anio <= @Ejercicio            
				and Mes <= @IDMes            
				order by Anio desc,Mes desc) as [PRIMA RIESGO] 
		INTO #temporal
		FROM @dtEmpleados e
			Left Join RH.tblCatTiposPrestacionesDetalle PD  
				on E.IDTipoPrestacion = PD.IDTipoPrestacion  
					and PD.Antiguedad = CASE WHEN DATEDIFF(YEAR,E.FechaAntiguedad,@FechaFinPago) < 1 THEN 1  
						ELSE DATEDIFF(YEAR,E.FechaAntiguedad,@FechaFinPago)
						END  

		SELECT 
			[CLAVE],
			[NOMBRE COMPLETO],
			[INGRESO],
			[DEPARTAMENTO],
			[PUESTO],
			[S. MENSUAL],
			--[FONDO AHORRO],
			--FLOOR ( [VALES] ) AS [VALES],
			[AGUINALDO],
			[PRIMA VACACIONAL],
			[S. MENSUAL] + /*[FONDO AHORRO] + [VALES] +*/ [AGUINALDO] + [PRIMA VACACIONAL] AS [PERCEPCIONES],
			( [S. MENSUAL] /*+ [FONDO AHORRO] + [VALES]*/  ) * 0.02 AS [ISN],
			( ( PorcentajesPago.Infonavit ) * 30 ) * [INTEGRADO] AS [5% INFONAVIT],
			---INICIA IMSS PATRONAL
				--CUOTA FIJA PATRON
					( @SalarioMinimo * 30 ) * PorcentajesPago.CuotaFija AS [CUOTA_FIJA_PATRON], --CTAS_IMSS_CF
				--EXEDENTE DE 3 SALARIOS MINIMOS
					CASE WHEN [INTEGRADO] > ( 3 * @SalarioMinimo ) THEN
						( ( [INTEGRADO] - ( 3 * @SalarioMinimo ) ) * 30 ) * PorcentajesPago.ExcedentePatronal
						ELSE 0	END AS [EXEDENTE3SALARIOS],
				--CUOTAS DE PRESTACIONES EN DINERO PATRON
					 ( [INTEGRADO] * 30 ) * PorcentajesPago.PrestacionesDineroPatronal AS [PRESTACIONESPATRONAL],
				--CUOTAS DE GUARDERIA PATRON
					 ( [INTEGRADO] * 30 ) * PorcentajesPago.GuarderiasPrestacionesSociales AS [GUARDERIAS],
				--CUOTAS DE RIESGO PENSIONES PATRON
					 ( ( [INTEGRADO] * 30 ) * [PRIMA RIESGO] ) AS [RIESGO PENSIONES PATRON],
				--CUOTAS DE RESERVAS PENSIONES PATRON
					 ( [INTEGRADO] * 30 ) * PorcentajesPago.GMPensionadosPatronal AS [RESERVAS PENSIONES PATRON],
				--CUOTAS DE INVALIDEZ
					CASE WHEN [INTEGRADO] > ( 25 * @SalarioMinimo ) THEN
						( ( 25 * @SalarioMinimo ) * 30 ) * PorcentajesPago.InvalidezVidaPatronal 
					ELSE ( [INTEGRADO] * 30 ) * PorcentajesPago.InvalidezVidaPatronal END AS [CUOTAS INVALIDEZ PATRON],
				--CESAP
					(  [INTEGRADO] * 30 ) * PorcentajesPago.CesantiaVejezPatron  AS [CESAP],
				--RETIP
					(  [INTEGRADO] * 30 ) * PorcentajesPago.SeguroRetiro  AS [RETIP],

			--INICIA IMSS OBRERO
					CASE WHEN [CLAVE] = '0001' THEN 
						0		
					ELSE
						CASE WHEN [INTEGRADO] >= @Tope25Uma THEN 
							( ( @Tope25Uma * ( PorcentajesPago.PrestacionesDineroObrera + PorcentajesPago.GMPensionadosObrera ) ) * 30  ) +
							( ( @Tope25Uma - ( @SalarioMinimo * 3 )  ) * PorcentajesPago.ExcedenteObrera ) * 30 +
							( ( ( ( 25 * @SalarioMinimo ) * PorcentajesPago.InvalidezVidaObrera ) ) * 30 ) +
							( ( ( ( 25 * @SalarioMinimo ) * PorcentajesPago.CesantiaVejezObrera ) ) * 30 )
						ELSE
							CASE WHEN [INTEGRADO] > ( @SalarioMinimo * 3) THEN
									( [INTEGRADO] * ( PorcentajesPago.PrestacionesDineroObrera + PorcentajesPago.GMPensionadosObrera ) * 30 ) +
									( [INTEGRADO] * ( PorcentajesPago.InvalidezVidaObrera + PorcentajesPago.CesantiaVejezObrera ) * 30 ) +
									( ( [INTEGRADO] - ( @SalarioMinimo * 3) ) * PorcentajesPago.ExcedenteObrera ) * 30
							ELSE
									[INTEGRADO] * ( PorcentajesPago.PrestacionesDineroObrera + PorcentajesPago.GMPensionadosObrera ) * 30 +
									[INTEGRADO] * ( PorcentajesPago.InvalidezVidaObrera + PorcentajesPago.CesantiaVejezObrera ) * 30 
							END
						END
					END AS [IMSS OBRERO]

			INTO #tablaPreLlenada
		FROM #temporal,
			( select top 1 *        
				from [IMSS].[tblCatPorcentajesPago] with (nolock)        
					where Fecha <= @FechaFinPago        
						order by Fecha desc) as PorcentajesPago 


		SELECT 
			[CLAVE] as Clave,
			[NOMBRE COMPLETO] as Nombre_Completo,
			[INGRESO] as Ingreso,
			[DEPARTAMENTO] as Departamento,
			[PUESTO] as Puesto,
			ROUND( [S. MENSUAL] , 2 )		AS S_MENSUAL ,
			--ROUND( [FONDO AHORRO], 2)		AS FONDO_AHORRO,
			--ROUND( [VALES] ,2 )				AS VALES,
			ROUND( [AGUINALDO], 2)			AS AGUINALDO ,
			ROUND( [PRIMA VACACIONAL] , 2 ) AS PRIMA_VACACIONAL,
			ROUND( [PERCEPCIONES] , 2 )		AS PERCEPCIONES,
			ROUND( [ISN], 2 )				AS ISN,
			ROUND( [5% INFONAVIT], 2 )		AS INFONAVIT,
			ROUND( [CUOTA_FIJA_PATRON] + [EXEDENTE3SALARIOS] + [PRESTACIONESPATRONAL] + [GUARDERIAS] + [RIESGO PENSIONES PATRON] + [RESERVAS PENSIONES PATRON] + [CUOTAS INVALIDEZ PATRON] + [CESAP] + [RETIP] , 2 ) AS IMSS_PATRONAL,
			ROUND( [IMSS OBRERO], 2 ) AS IMSS_OBRERO,
			ROUND( [ISN] + [5% INFONAVIT] + [CUOTA_FIJA_PATRON] + [EXEDENTE3SALARIOS] + [PRESTACIONESPATRONAL] + [GUARDERIAS] + [RIESGO PENSIONES PATRON] + [RESERVAS PENSIONES PATRON] + [CUOTAS INVALIDEZ PATRON] + [CESAP] + [RETIP] + [IMSS OBRERO] , 2 ) AS IMPUESTO,
			ROUND( [PERCEPCIONES] + [ISN] + [5% INFONAVIT] + [CUOTA_FIJA_PATRON] + [EXEDENTE3SALARIOS] + [PRESTACIONESPATRONAL] + [GUARDERIAS] + [RIESGO PENSIONES PATRON] + [RESERVAS PENSIONES PATRON] + [CUOTAS INVALIDEZ PATRON] + [CESAP] + [RETIP] + [IMSS OBRERO] , 2 ) AS COSTO_NETO
		FROM #tablaPreLlenada
			---order by Departamento
			--ORDER BY [NOMBRE COMPLETO]

		--SUMATORIA
		SELECT 
		   
		SUM ( ROUND( [S. MENSUAL], 2) ) AS S_MENSUAL,
		--SUM ( ROUND( [FONDO AHORRO], 2) ) AS FONDO_AHORRO,
		--SUM ( ROUND( [VALES], 2) ) AS VALES,
		SUM ( ROUND( [AGUINALDO], 2) ) AS AGUINALDO, 
		SUM ( ROUND( [PRIMA VACACIONAL], 2) ) AS PRIMA_VACACIONAL, 
		SUM ( ROUND( [PERCEPCIONES], 2) ) AS PERCEPCIONES, 
		SUM ( ROUND( [ISN], 2) ) AS ISN, 
		SUM ( ROUND( [5% INFONAVIT], 2) ) AS INFONAVIT, 
		SUM ( ROUND( [CUOTA_FIJA_PATRON] + [EXEDENTE3SALARIOS] + [PRESTACIONESPATRONAL] + [GUARDERIAS] + [RIESGO PENSIONES PATRON] + [RESERVAS PENSIONES PATRON] + [CUOTAS INVALIDEZ PATRON] + [CESAP] + [RETIP] , 2 ))  AS IMSS_PATRONAL, 
		SUM ( ROUND( [IMSS OBRERO], 2) ) AS IMSS_OBRERO, 
		SUM ( ROUND( [ISN] + [5% INFONAVIT] + [CUOTA_FIJA_PATRON] + [EXEDENTE3SALARIOS] + [PRESTACIONESPATRONAL] + [GUARDERIAS] + [RIESGO PENSIONES PATRON] + [RESERVAS PENSIONES PATRON] + [CUOTAS INVALIDEZ PATRON] + [CESAP] + [RETIP] + [IMSS OBRERO] , 2 )) AS IMPUESTO, 
		SUM ( ROUND( [PERCEPCIONES] + [ISN] + [5% INFONAVIT] + [CUOTA_FIJA_PATRON] + [EXEDENTE3SALARIOS] + [PRESTACIONESPATRONAL] + [GUARDERIAS] + [RIESGO PENSIONES PATRON] + [RESERVAS PENSIONES PATRON] + [CUOTAS INVALIDEZ PATRON] + [CESAP] + [RETIP] + [IMSS OBRERO] , 2 )) AS COSTO_NETO
		FROM #tablaPreLlenada
GO

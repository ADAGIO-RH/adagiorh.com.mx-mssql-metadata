USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: CREDITO INFONAVIT (PROPORCIONALIDAD)
** Autor			: Javier Peña,
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2024-10-25
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
CREATE PROC [Nomina].[spCoreConcepto_304B]
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
		,@Codigo varchar(20) = '304B' 
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
		,@SMGDF decimal(18,2)          
		,@UMA decimal(18,2)         
		,@StartYear date      
		,@FactorDescuento decimal(18,2)        
		,@DiasBismestre int    
		,@IDConceptoDiasVacaciones int    
		,@IDConceptoDiasPagados int    

        ---- VARIABLES REFACTOR
        ,@FechaMinHistorialMov Date
        ,@FechaMaxHistorialMov Date
		,@AusentimosAfectaSUA varchar(max)
        ,@dtFechasMesActual app.dtFechasFull
        ,@dtFechas app.dtFechas
		,@dtVigenciaEmpleado app.dtFechasVigenciaEmpleado
        ,@ID_TIPO_MOVIMIENTO_SUSPENSION int = 2
		,@INFONAVITREFORMA2025 bit = 0
		
	;
    -- if object_id('tempdb..#tempInfonavitAvisos') is not null drop table #tempInfonavitAvisos
    IF OBJECT_ID('tempdb..#tempInfonavitHistorialMovimientos') IS NOT NULL DROP TABLE #tempInfonavitHistorialMovimientos
	IF OBJECT_ID('tempdb..#tempAusentismosIncapacidades') IS NOT NULL DROP TABLE #tempAusentismosIncapacidades
	IF OBJECT_ID('tempdb..#tempInfonavitHistorialMovimientosCompletos') IS NOT NULL DROP TABLE #tempInfonavitHistorialMovimientosCompletos
    IF OBJECT_ID('tempdb..#tempAplicable') IS NOT NULL DROP TABLE #tempAplicable
    
	
	

	select top 1 
		@IDPeriodo = IDPeriodo ,@IDTipoNomina= IDTipoNomina,@Ejercicio = Ejercicio,@ClavePeriodo	= ClavePeriodo,@DescripcionPeriodo =  Descripcion 
		,@FechaInicioPago = FechaInicioPago,@FechaFinPago	= FechaFinPago,@FechaInicioIncidencia = FechaInicioIncidencia,@FechaFinIncidencia=	 FechaFinIncidencia 
		,@Dias = Dias,@AnioInicio = AnioInicio,@AnioFin = AnioFin,@MesInicio = MesInicio,@MesFin = MesFin 
		,@IDMes = IDMes,@BimestreInicio = BimestreInicio,@BimestreFin = BimestreFin 
		,@General = General,@Finiquito = Finiquito,@Especial = Especial,@Cerrado = Cerrado 
	from @dtPeriodo 

	SELECT @INFONAVITREFORMA2025 = CAST(ISNULL(Valor,'0') as bit) FROM Nomina.tblConfiguracionNomina where Configuracion = 'INFONAVITREFORMA2025'

 
	select top 1 @IDConcepto=IDConcepto from @dtConceptos where Codigo=@Codigo; 
	select top 1 @IDConceptoDiasPagados=IDConcepto from @dtConceptos where Codigo='005';      
	select top 1 @IDConceptoDiasVacaciones=IDConcepto from @dtConceptos where Codigo='002';
	    
         
	set @StartYear = cast(cast(@Ejercicio as varchar)+'-01-01' as date)       
      
	
	  select @DiasBismestre = CASE WHEN DATEPART(MONTH,@FechaInicioPago) in (1,2) then   DateDiff(day,@StartYear,EOMONTH( DATEADD(MONTH,1,@StartYear)))+1    
									WHEN DATEPART(MONTH,@FechaInicioPago) in (3,4) then  DateDiff(day,DATEADD(MONTH,2,@StartYear),EOMONTH( DATEADD(MONTH,3,@StartYear)))+1    
									WHEN DATEPART(MONTH,@FechaInicioPago) in (5,6) then  DateDiff(day,DATEADD(MONTH,4,@StartYear),EOMONTH( DATEADD(MONTH,5,@StartYear)))+1    
									WHEN DATEPART(MONTH,@FechaInicioPago) in (7,8) then  DateDiff(day,DATEADD(MONTH,6,@StartYear),EOMONTH( DATEADD(MONTH,7,@StartYear)))+1    
									WHEN DATEPART(MONTH,@FechaInicioPago) in (9,10) then DateDiff(day,DATEADD(MONTH,8,@StartYear),EOMONTH( DATEADD(MONTH,9,@StartYear)))+1    
									WHEN DATEPART(MONTH,@FechaInicioPago) in (11,12) then  DateDiff(day,DATEADD(MONTH,10,@StartYear),EOMONTH( DATEADD(MONTH,11,@StartYear)))+1   
               else 0 END 




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


	-- Se determinan las fechas para el primer y último movimiento de INFONAVIT, limitadas por el rango de fechas de pago.
    -- @FechaMinHistorialMov: Se asigna la menor fecha de la tabla de historial, o la fecha de inicio de pago si la menor fecha es anterior.
    -- @FechaMaxHistorialMov: Se asigna la mayor fecha de historial o de creación del aviso, o la fecha de fin de pago si la mayor fecha es posterior.
    -- Estas fechas se obtienen de la tabla [RH].[tblHistorialInfonavitEmpleado] para los empleados en @dtempleados.
        
    SELECT 
            @FechaMinHistorialMov = CASE WHEN ISNULL(MIN(HIE.Fecha),@FechaInicioPago) < @FechaInicioPago THEN ISNULL(MIN(HIE.Fecha),@FechaInicioPago) 
                                        ELSE @FechaInicioPago 
                                    END 
        ,@FechaMaxHistorialMov = CASE WHEN ISNULL(MAX(HIE.Fecha),@FechaFinPago) < @FechaFinPago THEN @FechaFinPago
                                        ELSE ISNULL(MAX(HIE.Fecha),@FechaFinPago) 
                                    END								
        FROM RH.tblHistorialInfonavitEmpleado HIE WITH(NOLOCK)
            INNER JOIN @dtempleados e 
                on HIE.IDEmpleado  = E.IDEmpleado

    -- Selecciona todos los campos de la tabla de historial de avisos de INFONAVIT por empleado (HIE),
    -- agrega columnas calculadas para la fecha de aplicación y fin de aplicación (ambas con la fecha actual),
    -- el salario integrado del empleado, y columnas adicionales como el factor de descuento y días del bimestre (inicializados en 0).
    -- Inserta los resultados en una tabla temporal (#tempInfonavitHistorialMovimientos).

    
    SELECT
          HIE.* 
		, HIE.Fecha AS FechaAplicacion
		, CAST(GETDATE() AS DATE) AS FechaFinAplicacion
		, E.SalarioIntegrado
		, CAST(0.00 AS DECIMAL(18,2)) FactorDescuento
		, DiasBimestre = 0 
		, Descuento =  CAST(0.00 AS DECIMAL(18,2)) 
		INTO #tempInfonavitHistorialMovimientos
		FROM RH.tblHistorialInfonavitEmpleado HIE WITH(NOLOCK)
			INNER JOIN @dtempleados e 
				on HIE.IDEmpleado  = E.IDEmpleado

    
    -- Actualiza la columna FechaFinAplicacion en la tabla temporal #tempInfonavitHistorialMovimientos.
	-- Si existe un movimiento posterior para el mismo NúmeroCredito y empleado, establece la FechaFinAplicacion
	-- como el día anterior a la FechaAplicacion del siguiente movimiento.
	-- Si no hay un movimiento posterior, asigna '9999-12-31' como la FechaFinAplicacion por defecto.

	UPDATE a
			SET a.FechaFinAplicacion = ISNULL((SELECT TOP 1 DATEADD(DAY,-1,FechaAplicacion) 
											   FROM #tempInfonavitHistorialMovimientos 
											   WHERE NumeroCredito = a.NumeroCredito 
										  	     AND IDEmpleado = A.IDEmpleado
										         AND FechaAplicacion > a.FechaAplicacion
										       ORDER BY FechaAplicacion ASC)
										,'9999-12-31')
	FROM #tempInfonavitHistorialMovimientos a

	-- Inserta en la tabla temporal @dtFechas un rango de fechas que cubre desde @FechaMinHistorialMov hasta @FechaMaxHistorialMov.
	-- Esto se logra generando números secuenciales (rn) y sumándolos a la fecha mínima del historial para obtener cada fecha dentro del rango.
	-- Utiliza las tablas del sistema sys.all_objects para generar una secuencia de números.

	INSERT @dtFechas([Fecha]) 
		SELECT d
		FROM
		(
			SELECT d = DATEADD(DAY, rn - 1, @FechaMinHistorialMov)
			FROM 
			(
			SELECT TOP (DATEDIFF(DAY, @FechaMinHistorialMov, @FechaMaxHistorialMov) +1) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2			
			ORDER BY s1.[object_id]
			) AS x
		) AS y;

        
	-- Inserta en la tabla temporal @dtFechasMesActual un rango de fechas correspondiente al mes actual de pago.
	-- La secuencia de fechas comienza desde el primer día del mes de @FechaInicioPago hasta el último día del mes de @FechaFinPago.
	-- Similar al bloque anterior, se genera una secuencia de números (rn) y se ajustan a las fechas deseadas.

	INSERT INTO @dtFechasMesActual([Fecha]) 
		SELECT d
		FROM
		(
			SELECT d = DATEADD(DAY, rn - 1, DATEADD(month, DATEDIFF(month, 0, @FechaInicioPago), 0))
			FROM 
			(
			SELECT TOP (DATEDIFF(DAY, DATEADD(month, DATEDIFF(month, 0, @FechaInicioPago), 0) , EOMONTH(@FechaFinPago)) +1) 
			rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2			
			ORDER BY s1.[object_id]
			) AS x
		) AS y;

	
	/* Determina la fechas de inicio y fin para buscar las incidencias tomando en cuenta los movimientos afiliatorios del colaborador en el periodo */
	
	BEGIN 
	
		
		IF OBJECT_ID('tempdb..#TempMovimientos') IS NOT NULL DROP TABLE #TempMovimientos;  
				
		-- Inserta en #TempMovimientos los movimientos afiliatorios de los empleados, asignando un número de fila para cada empleado ordenado por la fecha de movimiento en orden descendente.
		-- Se filtran los movimientos para aquellos con fecha menor o igual a @FechaFinIncidencia y excluyendo los de código 'M'.

		SELECT m.*,TipoMovimiento.Codigo, ROW_NUMBER() OVER (PARTITION BY m.IDEmpleado ORDER BY  m.Fecha DESC) AS [Row]  
		INTO #TempMovimientos  
		FROM @dtempleados e  
			JOIN IMSS.tblMovAfiliatorios m on e.IDEmpleado = m.IDEmpleado  
			LEFT JOIN IMSS.tblCatTipoMovimientos TipoMovimiento on m.IDTipoMovimiento = TipoMovimiento.IDTipoMovimiento  
				  AND TipoMovimiento.Codigo <>'M' 
				  AND m.Fecha <= @FechaFinIncidencia  

		-- Elimina de #TempMovimientos todos los movimientos que no sean el más reciente por empleado (mantiene solo la fila con [Row] = 1).
		DELETE FROM #TempMovimientos WHERE [Row] <> 1


		IF OBJECT_ID('tempdb..#TempFechasHabiles') IS NOT NULL DROP TABLE #TempFechasHabiles;  

		
		-- Inserta en #TempFechasHabiles las fechas de inicio y fin de incidencias:
		--  - FechaInicio: Si el movimiento ocurre dentro del rango y su código es 'A' o 'R', usa la fecha del movimiento; de lo contrario, usa @FechaInicioIncidencia.
		--  - FechaFin: Si el movimiento ocurre dentro del rango y su código es 'B', usa la fecha del movimiento; de lo contrario, usa @FechaFinIncidencia.

		SELECT Movimientos.IDEmpleado
			,FechaInicio =CASE  WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'A' OR Movimientos.Codigo = 'R') THEN Movimientos.Fecha				
				ELSE @FechaInicioIncidencia  
				END  
			,FechaFin =CASE WHEN ( Movimientos.Fecha between @FechaInicioIncidencia and @FechaFinIncidencia) AND (Movimientos.Codigo = 'B') THEN Movimientos.Fecha				
				ELSE @FechaFinIncidencia  
				END  
		INTO #TempFechasHabiles
		FROM #TempMovimientos Movimientos

	END;

	-- Genera una cadena con los IDIncidencia que representan ausentismos que afectan el SUA .
	
	-- @AusentimosAfectaSUA almacena esta cadena de incidencias separadas por comas.
	-- La selección incluye:
	--  - Incidencias de la tabla Asistencia.tblCatIncidencias que son ausentismos (EsAusentismo = 1), sin goce de sueldo (GoceSueldo = 0), 
	--    diferentes de 'I' (Incapacidades), y que afectan el SUA (afectaSUA = 1).
	--  - Incidencias con ID 'F' (Falta injustificada) que también afectan el SUA.
	-- La función `STUFF` elimina la primera coma de la cadena generada por `FOR XML PATH('')`.

		SELECT @AusentimosAfectaSUA = STUFF(
                        (   SELECT ',' + CONVERT(NVARCHAR(20), a.IDIncidencia) 
                            FROM ( SELECT IDIncidencia
									FROM Asistencia.tblCatIncidencias
									Where EsAusentismo = 1
									AND GoceSueldo = 0
									and IDIncidencia <> 'I'
									and afectaSUA = 1
									UNION
							  SELECT IDIncidencia
									FROM Asistencia.tblCatIncidencias
									Where IDIncidencia = 'F'  
									and afectaSUA = 1) A
                            FOR xml path('')
                        )
                        , 1
                        , 1
                        , '')
    
	-- Inserta en la tabla temporal @dtVigenciaEmpleado la información sobre la vigencia de los empleados.
	-- Para cada empleado en @dtEmpleados, se combina con todas las fechas de @dtFechas usando CROSS APPLY.
	-- Luego se filtran las fechas que caen entre la FechaInicio y FechaFin de #TempFechasHabiles, 
	-- y se marca cada registro como vigente (valor 1).

	INSERT INTO @dtVigenciaEmpleado(IDEmpleado,Fecha,Vigente)
		SELECT Empleados.IDEmpleado, F.Fecha, 1
		FROM @dtEmpleados Empleados
			Cross Apply @dtFechas F
			inner join #TempFechasHabiles FA
				on FA.IDEmpleado = Empleados.IDEmpleado
		WHERE F.Fecha BETWEEN  FA.FechaInicio  AND FA.FechaFin 	

    
	-- Selecciona información sobre ausentismos e incapacidades de los empleados para la tabla temporal #tempAusentismosIncapacidades.
    -- Para cada empleado en @dtempleados:
    --  - Se obtiene el ID del empleado.
    --  - Se selecciona cada fecha del mes actual usando CROSS APPLY.
    --  - Se llama a la función [Asistencia].[fnBuscarIncidenciasEmpleado] para verificar incidencias de ausentismo en la fecha.    
    --  - Se llama a la función [Asistencia].[fnBuscarIncapacidadEmpleado] para verificar incapacidades en la fecha.
    --  - Se obtiene el código del tipo de jornada laboral del empleado desde la tabla IMSS.tblCatTipoJornada.
    --  - Se inicializa ValorAusentismo a 0.

	SELECT Empleados.IDEmpleado
			,F.Fecha
			,Ausentismo = [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,(@AusentimosAfectaSUA),f.fecha, f.fecha)
			-- ,RNAusentismo = 0
			,Incapacidad = [Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,'1,2,3',F.fecha, F.fecha)
			,TJ.Codigo as IDJornadaLaboral
			-- ,0 as ValorAusentismo
	INTO #tempAusentismosIncapacidades
		FROM @dtempleados Empleados
	INNER JOIN RH.tblEmpleados e
			on e.IDEmpleado = Empleados.IDEmpleado
	LEFT JOIN IMSS.tblCatTipoJornada TJ
				on TJ.IDTipoJornada = e.IDTipoJornada
	-- CROSS APPLY @dtFechasMesActual F	
    CROSS APPLY @dtFechas F
    --- Debe ser por todo el mes o solo por el periodo? No entiendo


	

    
	select 
			 VE.IDEmpleado	
			,VE.Fecha	
			,VE.Vigente
			,IA.IDInfonavitEmpleado
            ,IA.IDHistorialInfonavitEmpleado
			,IA.IDTipoDescuento
			,IA.NumeroCredito
			,IA.ValorDescuento
			,IA.IDTipoMovimiento
			,IA.FechaAplicacion
			,IA.FechaFinAplicacion
			,IA.SalarioIntegrado			
			,FactorDescuento = (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc)
			,SalarioMinimo = (select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <= VE.Fecha order by Fecha desc)
			,FactorDescuentoAnterior = (select top 1 FactorDescuento from nomina.tblSalariosMinimos where Fecha < VE.Fecha order by Fecha desc)
			,SalarioMinimoAnterior = (select top 1 SalarioMinimo from nomina.tblSalariosMinimos where Fecha <  VE.Fecha order by Fecha desc)
			,DiasBimestre = [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
			,Descuento =                CASE WHEN TD.Codigo = '1' THEN  ISNULL(IA.SalarioIntegrado,0) * ( ISNULL(IA.ValorDescuento,0) /100.0 )
										 WHEN TD.Codigo     = '2' THEN (ISNULL(IA.ValorDescuento,0) * 2.0) / [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
										 WHEN TD.Codigo     = '3' THEN (ISNULL(IA.ValorDescuento,0) * ISNULL((SELECT TOP 1 FactorDescuento FROM nomina.tblSalariosMinimos WHERE Fecha <= VE.Fecha ORDER BY Fecha DESC),0) * 2.0) / [Asistencia].[fnGetDiasBimestreByFecha](VE.Fecha)
										 ELSE 0.00
										END			            
			, CAST( AusentismosIncapacidades.Ausentismo as int) as ausentismo			
			, CAST( AusentismosIncapacidades.Incapacidad as int) as Incapacidad
			, CAST( 0 as decimal(18,2)) as DiferenciaAjuste
			, isnull(TJ.Codigo,0) as IDJornadaLaboral			
		into #tempInfonavitHistorialMovimientosCompletos
		from @dtVigenciaEmpleado VE            
			inner join #tempInfonavitHistorialMovimientos IA
				on VE.IDEmpleado = IA.IDEmpleado
				and VE.Fecha between IA.FechaAplicacion and IA.FechaFinAplicacion
            INNER JOIN RH.tblCatInfonavitTipoDescuento TD 
                on TD.IDTipoDescuento = IA.IDTipoDescuento        
			inner join RH.tblEmpleados e
				on VE.IDEmpleado = E.IDEmpleado
			left join IMSS.tblCatTipoJornada TJ
				on TJ.IDTipoJornada = E.IDTipoJornada
			left join #tempAusentismosIncapacidades AusentismosIncapacidades
				on AusentismosIncapacidades.Fecha = ve.Fecha
				and AusentismosIncapacidades.IDEmpleado = ve.IDEmpleado

    --select * from #tempInfonavitHistorialMovimientosCompletos

    delete c
	from  #tempInfonavitHistorialMovimientosCompletos c			
	where c.IDTipoMovimiento = @ID_TIPO_MOVIMIENTO_SUSPENSION

    SELECT 
             ac.IDEmpleado
	       , ac.IDHistorialInfonavitEmpleado
	       , ac.IDJornadaLaboral
           , ac.NumeroCredito  
           , ac.IDInfonavitEmpleado         
	       , SUM(ac.Descuento) totalDescuento
	       , COUNT(*) diasVigentes
	       , SUM(CASE WHEN ac.ausentismo = 0 THEN 0 ELSE 1 END) AS ausentismos
	       , SUM(ac.Incapacidad) AS incapacidades
	       ,(SUM(ac.Descuento)) - (
					CASE WHEN ISNULL(@INFONAVITREFORMA2025,0) = 0 THEN  ((SUM(CASE WHEN ac.ausentismo = 0 THEN 0 ELSE 1 END)*AC.Descuento)+ ((SUM(CASE WHEN ac.Incapacidad = 0 THEN 0 ELSE 1 END)*ac.Descuento))) 
						ELSE 0 
						END
			)	AS DescuentoAplicable	
		into #tempAplicable	
	FROM #tempInfonavitHistorialMovimientosCompletos ac
	where ac.Fecha between @FechaInicioPago and @FechaFinPago
	group by ac.IDEmpleado, ac.IDInfonavitEmpleado ,ac.IDHistorialInfonavitEmpleado, ac.IDJornadaLaboral,ac.NumeroCredito, ac.Descuento
		
    
	    
	IF(@General = 1 Or @Finiquito =1)
	BEGIN
		select TOP 1  @SMGDF = SalarioMinimo, @UMA = UMA , @FactorDescuento = FactorDescuento          
		from Nomina.tblSalariosMinimos          
		WHERE DATEPART(YEAR, Fecha) = @Ejercicio          
		ORDER BY Fecha DESC          
          		
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
					isnull((SELECT SUM(DescuentoAplicable) 
						FROM #tempAplicable
						WHERE IDEmpleado = Empleados.IDEmpleado
						),0)
				END Valor
            ,STUFF((    
				SELECT ', Credito ' + [NumeroCredito] + ': $' + CAST(DescuentoAplicable AS VARCHAR(MAX))     
				FROM #tempAplicable     
				WHERE (IDEmpleado = Empleados.IDEmpleado)     
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')    
				,1,2,'') AS Creditos 
            ,(
                SELECT TOP 1 IDInfonavitEmpleado
                FROM #tempAplicable
                WHERE IDEmpleado = Empleados.IDEmpleado
            )  AS IDInfonavitEmpleado
			,ISNULL(DTLocal.CantidadMonto,0) as CantidadMonto
			,ISNULL(DTLocal.CantidadDias ,0) as CantidadDias
			,ISNULL(DTLocal.CantidadVeces,0) as CantidadVeces  																							 
			,ISNULL(DTLocal.CantidadOtro1,0) as CantidadOtro1  																							 
			,ISNULL(DTLocal.CantidadOtro2,0) as CantidadOtro2  																							 
		INTO #TempValores
		FROM @dtempleados Empleados
			Left Join @dtDetallePeriodoLocal DTLocal
				on Empleados.IDEmpleado = DTLocal.IDEmpleado
			Inner join RH.tblEmpleados e with(nolock)
				on e.IDEmpleado = Empleados.IDEmpleado
			left join IMSS.tblCatTipoJornada TJ
				on TJ.IDTipoJornada = Empleados.IDJornadaLaboral
 
		

		--SELECT * FROM #tempCreditoInfonavitSUM
		MERGE @dtDetallePeriodoLocal AS TARGET          
		USING #TempValores AS SOURCE          
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo          
			and TARGET.IDConcepto = @IDConcepto          
			and TARGET.IDEmpleado = SOURCE.IDEmpleado
			and TARGET.IDReferencia = SOURCE.IDInfonavitEmpleado
		WHEN MATCHED Then          
		update Set               
			TARGET.ImporteTotal1  = SOURCE.Valor          
			,TARGET.ImporteGravado  = 0.00   
			,TARGET.CantidadMonto   = SOURCE.CantidadMonto      
			,TARGET.CantidadDias    = SOURCE.CantidadDias      
			,TARGET.CantidadVeces   = SOURCE.CantidadVeces     
			,TARGET.CantidadOtro1   = SOURCE.CantidadOtro1     
			,TARGET.CantidadOtro2   = SOURCE.CantidadOtro2     
			,TARGET.IDReferencia    = SOURCE.IDInfonavitEmpleado          
			,TARGET.Descripcion     = SOURCE.Creditos          
              
		WHEN NOT MATCHED BY TARGET THEN           
		INSERT(IDEmpleado,IDPeriodo,IDConcepto,ImporteGravado,ImporteTotal1,Descripcion,  			
            CantidadMonto,CantidadDias ,CantidadVeces,CantidadOtro1,CantidadOtro2 , IDReferencia )          
		VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,@IDConcepto,0.00,Source.Valor,SOURCE.Creditos,  			
               SOURCE.CantidadMonto ,SOURCE.CantidadDias  ,SOURCE.CantidadVeces  ,SOURCE.CantidadOtro1  ,SOURCE.CantidadOtro2, SOURCE.IDInfonavitEmpleado)
		WHEN NOT MATCHED BY SOURCE THEN           
		DELETE;          

		
	END ELSE
	IF (@Especial = 1)
	BEGIN
		

		PRINT 0
	END;
 
	Select * from @dtDetallePeriodoLocal  
 	where 
		(isnull(CantidadMonto,0) <> 0 OR		 
		isnull(CantidadDias,0)  <> 0 OR		 
		isnull(CantidadVeces,0) <> 0 OR		 
		isnull(CantidadOtro1,0) <> 0 OR		 
		isnull(CantidadOtro2,0) <> 0 OR		 
		isnull(ImporteGravado,0) <> 0 OR		 
		isnull(ImporteExcento,0) <> 0 OR		 
		isnull(ImporteOtro,0) <> 0 OR		 
		isnull(ImporteTotal1,0) <> 0 OR		 
		isnull(ImporteTotal2,0) <> 0  )  
END;
GO

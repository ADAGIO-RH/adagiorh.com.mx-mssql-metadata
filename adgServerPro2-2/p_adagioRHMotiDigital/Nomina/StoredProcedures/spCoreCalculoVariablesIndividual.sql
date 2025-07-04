USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : Cálculo de Variables por persona   
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-07-22
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Nomina].[spCoreCalculoVariablesIndividual]

(
 
    @IDControlCalculoVariables int,
    @IDEmpleado int  ,
    @IDUsuario int 
)
AS        
BEGIN
        DECLARE 
            @IDCalculoVariablesBimestralesMaster INT = 0;
    IF NOT EXISTS( SELECT 
                         TOP 1 1
                   FROM Nomina.TblCalculoVariablesBimestralesMaster
                   WHERE IDEmpleado = @IDEmpleado AND IDControlCalculoVariables = @IDControlCalculoVariables )  
	BEGIN
        RAISERROR('EL EMPLEADO NO SE ENCUENTRA EN EL CALCULO ',16,1);
        RETURN;
    END
    ELSE
    BEGIN
        SELECT 
               @IDCalculoVariablesBimestralesMaster = IDCalculoVariablesBimestralesMaster
               FROM Nomina.TblCalculoVariablesBimestralesMaster
               WHERE IDEmpleado = @IDEmpleado AND IDControlCalculoVariables = @IDControlCalculoVariables 
    END

    
    DECLARE
        @IDBimestre                                 INT
       ,@Aplicar                                    BIT
       ,@Ejercicio                                  INT
       ,@IDRegPatronal                              INT
        --- CONSTANTES
       ,@VALOR_APLICADO                             BIT = 1


    SELECT
        @IDBimestre     = IDBimestre 
          , @Aplicar        = Aplicar
          , @IDRegPatronal  = IDRegPatronal
          , @Ejercicio      = Ejercicio
    FROM Nomina.tblControlCalculoVariablesBimestrales
    WHERE IDControlCalculoVariables = @IDControlCalculoVariables

    IF @Aplicar = @VALOR_APLICADO
	    BEGIN
        RAISERROR('El cálculo ya ha sido aplicado y no se puede modificar en este estado', 16, 1);
        RETURN;
    END

    DECLARE 
        @ConfigPromediarUMA                         INT = 0
       ,@ConfigCriterioDiasVales                    INT = 0 
       ,@ConfigTopeVales                            INT = 0
       ,@ConfigCriterioCambioSDI                    INT = 0
       ,@ConfigCriterioBajaReingreso                INT = 0
       ,@FechaInicioBimestre                        DATE  
	   ,@FechaFinBimestre                           DATE  
       ,@SalarioMinimo                              DECIMAL(18,2)
       ,@UMABimestre                                DECIMAL(18,2)
	   ,@UMA                                        DECIMAL(18,2)
       ,@DiasBimestre                               INT		
	   ,@DescripcionBimestre                        VARCHAR(MAX)
       ,@TopeValesBimestral                         DECIMAL(18,2)
        --- CONSTANTES
       ,@CONFIG_UMA_CORRESPONDIENTE_MES_BIMESTRE   INT = 1 --- UMA CORRESPONDIENTE A CADA MES DEL BIMESTRE
       ,@CONFIG_ULTIMA_UMA_BIMESTRE                INT = 2 --- ULTIMA UMA DEL BIMESTRE
       ,@CONFIG_PROMEDIO_UMA_BIMESTRE              INT = 3 --- PROMEDIO DE UMA DEL BIMESTRE
                     
       ,@CRITERIO_DIAS_TRABAJADOR_TOPE_VALES       INT = 1
       ,@CRITERIO_DIAS_BIMESTRE_TOPE_VALES         INT = 2
       
       ,@CRITERIO_DIAS_TOPE_VALES                  VARCHAR(30) = 'CriterioDiasTopeVales'
       ,@CRITERIO_TOPE_VALES                       VARCHAR(30) = 'CriterioTopeVales'
       ,@CRITERIO_CAMBIO_SDI                       VARCHAR(30) = 'CriterioCambioSDI'
       ,@CRITERIO_BAJA_REINGRESO                   VARCHAR(30) = 'CriterioBajaReingreso'
	   
	   ;
    




    IF OBJECT_ID('tempdb..#tempMovPrevios') IS NOT NULL DROP TABLE #tempMovPrevios
    IF OBJECT_ID('tempdb..#tempData2') IS NOT NULL DROP TABLE #tempData2
    IF OBJECT_ID('tempdb..#tempData') IS NOT NULL DROP TABLE #tempData
    IF OBJECT_ID('tempdb..#tempcalc') IS NOT NULL DROP TABLE #tempcalc
    IF OBJECT_ID('tempdb..#tempDone') IS NOT NULL DROP TABLE #tempDone
    IF OBJECT_ID('tempdb..#tempMovBajas') IS NOT NULL DROP TABLE #tempMovBajas

    DECLARE @ConfiguracionesBimestre as TABLE (
        IDBimestre int,
        IDMes int,
        UMA Decimal(18,2),
        SalarioMinimo Decimal(18,2),
        IniMes date,
        FinMes date
	    )

    SELECT
        TOP 1
        @ConfigPromediarUMA = isnull(PromediarUMA,1)
    FROM Nomina.tblConfigReporteVariablesBimestrales WITH(NOLOCK)
    
    SELECT 
           TOP 1 @ConfigCriterioDiasVales = CAST(VALOR AS INT)           
    FROM Nomina.tblConfiguracionNomina
    WHERE Configuracion = @CRITERIO_DIAS_TOPE_VALES
    
    
    SELECT 
           TOP 1 @ConfigTopeVales = CAST(VALOR AS INT)           
    FROM Nomina.tblConfiguracionNomina
    WHERE Configuracion = @CRITERIO_TOPE_VALES

    SELECT 
           TOP 1 @ConfigCriterioCambioSDI = CAST(VALOR AS INT)           
    FROM Nomina.tblConfiguracionNomina
    WHERE Configuracion = @CRITERIO_CAMBIO_SDI

	SELECT 
           TOP 1 @ConfigCriterioBajaReingreso = CAST(ISNULL(VALOR,'0') AS INT)           
    FROM Nomina.tblConfiguracionNomina
    WHERE Configuracion = @CRITERIO_BAJA_REINGRESO


    

    INSERT INTO @ConfiguracionesBimestre
    SELECT
        @IDBimestre 
		     , item
		     , (    
                    SELECT
                             TOP 1 UMA
                    FROM Nomina.tblSalariosMinimos WITH(NOLOCK)
                    WHERE Fecha <= DATEADD(DAY,-1,DATEADD(MONTH,CAST(item AS INT),DATEADD(YEAR,@Ejercicio-1900,0)))
                    ORDER BY Fecha DESC
                )
		     , (
                    SELECT
                        TOP 1 SalarioMinimo

                    FROM Nomina.tblSalariosMinimos WITH(NOLOCK)
                    WHERE Fecha <= DATEADD(DAY,-1,DATEADD(MONTH,CAST(item AS INT),DATEADD(YEAR,@Ejercicio-1900,0)))
                    ORDER BY Fecha DESC
               )
		     , (DATEADD(MONTH,CAST(item AS INT)-1,DATEADD(YEAR,@Ejercicio-1900,0)))   
		     , DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0)))
    FROM app.Split(
                       ( SELECT
            TOP 1
            meses
        FROM Nomina.tblCatBimestres WITH (NOLOCK)
        WHERE IDBimestre = @IDBimestre
                       )
                  ,',')

    SELECT
          @FechaInicioBimestre = MIN(DATEADD(MONTH,IDMes-1,DATEADD(YEAR,@Ejercicio-1900,0)))
    FROM Nomina.tblCatMeses WITH (NOLOCK)
    WHERE CAST(IDMes AS VARCHAR) IN (SELECT item
    FROM app.Split( (SELECT TOP 1
            meses
        FROM Nomina.tblCatBimestres WITH (NOLOCK)
        WHERE IDBimestre = @IDBimestre),','))

    SET @FechaFinBimestre = [Asistencia].[fnGetFechaFinBimestre](@FechaInicioBimestre)

    SET @DiasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) + 1

    SELECT
        @DescripcionBimestre = Descripcion
    FROM Nomina.tblCatBimestres WITH (NOLOCK)
    WHERE IDBimestre = @IDBimestre

    IF(@ConfigPromediarUMA = @CONFIG_ULTIMA_UMA_BIMESTRE)
	    BEGIN
        UPDATE @ConfiguracionesBimestre
		    SET UMA = (SELECT TOP 1
            UMA
        FROM Nomina.tblSalariosMinimos WITH(NOLOCK)
        WHERE Fecha <= @FechaFinBimestre
        order by Fecha desc)
    END


    IF(@ConfigPromediarUMA = @CONFIG_PROMEDIO_UMA_BIMESTRE)
	    BEGIN

        SELECT @UMA =  ( SELECT AVG(UMA) UMA
            FROM (
							        SELECT f.FinMes,
                    ( SELECT
                        TOP 1
                        UMA
                    FROM Nomina.tblSalariosMinimos WITH (NOLOCK)
                    WHERE Fecha <= f.FinMes
                    ORDER BY Fecha DESC
                                           ) UMA
                FROM @ConfiguracionesBimestre f
						          ) AS info
                            )

        UPDATE @ConfiguracionesBimestre
		    SET UMA =  @UMA

    END


    SELECT TOP 1
            @UMABimestre=UMA
        FROM  @ConfiguracionesBimestre        
        order by IDMes desc
    
    SET @TopeValesBimestral= (@UMABimestre * @DiasBimestre) * 0.40


    SELECT
        [d].[IDBimestre],
        [d].[IDMes],
        [d].[UMA],
        [d].[SalarioMinimo],
        [d].[IniMes],
        [d].[FinMes],
        [e].[IDEmpleado],
        ( 
                SELECT
                    TOP 1
                    IDMovAfiliatorio
                FROM IMSS.tblMovAfiliatorios M WITH(NOLOCK)
                WHERE E.IDEmpleado = M.IDEmpleado
                    AND M.IDTipoMovimiento IN (SELECT IDTipoMovimiento
												FROM IMSS.tblCatTipoMovimientos
												WHERE Codigo <> 'B')
                    AND (( m.Fecha >= e.FechaAntiguedad and isnull(@ConfigCriterioBajaReingreso,0) = 0) or (@ConfigCriterioBajaReingreso = 1) )
                    AND m.Fecha <= d.FinMes
                    AND m.IDRegPatronal    = @IDRegPatronal
                ORDER BY m.Fecha DESC

        ) AS [IDMovAfiliatorio]
    INTO #tempMovPrevios
    FROM RH.tblEmpleados E
		CROSS APPLY @ConfiguracionesBimestre d
    WHERE E.IDEmpleado = @IDEmpleado

    SELECT
        -- ,DatosEmpleado.ClaveEmpleado  
        -- ,DatosEmpleado.NOMBRECOMPLETO  
        -- ,DatosEmpleado.Departamento  
        -- ,DatosEmpleado.Sucursal  
        -- ,DatosEmpleado.Puesto  
        -- ,DatosEmpleado.IDRegPatronal  
        -- ,DatosEmpleado.RegPatronal  
          e.IDCalculoVariablesBimestralesMaster                                                                                          AS [IDCalculoVariablesBimestralesMaster]
        , e.IDControlCalculoVariables                                                                                                    AS [IDControlCalculoVariables]           
        , e.IDEmpleado                                                                                                                   AS [IDEmpleado]		
		, CAST(mov.SalarioDiario     AS DECIMAL(10,2))                                                                                   AS [AnteriorSalarioDiario]
		, CAST(mov.SalarioVariable   AS DECIMAL(10,2))                                                                                   AS [AnteriorSalarioVariable]
		, CAST(mov.SalarioIntegrado  AS DECIMAL(10,2))                                                                                   AS [AnteriorSalarioIntegrado]
        , CAST(mov.SalarioDiarioReal AS DECIMAL(10,2))                                                                                   AS [AnteriorSalarioDiarioReal]
		, mov.Fecha                                                                                                                      AS [FechaMov]
		, e.FechaAntiguedad                                                                                                              AS [FechaAntiguedad]
		, vb.IDConfiguracionVariablesbimestrales                                                                                         AS [IDConfiguracionVariablesbimestrales]
        , vb.ConceptosValesDespensa                                                                                                      AS [ConceptosValesDespensa]
        , vb.ConceptosPremioPuntualidad                                                                                                  AS [ConceptosPremioPuntualidad]
        , vb.ConceptosPremioAsistencia                                                                                                   AS [ConceptosPremioAsistencia]
        , vb.ConceptosHorasExtrasDobles                                                                                                  AS [ConceptosHorasExtrasDobles]
        , vb.ConceptosIntegrablesVariables                                                                                               AS [ConceptosIntegrablesVariables]
        , vb.ConceptosDias                                                                                                               AS [ConceptosDias]
        , vb.IDRazonMovimiento                                                                                                           AS [IDRazonMovimiento]
        , vb.CriterioDias                                                                                                                AS [CriterioDias]
        , vb.PromediarUMA                                                                                                                AS [PromediarUMA]
        , vb.TopePremioPuntualidadAsistencia                                                                                             AS [TopePremioPuntualidadAsistencia]
		, temp.IDBimestre                                                                                                                AS [IDBimestre]
		, temp.UMA                                                                                                                       AS [UMA]
		, temp.SalarioMinimo                                                                                                             AS [SalarioMinimo]
		, temp.IDMes                                                                                                                     AS [IDMes]
		, temp.IniMes                                                                                                                    AS [IniMes]
		, temp.FinMes                                                                                                                    AS [FinMes]
        , temp.IDMovAfiliatorio                                                                                                          AS [IDMovAfiliatorio]
		, (
            SELECT
                MIN(Factor)
            FROM [RH].[tblCatTiposPrestacionesDetalle] WITH (NOLOCK)
            WHERE IDTipoPrestacion = UltimaPrestacionBimestre.IDTipoPrestacion               
              --AND Antiguedad       = CEILING([Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,temp.FinMes))
                AND Antiguedad     = ISNULL(FLOOR(DATEDIFF(day,e.FechaAntiguedad,temp.FinMes)/365.25),0)+1                
        )                                                                                                                               AS [Factor]
		, DetallePrestacionUltimoMov.Factor                                                                                             AS [FactorAntiguo]
		, CEILING([Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,temp.FinMes))                                                AS [AniosPrestacion]
		, ISNULL(
                ( 
                  SELECT
                        CAST( SUM(Importetotal1) AS DECIMAL(18,2) )
                    FROM Nomina.tblDetallePeriodo   dp WITH (NOLOCK)
                       INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK)
                       ON  dp.IDPeriodo = p.IDPeriodo
                           AND p.Ejercicio  = @Ejercicio
                           AND p.IDMes      = temp.IDMes
                           AND p.Cerrado    = 1
                       INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
                       ON hep.IDEmpleado    = e.IDEmpleado
                           AND hep.IDPeriodo     = p.IDPeriodo
                           AND hep.IDRegPatronal = @IDRegPatronal
                    WHERE dp.IDEmpleado = e.IDEmpleado
                       AND dp.IDConcepto IN (SELECT item FROM app.Split(vb.ConceptosValesDespensa,','))                       
                )
             ,0)                                                                                                                        AS [Vales]
		, ISNULL(
                ( 
                  SELECT
                       CAST( SUM(Importetotal1) AS DECIMAL(18,2) )
                  FROM Nomina.tblDetallePeriodo   dp WITH (NOLOCK)
                      INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK)
                      ON  dp.IDPeriodo = p.IDPeriodo
                          AND p.Ejercicio  = @Ejercicio
                          AND p.IDMes      = temp.IDMes
                          AND p.Cerrado    = 1
                      INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
                      ON hep.IDEmpleado    = e.IDEmpleado
                          AND hep.IDPeriodo     = p.IDPeriodo
                          AND hep.IDRegPatronal = @IDRegPatronal
                  WHERE dp.IDEmpleado = e.IDEmpleado
                      AND dp.IDConcepto IN (SELECT item FROM app.Split(vb.ConceptosPremioPuntualidad,','))                      
                ) 
            ,0)                                                                                                                         AS [PremioPuntualidad]
		, ISNULL(
                    ( 
                      SELECT
                            CAST( SUM(Importetotal1) AS DECIMAL(18,2) )
                      FROM Nomina.tblDetallePeriodo   dp WITH (NOLOCK)
                          INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK)
                          ON dp.IDPeriodo = p.IDPeriodo
                              AND p.Ejercicio  = @Ejercicio
                              AND p.IDMes      = temp.IDMes
                              AND p.Cerrado    = 1
                          INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
                          ON hep.IDEmpleado    = e.IDEmpleado
                              AND hep.IDPeriodo     = p.IDPeriodo
                              AND hep.IDRegPatronal = @IDRegPatronal
                      WHERE dp.IDEmpleado = e.IDEmpleado
                          AND dp.IDConcepto IN (SELECT item FROM app.Split(vb.ConceptosPremioAsistencia,','))                           
                    )
              ,0)                                                                                                                       AS [PremioAsistencia]            
		, CASE WHEN ISNULL(
                            (
                              SELECT
                                   CAST( SUM(dp.ImporteGravado) AS DECIMAL(18,2) )
                              FROM Nomina.tblDetallePeriodo dp WITH (NOLOCK)
                                  INNER JOIN Nomina.tblCatPeriodos p with (nolock)
                                  ON dp.IDPeriodo = p.IDPeriodo
                                      AND p.Ejercicio  = @Ejercicio
                                      AND p.IDMes      =  temp.IDMes
                                      AND p.Cerrado    = 1
                                  INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
                                  ON hep.IDEmpleado = e.IDEmpleado
                                      AND hep.IDPeriodo = p.IDPeriodo
                                      AND hep.IDRegPatronal = @IDRegPatronal
                              WHERE dp.IDEmpleado = e.IDEmpleado
                                  AND dp.IDConcepto IN ( SELECT item FROM app.Split(vb.ConceptosHorasExtrasDobles,',') )                                   
                            )
                       ,0 ) <= ( ( mov.SalarioDiario /  8.0 ) * 2.0 ) * 72.0
			   THEN 0.00
			   ELSE ISNULL(
                            (
                              SELECT
                                    CAST( SUM(ImporteGravado) AS DECIMAL(18,2) )
                              FROM Nomina.tblDetallePeriodo dp   WITH (NOLOCK)
                                  INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK)
                                  ON dp.IDPeriodo = p.IDPeriodo
                                      AND p.Ejercicio  = @Ejercicio
                                      AND p.IDMes      = temp.IDMes
                                      AND p.Cerrado    = 1
                                  INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH (NOLOCK)
                                  ON hep.IDEmpleado    = e.IDEmpleado
                                      AND hep.IDPeriodo     = p.IDPeriodo
                                      AND hep.IDRegPatronal = @IDRegPatronal
                              WHERE dp.IDEmpleado = e.IDEmpleado
                                  AND dp.IDConcepto IN ( SELECT item FROM app.Split(vb.ConceptosHorasExtrasDobles,',') )                                   
                            )
                        ,0) - ( ( mov.SalarioDiario /  8.0 ) * 2.0 ) * 72.0
				END                                                                                                                     AS [HorasExtrasDobles]  				                            
		, ISNULL(
                ( 
                  SELECT
                        CAST( SUM( Importetotal1 ) AS DECIMAL(18,2) )
                  FROM Nomina.tblDetallePeriodo dp   WITH (NOLOCK)
                      INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK)
                      ON dp.IDPeriodo = p.IDPeriodo
                          AND p.Ejercicio  = @Ejercicio
                          AND p.IDMes      =  temp.IDMes
                          AND p.Cerrado    = 1
                      INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
                      ON hep.IDEmpleado    = e.IDEmpleado
                          AND hep.IDPeriodo     = p.IDPeriodo
                          AND hep.IDRegPatronal = @IDRegPatronal
                  WHERE dp.IDEmpleado = e.IDEmpleado
                      AND dp.IDConcepto IN ( SELECT item FROM app.Split(vb.ConceptosIntegrablesVariables,',') )                       
                )
            ,0)                                                                                                                         AS [IntegrablesVariables]  								                            
		, ISNULL(
                (
                  SELECT
                        CAST( SUM(Importetotal1) AS DECIMAL(18,2) )
                  FROM Nomina.tblDetallePeriodo dp   WITH (NOLOCK)
                      INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK)
                      ON dp.IDPeriodo = p.IDPeriodo
                          AND p.Ejercicio  = @Ejercicio
                          AND p.IDMes      = temp.IDMes
                          AND p.Cerrado    = 1
                      INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
                      ON hep.IDEmpleado    = e.IDEmpleado
                          AND hep.IDPeriodo     = p.IDPeriodo
                          AND hep.IDRegPatronal = @IDRegPatronal
                  WHERE dp.IDEmpleado = e.IDEmpleado
                    AND dp.IDConcepto IN ( SELECT item FROM app.Split(vb.ConceptosDias,',')) 
                )
            ,0)                                                                                                                         AS [Dias]              
	    , CASE WHEN E.FechaAntiguedad > temp.IniMes THEN DATEDIFF( DAY, E.FechaAntiguedad, temp.FinMes) + 1  
              ELSE DATEDIFF(DAY, temp.IniMes, temp.FinMes) + 1 
         END                                                                                                                            AS [DiasMes]
    INTO #tempData
    FROM Nomina.TblCalculoVariablesBimestralesMaster e
        LEFT JOIN #tempMovPrevios temp
               ON temp.IDEmpleado = e.IDEmpleado
        INNER JOIN IMSS.tblMovAfiliatorios mov WITH(NOLOCK)
               ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio
        LEFT JOIN RH.tblPrestacionesEmpleado PrestacionUltimoMov WITH(NOLOCK)
               ON E.IDEmpleado = PrestacionUltimoMov.IDEmpleado
              AND PrestacionUltimoMov.FechaIni<= mov.Fecha
              AND PrestacionUltimoMov.FechaFin >= mov.Fecha
        LEFT JOIN RH.tblCatTiposPrestacionesDetalle DetallePrestacionUltimoMov WITH(NOLOCK)
               ON PrestacionUltimoMov.IDTipoPrestacion  = DetallePrestacionUltimoMov.IDTipoPrestacion
            -- AND DetallePrestacionUltimoMov.Antiguedad = CEILING( [Asistencia].[fnBuscarAniosDiferencia](e.FechaAntiguedad,mov.Fecha) ) 
              AND DetallePrestacionUltimoMov.Antiguedad = ISNULL(FLOOR(DATEDIFF(day,[IMSS].[fnObtenerFechaAntiguedad](E.IDEmpleado, MOV.IDMovAfiliatorio), MOV.Fecha)/365.25),0)+1
        LEFT JOIN RH.tblPrestacionesEmpleado UltimaPrestacionBimestre WITH(NOLOCK)
               ON E.IDEmpleado = UltimaPrestacionBimestre.IDEmpleado
              AND UltimaPrestacionBimestre.FechaIni<= @FechaFinBimestre
              AND UltimaPrestacionBimestre.FechaFin >= @FechaFinBimestre        
        CROSS JOIN Nomina.tblConfigReporteVariablesBimestrales vb WITH (NOLOCK)
    WHERE e.IDEmpleado                = @IDEmpleado
      AND e.IDControlCalculoVariables = @IDControlCalculoVariables
	  

      IF NOT EXISTS( SELECT TOP 1 1 FROM #tempData)  
	  BEGIN
        RAISERROR('El colaborador no cuenta con la información necesaria para calcularse',16,1);
        RETURN;
      END
    

    /*SE PONE ESTE BLOQUE PARA SALARIOS A LA BAJA, YA QUE ANTERIORMENTE TRAIAMOS EL MAX SALARIO QUE NO NECESARIAMENTE ERA EL DEL ULTIMO MOV AFILIATORIO*/

    DECLARE 
            @AnteriorSalarioDiario       DECIMAL(18,2)
           ,@AnteriorSalarioVariable     DECIMAL(18,2)
           ,@AnteriorSalarioIntegrado    DECIMAL(18,2)
           ,@AnteriorSalarioDiarioReal   DECIMAL(18,2)


    SELECT TOP 1 
                @AnteriorSalarioDiario      = SalarioDiario
               ,@AnteriorSalarioVariable    = SalarioVariable
               ,@AnteriorSalarioIntegrado   = SalarioIntegrado
               ,@AnteriorSalarioDiarioReal  = SalarioDiarioReal
    FROM #tempMovPrevios MovPrevios
        INNER JOIN IMSS.tblMovAfiliatorios Movs
                ON Movs.IDMovAfiliatorio = MovPrevios.IDMovAfiliatorio
    ORDER BY IDMes DESC

    
    

    SELECT
             m.IDEmpleado 		                                               AS [IDEmpleado] 
           , m.IDCalculoVariablesBimestralesMaster                             AS [IDCalculoVariablesBimestralesMaster]
           , m.IDControlCalculoVariables                                       AS [IDControlCalculoVariables]
		--    , CAST( MAX( m.AnteriorSalarioDiario )     AS DECIMAL(18,2))        AS [AnteriorSalarioDiario]
		--    , CAST( MAX( m.AnteriorSalarioVariable )   AS DECIMAL(18,2))        AS [AnteriorSalarioVariable]
		--    , CAST( MAX( m.AnteriorSalarioIntegrado )  AS DECIMAL(18,2))        AS [AnteriorSalarioIntegrado]
        --    , CAST( MAX( m.AnteriorSalarioDiarioReal ) AS DECIMAL(18,2))        AS [AnteriorSalarioDiarioReal]
           , CAST( @AnteriorSalarioDiario     AS DECIMAL(18,2))                AS [AnteriorSalarioDiario]
		   , CAST( @AnteriorSalarioVariable   AS DECIMAL(18,2))                AS [AnteriorSalarioVariable]
		   , CAST( @AnteriorSalarioIntegrado  AS DECIMAL(18,2))                AS [AnteriorSalarioIntegrado]
           , CAST( @AnteriorSalarioDiarioReal AS DECIMAL(18,2))                AS [AnteriorSalarioDiarioReal]
		   , MAX( m.Factor )                                                   AS [Factor]
		   , MIN( m.FactorAntiguo )                                            AS [FactorAntiguo]
		   , MIN( m.FechaAntiguedad )                                          AS [FechaAntiguedad]
		   , MAX( m.AniosPrestacion )                                          AS [AniosPrestacion]
		   , SUM( ValesDespensa )                                              AS [ValesDespensa]
		   , SUM( TopeVales )                                                  AS [TopeVales]
		   , SUM( ConceptosValesDespensa )                                     AS [ConceptosValesDespensa]
		   , SUM( ConceptosPremioPuntualidad )                                 AS [ConceptosPremioPuntualidad]
		   , SUM( ConceptosPremioAsistencia )                                  AS [ConceptosPremioAsistencia]
		   , SUM( HorasExtrasDobles )                                          AS [HorasExtrasDobles]
		   , SUM( IntegrablesVariables )                                       AS [IntegrablesVariables]
		   , MAX( ConceptosDias )                                              AS [ConceptosDias]
		   , MAX(IDRazonMovimiento)                                            AS [IDRazonMovimiento]
		   , CriterioDias                                                      AS [CriterioDias]
		   , SUM( Dias )                                                       AS [Dias]
		   , SUM( DiasMes )                                                    AS [DiasMes]
		   , MAX( UMA )                                                        AS [UMA]
		   , MAX( SalarioMinimo )                                              AS [SalarioMinimo]
		   , MAX( FechaMov )                                                   AS [FechaMov]
    INTO #tempcalc
    FROM (
		SELECT
              IDEmpleado                                                                                AS [IDEmpleado] 			
            , IDCalculoVariablesBimestralesMaster                                                       AS [IDCalculoVariablesBimestralesMaster]
            , IDControlCalculoVariables                                                                 AS [IDControlCalculoVariables]           
			, AnteriorSalarioDiario                                                                     AS [AnteriorSalarioDiario]
			, AnteriorSalarioVariable                                                                   AS [AnteriorSalarioVariable]
			, AnteriorSalarioIntegrado                                                                  AS [AnteriorSalarioIntegrado]
            , AnteriorSalarioDiarioReal                                                                 AS [AnteriorSalarioDiarioReal]
			, Factor                                                                                    AS [Factor]
			, FactorAntiguo                                                                             AS [FactorAntiguo]
			, FechaAntiguedad                                                                           AS [FechaAntiguedad]
			, AniosPrestacion                                                                           AS [AniosPrestacion]
			, FechaMov                                                                                  AS [FechaMov]
			, IDMes                                                                                     AS [IDMes]
			, Vales                                                                                     AS [ValesDespensa]
			, ( ( UMA * (
                         CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                              WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN DiasMes
                              ELSE  CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END
                              END
                        )
                ) * 0.40 )                                                                              AS [TopeVales]
			, CASE WHEN Vales > ( ( UMA * (
                                            CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                                                 WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES THEN DiasMes
                                                 ELSE  CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END
                                                 END
                                          )
                                  ) * 0.40                                   
                                ) 
                    THEN Vales - ( ( UMA * (
                                            CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                                                 WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES THEN DiasMes
                                                 ELSE  CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END
                                                 END
                                          )
                                  ) * 0.40                                   
                                ) 		
                    ELSE 0 END                                                                            AS [ConceptosValesDespensa]    
			, CASE WHEN PremioPuntualidad > ( ( ( CASE WHEN ISNULL( TopePremioPuntualidadAsistencia,1 ) = 1 THEN AnteriorSalarioDiario ELSE AnteriorSalarioIntegrado END ) * CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END ) * 0.10 ) THEN PremioPuntualidad - ( ( ( CASE WHEN ISNULL( TopePremioPuntualidadAsistencia,1 ) = 1 THEN AnteriorSalarioDiario ELSE AnteriorSalarioIntegrado END ) * CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END ) * 0.10 )  						
                  ELSE 0 END                                                                            AS [ConceptosPremioPuntualidad]  
    
			, CASE WHEN PremioAsistencia > ( ( ( CASE WHEN ISNULL( TopePremioPuntualidadAsistencia,1 ) = 1 THEN AnteriorSalarioDiario ELSE AnteriorSalarioIntegrado END ) * CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END ) * 0.10 ) THEN PremioAsistencia - ( ( ( CASE WHEN ISNULL( TopePremioPuntualidadAsistencia,1 ) = 1 THEN AnteriorSalarioDiario ELSE AnteriorSalarioIntegrado END ) * CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END ) * 0.10 )  
				ELSE 0 END                                                                              AS [ConceptosPremioAsistencia]    
			, HorasExtrasDobles                                                                         AS [HorasExtrasDobles]
			, IntegrablesVariables                                                                      AS [IntegrablesVariables]
			, ConceptosDias                                                                             AS [ConceptosDias]  
			, IDRazonMovimiento                                                                         AS [IDRazonMovimiento]
			, CriterioDias                                                                              AS [CriterioDias]
			, Dias                                                                                      AS [Dias]  
			, DiasMes                                                                                   AS [DiasMes]
			, UMA                                                                                       AS [UMA]
			, SalarioMinimo                                                                             AS [SalarioMinimo]
        FROM #tempData
        WHERE ( CASE WHEN CriterioDias = 0 and ISNULL( Dias ,0) > 0 THEN ISNULL( Dias ,0) ELSE ISNULL( DiasMes ,0) END) > 0
	) M
    GROUP BY m.IDEmpleado,IDCalculoVariablesBimestralesMaster,IDControlCalculoVariables ,m.CriterioDias




   
    IF(ISNULL(@ConfigTopeVales,0) = 1)
    BEGIN
    
    UPDATE #tempcalc
		SET ConceptosValesDespensa = CASE WHEN  ValesDespensa > @TopeValesBimestral THEN ValesDespensa - @TopeValesBimestral ELSE 0 END

    END
    ELSE IF(ISNULL(@ConfigTopeVales,0) = 2)
    BEGIN
        UPDATE #tempcalc
		SET ConceptosValesDespensa = CASE WHEN  ValesDespensa > (@UMABimestre *
                                                  (CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                                                       WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN DiasMes
                                                       ELSE  CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END END )*.40)
                                                       THEN ValesDespensa - (@UMABimestre *
                                                  (CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                                                       WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN DiasMes
                                                       ELSE  CASE WHEN CriterioDias = 0 THEN Dias ELSE DiasMes END END )*.40)
                                                        ELSE 0 END
    END
    ELSE
    BEGIN
        UPDATE #tempcalc
		    SET ConceptosValesDespensa = CASE WHEN  ValesDespensa > TopeVales THEN ConceptosValesDespensa ELSE 0 END
    END


    

    ---select TopeVales,@ConfigCriterioDiasVales from #tempcalc

    SELECT
           c.IDEmpleado                                                                                                                  AS [IDEmpleado]  	
         , IDCalculoVariablesBimestralesMaster                                                                                           AS [IDCalculoVariablesBimestralesMaster]
         , IDControlCalculoVariables                                                                                                     AS [IDControlCalculoVariables]           		 
		 , c.FechaAntiguedad                                                                                                             AS [FechaAntiguedad]
		 , 0                                                                                                                             AS [VariableCambio]
		 , c.Factor                                                                                                                      AS [NuevoFactor]
		 , c.FactorAntiguo                                                                                                               AS [FactorAntiguo]
		 , 0                                                                                                                             AS [FactorCambio]
		 , 0                                                                                                                             AS [IntegradoCambio]
		 , c.aniosPrestacion                                                                                                             AS [aniosPrestacion]
		 , CAST( c.AnteriorSalarioDiario    AS DECIMAL(18,2) )                                                                           AS [AnteriorSalarioDiario]
         , CAST( c.AnteriorSalarioIntegrado AS DECIMAL(18,2) )                                                                           AS [AnteriorSalarioIntegrado]
         , CAST( c.AnteriorSalarioVariable  AS DECIMAL(18,2) )                                                                           AS [AnteriorSalarioVariable]
         , CAST( c.AnteriorSalarioDiarioReal  AS DECIMAL(18,2) )                                                                         AS [AnteriorSalarioDiarioReal]
         , CAST( c.AnteriorSalarioDiario    AS DECIMAL(18,2) )                                                                           AS [SalarioDiario]
         , CAST( c.AnteriorSalarioDiarioReal  AS DECIMAL(18,2) )                                                                         AS [SalarioDiarioReal]
		 , 0                                                                                                                             AS [Afectar]
		 , CAST( CASE WHEN  ( 
                              (  
                                ISNULL( c.ConceptosValesDespensa     ,0) 
                              + ISNULL( c.ConceptosPremioPuntualidad ,0) 
                              + ISNULL( c.ConceptosPremioAsistencia  ,0)  
			                  + ISNULL( c.HorasExtrasDobles          ,0)
                              + ISNULL( c.IntegrablesVariables       ,0)
                              )
                            ) = 0 THEN 0 
                      ELSE  (
                              (
                                ISNULL( c.ConceptosValesDespensa     ,0)
                              + ISNULL( c.ConceptosPremioPuntualidad ,0)
                              + ISNULL( c.ConceptosPremioAsistencia  ,0)  
			                  + ISNULL( c.HorasExtrasDobles          ,0)
                              + ISNULL( c.IntegrablesVariables       ,0)
                              ) / CASE WHEN (c.CriterioDias = 0 AND c.Dias > 0) THEN c.Dias ELSE c.DiasMes END  
			                ) 
                 END AS DECIMAL(18,2)                		 
                )                                                                                                                        AS [SalarioVariable]  
  	     , CASE WHEN ( c.CriterioDias = 0 AND ISNULL( c.Dias ,0) > 0 ) THEN c.Dias ELSE c.DiasMes END                                    AS [Dias]
	     , CAST( CASE WHEN ( ( c.AnteriorSalarioDiario * c.Factor ) 
                            + CASE WHEN ( 
                                          (
                                              ISNULL( c.ConceptosValesDespensa     ,0)
                                            + ISNULL( c.ConceptosPremioPuntualidad ,0)
                                            + ISNULL( c.ConceptosPremioAsistencia  ,0) 
                                            + ISNULL( c.HorasExtrasDobles          ,0)
                                            + ISNULL( c.IntegrablesVariables       ,0)
                                          )
			                            ) = 0 THEN 0 
			                       ELSE (
                                         (
                                              ISNULL( c.ConceptosValesDespensa     ,0)
                                            + ISNULL( c.ConceptosPremioPuntualidad ,0)
                                            + ISNULL( c.ConceptosPremioAsistencia  ,0)   
			                                + ISNULL( c.HorasExtrasDobles          ,0)
                                            + ISNULL( c.IntegrablesVariables       ,0)
                                         ) / CASE WHEN (c.CriterioDias = 0 AND c.Dias > 0) THEN c.Dias ELSE c.DiasMes END  
			                            )    
		                       END 
                           ) >= UMA * 25 THEN ( UMA * 25 )
		              ELSE (c.AnteriorSalarioDiario * c.Factor) + 			
			                CASE WHEN (
                                        (
                                            ISNULL( c.ConceptosValesDespensa     ,0)
                                          + ISNULL( c.ConceptosPremioPuntualidad ,0)
                                          + ISNULL( c.ConceptosPremioAsistencia  ,0)
                                          + ISNULL( c.HorasExtrasDobles          ,0)
                                          + ISNULL( c.IntegrablesVariables       ,0)
                                        )
                                      ) = 0 THEN 0 
			                     ELSE (
                                        (
                                            ISNULL( c.ConceptosValesDespensa       ,0)
                                          + ISNULL( c.ConceptosPremioPuntualidad   ,0)
                                          + ISNULL( c.ConceptosPremioAsistencia    ,0)  
			                              + ISNULL( c.HorasExtrasDobles            ,0)
                                          + isnull( c.IntegrablesVariables         ,0)
                                        ) / CASE WHEN (c.CriterioDias = 0 AND c.Dias > 0) THEN c.Dias ELSE c.DiasMes END  
                                      ) 
   
		                    END 
		         END  AS DECIMAL(18,2)  	     
              )                                                                                                                          AS [SalarioIntegrado]		
		 , c.IDRazonMovimiento                                                                                                            AS [IDRazonMovimiento]  
		 , (
            SELECT 
                   TOP 1 Descripcion            
            FROM IMSS.tblCatRazonesMovAfiliatorios
            WHERE IDRazonMovimiento = c.IDRazonMovimiento
           )                                                                                                                              AS [RazonMovimiento]
		 , DATEADD( DAY , 1 , @FechaFinBimestre )                                                                                         AS [DiaAplicacion]  
		 , CAST( ISNULL( c.ConceptosPremioAsistencia   ,0) AS DECIMAL(18,2) )                                                             AS [CantidadPremioAsistencia]
		 , CAST( ISNULL( c.ConceptosPremioPuntualidad  ,0) AS DECIMAL(18,2) )                                                             AS [CantidadPremioPuntualidad]
		 , CAST( ISNULL( c.ConceptosValesDespensa      ,0) AS DECIMAL(18,2) )                                                             AS [CantidadValesDespensa]
		 , CAST( ISNULL( c.IntegrablesVariables        ,0) AS DECIMAL(18,2) )                                                             AS [CantidadIntegrablesVariables]
		 , CAST( ISNULL( c.HorasExtrasDobles           ,0) AS DECIMAL(18,2) )                                                             AS [CantidadHorasExtrasDobles]
		 , config.ConceptosValesDespensa                                                                                                  AS [ConceptosValesDespensa]
		 , config.ConceptosPremioPuntualidad                                                                                              AS [ConceptosPremioPuntualidad]                                                                                                
		 , config.ConceptosPremioAsistencia                                                                                               AS [ConceptosPremioAsistencia]
		 , config.ConceptosHorasExtrasDobles                                                                                              AS [ConceptosHorasExtrasDobles]
		 , config.ConceptosIntegrablesVariables                                                                                           AS [ConceptosIntegrablesVariables]
		 , config.ConceptosDias                                                                                                           AS [ConceptosDias]
		 , config.PromediarUMA                                                                                                            AS [PromediarUMA]
		 , config.TopePremioPuntualidadAsistencia                                                                                         AS [TopePremioPuntualidadAsistencia]
		 , c.UMA                                                                                                                          AS [UMA]
		 , c.SalarioMinimo                                                                                                                AS [SalarioMinimo]
		 , @Ejercicio                                                                                                                     AS [Ejercicio]
		 , @DescripcionBimestre                                                                                                           AS [Bimestre]		 
		 , CASE WHEN config.CriterioDias = 0 THEN 'DIAS ACUMULADOS DEL TRABAJADOR' ELSE 'DIAS DEL BIMESTRE' END                           AS [CriterioDias]
		 , CASE WHEN ISNULL( config.PromediarUMA ,1) = 1 THEN 'UMA CORRESPONDIENTE A CADA MES DEL BIMESTRE'       
		 		WHEN ISNULL( config.PromediarUMA ,1) = 2 THEN 'ULTIMA UMA DEL BIMESTRE'
		 		ELSE 'PROMEDIO DE UMA DEL BIMESTRE' 		 
           END                                                                                                                            AS [CriterioUMA] 
		 , SUBSTRING(  
		              (  
		                    SELECT ','+c.Codigo+' - '+c.Descripcion  AS [text()]
                            FROM Nomina.tblcatconceptos c                              WITH(NOLOCK)
		                    CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)
                            WHERE IDConcepto in (SELECT item FROM app.Split(vb.ConceptosIntegrablesVariables,','))
                            FOR XML PATH ('')  
		              )
            , 2, 1000) [ConceptosIntegran]  		 
		 , c.FechaMov                                                                                                                     AS [FechaUltimoMovimiento]
    INTO #tempDone
    FROM #tempcalc c        
	    CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales config WITH(NOLOCK)
    WHERE ( CASE WHEN c.CriterioDias = 0 AND ISNULL( c.Dias ,0) > 0 THEN c.Dias ELSE @DiasBimestre END ) > 0


    
    UPDATE  #tempDone  
	SET   VariableCambio  = CASE WHEN  AnteriorSalarioVariable <> SalarioVariable                      THEN 1 ELSE 0 END
		, FactorCambio    = CASE WHEN  FactorAntiguo <> NuevoFactor                                    THEN 1 ELSE 0 END 
		, IntegradoCambio = CASE WHEN ROUND(AnteriorSalarioIntegrado, 2) <> ROUND(SalarioIntegrado, 2) THEN 1 ELSE 0 END


    UPDATE #tempDone 
	-- SET Afectar = CASE WHEN VariableCambio = 1 OR FactorCambio = 1 OR IntegradoCambio = 1 THEN 1 ELSE 0 END
    SET Afectar = CASE WHEN @ConfigCriterioCambioSDI = 1 
                            THEN IntegradoCambio 
                       ELSE 
                            CASE WHEN VariableCambio = 1 OR FactorCambio = 1 THEN 1 ELSE 0 END 
                  END
   

    BEGIN TRY
		BEGIN TRANSACTION TRANVariables
            MERGE INTO [Nomina].[TblCalculoVariablesBimestralesMaster] AS TARGET
            USING #tempDone AS SOURCE
            ON TARGET.IDControlCalculoVariables = SOURCE.IDControlCalculoVariables
            AND TARGET.IDEmpleado = SOURCE.IDEmpleado    
            WHEN MATCHED THEN
                UPDATE SET
                      TARGET.VariableCambio = SOURCE.VariableCambio
                    , TARGET.FactorCambio = SOURCE.FactorCambio
                    , TARGET.IntegradoCambio = SOURCE.IntegradoCambio
                    , TARGET.NuevoFactor = SOURCE.NuevoFactor
                    , TARGET.FactorAntiguo = SOURCE.FactorAntiguo
                    , TARGET.AniosPrestacion = SOURCE.AniosPrestacion
                    , TARGET.SalarioDiario = SOURCE.SalarioDiario
                    , TARGET.SalarioVariable = SOURCE.SalarioVariable
                    , TARGET.SalarioIntegrado = SOURCE.SalarioIntegrado
                    , TARGET.SalarioDiarioReal = SOURCE.SalarioDiarioReal
                    , TARGET.AnteriorSalarioDiario = SOURCE.AnteriorSalarioDiario
                    , TARGET.AnteriorSalarioVariable = SOURCE.AnteriorSalarioVariable
                    , TARGET.AnteriorSalarioIntegrado = SOURCE.AnteriorSalarioIntegrado
                    , TARGET.AnteriorSalarioDiarioReal = SOURCE.AnteriorSalarioDiarioReal
                    , TARGET.Dias = SOURCE.Dias
                    , TARGET.DiaAplicacion = SOURCE.DiaAplicacion
                    , TARGET.CantidadPremioAsistencia = SOURCE.CantidadPremioAsistencia
                    , TARGET.CantidadPremioPuntualidad = SOURCE.CantidadPremioPuntualidad
                    , TARGET.CantidadValesDespensa = SOURCE.CantidadValesDespensa
                    , TARGET.CantidadIntegrablesVariables = SOURCE.CantidadIntegrablesVariables
                    , TARGET.CantidadHorasExtrasDobles = SOURCE.CantidadHorasExtrasDobles
                    , TARGET.UMA = SOURCE.UMA
                    , TARGET.SalarioMinimo = SOURCE.SalarioMinimo
                    , TARGET.CriterioDias = SOURCE.CriterioDias
                    , TARGET.CriterioUMA = SOURCE.CriterioUMA
                    , TARGET.ConceptosIntegran = SOURCE.ConceptosIntegran
                    , TARGET.FechaUltimoMovimiento = SOURCE.FechaUltimoMovimiento
                    , TARGET.Afectar = source.Afectar ;   


            ---SEGMENTO DE DETALLE

            IF OBJECT_ID('tempdb..#tempDias') IS NOT NULL DROP TABLE #tempDias
            IF OBJECT_ID('tempdb..#tempTblCalculoVariablesBimestralesDetalle') IS NOT NULL DROP TABLE #tempTblCalculoVariablesBimestralesDetalle
            IF OBJECT_ID('tempdb..#tempTblCalculoVariablesBimestralesDetalleVales') IS NOT NULL DROP TABLE #tempTblCalculoVariablesBimestralesDetalleVales


    
            CREATE TABLE #tempTblCalculoVariablesBimestralesDetalle (        
                    [IDCalculoVariablesBimestralesMaster]        [INT] NOT NULL,
                    [IDEmpleado]                                 [INT] NOT NULL,
                    [IDConcepto]                                 [INT] NOT NULL,
                    [Integrable]                                 [DECIMAL](18, 2) NULL,
                    [Importetotal1]                              [DECIMAL](18, 2) NULL
            );

            CREATE TABLE #tempTblCalculoVariablesBimestralesDetalleVales (        
                    [IDCalculoVariablesBimestralesMaster]        [INT] NOT NULL,
                    [IDEmpleado]                                 [INT] NOT NULL,
                    [IDConcepto]                                 [INT] NOT NULL,
                    [Integrable]                                 [DECIMAL](18, 2) NULL,
                    [Importetotal1]                              [DECIMAL](18, 2) NULL,
                    [TopeVales]                                  [DECIMAL](18, 2) NULL,
                    [Dias]                                       [DECIMAL](18,2) NULL,
                    [DiasMes]                                       [DECIMAL](18,2) NULL,
            );



             SELECT 
                  @IDEmpleado                                                                                                                                         AS [IDEmpleado]
                , ISNULL(
                            (   
                                SELECT 
                                       CAST( SUM( Importetotal1 ) AS DECIMAL(18,2) )      
	        			        FROM Nomina.tblDetallePeriodo dp        WITH (NOLOCK)  
	        			            INNER JOIN Nomina.tblCatPeriodos p  WITH (NOLOCK)   
	        			    	            ON dp.IDPeriodo = p.IDPeriodo  
	        			    		       AND p.Ejercicio  = @Ejercicio  
	        			    		       AND p.IDMes      =  temp.IDMes 
	        			    		       AND p.Cerrado    = 1 
	        			    	    INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
	        			    		        ON hep.IDEmpleado    = @IDEmpleado
	        			    		       AND hep.IDPeriodo     = p.IDPeriodo
	        			    		       AND hep.IDRegPatronal = @IDRegPatronal
	        			        WHERE dp.IDEmpleado = @IDEmpleado 
                                  AND dp.IDConcepto IN (SELECT item FROM app.Split(vb.ConceptosDias,',')) 
                            )
                       ,0)                                                                                                                                           AS [Dias]  
	            , CASE WHEN CVBM.FechaAntiguedad>temp.IniMes THEN DATEDIFF(DAY,CVBM.FechaAntiguedad,temp.FinMes)+1 ELSE DATEDIFF(DAY,temp.IniMes,temp.FinMes)+1 END  AS [DiasMes]
                , temp.IDMes
             INTO #tempDias
             FROM #tempMovPrevios temp            
                  CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)
                  INNER JOIN IMSS.tblMovAfiliatorios mov                     WITH(NOLOCK)
	        	          ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio
                  INNER JOIN Nomina.TblCalculoVariablesBimestralesMaster CVBM    
                          ON CVBM.IDEmpleado                = @IDEmpleado
                         AND CVBM.IDControlCalculoVariables = @IDControlCalculoVariables       

        
            IF (
                (SELECT COUNT(item) 
                 FROM app.Split(
                     (SELECT TOP 1 ConceptosValesDespensa 
                      FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK)), ',')
                ) > 1
            )
            BEGIN
                INSERT INTO #tempTblCalculoVariablesBimestralesDetalleVales  (IDEmpleado,IDCalculoVariablesBimestralesMaster,IDConcepto,Integrable,Importetotal1,TopeVales,Dias,DiasMes)            
                SELECT                     
                        @IDEmpleado                                   AS [IDEmpleado]
                      , @IDCalculoVariablesBimestralesMaster          AS [IDCalculoVariablesBimestralesMaster]
                      , (SELECT TOP 1 item FROM app.Split((SELECT TOP 1 ConceptosValesDespensa FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK)), ',')) AS [IDConcepto]
                      , CASE WHEN  SUM(Vales) > SUM(TopeVales) 
                                 THEN SUM(Integrable) 
                            ELSE 0 
                        END                                           AS [Integrable]
                      , SUM(Vales.Importetotal1)                      AS [Importetotal1]
                      , SUM(TopeVales)                                AS [TopeVales]
                      , Sum(Dias)                                     AS [Dias]
                      , Sum(DiasMes)                                  AS [DiasMes]
                FROM
                    (
                        SELECT 
	            		        NULL                                                                                                                           AS [IDConcepto]                
	            		      , CASE WHEN SUM( dp.Importetotal1 ) > ( ( temp.UMA * (
                                                                                CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN dias.Dias
                                                                                     WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES THEN dias.DiasMes
                                                                                     ELSE  CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END
                                                                                     END
                                                                               )
                                                                        ) * 0.40   ) 
                                          THEN SUM( dp.Importetotal1 ) - ( ( temp.UMA * (
                                                                                CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN dias.Dias
                                                                                     WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES THEN dias.DiasMes
                                                                                     ELSE  CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END
                                                                                     END
                                                                               )
                                                                            ) * 0.40 )  
                                     ELSE 0 
                                END                                                                                                                                      AS [Integrable]
	            		      , SUM(Importetotal1)                                                                                                                       AS [Importetotal1]
                              , UMA                                                                                                                                      AS [UMA]
                              , dias.Dias                                                                                                                                AS [Dias]
                              , dias.DiasMes                                                                                                                             AS [DiasMes]
                              , vb.CriterioDias                                                                                                                          AS [CriterioDias]
	            		      , ( ( UMA * (
                                            CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN dias.Dias
                                                 WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN dias.DiasMes
                                                 ELSE  CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END
                                                 END
                                            )
                                   ) * 0.40 )                                                                                                                            AS [TopeVales]
	            		      , SUM( dp.Importetotal1 )                                                                                                                  AS [Vales]
	            	    FROM Nomina.tblDetallePeriodo dp                WITH (NOLOCK)
                             LEFT JOIN #tempMovPrevios temp
                                    ON temp.IDEmpleado = dp.IDEmpleado
                             INNER JOIN IMSS.tblMovAfiliatorios mov     WITH(NOLOCK)
	            	                 ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
                             INNER JOIN Nomina.tblCatPeriodos p         WITH (NOLOCK) 
	            			         ON dp.IDPeriodo = p.IDPeriodo
	            				    AND p.Ejercicio  = @Ejercicio
	            				    AND p.IDMes      = temp.IDMes
	            				    AND p.Cerrado    = 1
                             INNER JOIN #tempDias dias
                                     ON dias.IDEmpleado = dp.IDEmpleado 
                                    AND p.IDMes         = dias.IDMes
	            		     INNER JOIN Nomina.tblCatConceptos c                        WITH (NOLOCK)
	            			         ON c.IDConcepto    = dp.IDConcepto
	            		     INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP      WITH(NOLOCK)
	            					 ON hep.IDEmpleado    = @IDEmpleado
	            					AND hep.IDPeriodo     = p.IDPeriodo
	            					AND hep.IDRegPatronal = @IDRegPatronal            
                             CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)       
	            	    WHERE dp.IDEmpleado = @IDEmpleado 
	            		  AND dp.IDConcepto IN ( SELECT item FROM app.Split( ( SELECT TOP 1 ConceptosValesDespensa FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK) ), ',') ) 
	            	    GROUP BY   
                                   temp.UMA
                                 , dias.IDMes
                                 , dias.Dias
                                 , dias.DiasMes
                                 , VB.CriterioDias
                    ) AS [Vales]
	            GROUP BY Vales.IDConcepto
            END
            ELSE
            BEGIN
                 INSERT INTO #tempTblCalculoVariablesBimestralesDetalleVales  (IDEmpleado,IDCalculoVariablesBimestralesMaster,IDConcepto,Integrable,Importetotal1,TopeVales,Dias,DiasMes)            
                SELECT                     
                        @IDEmpleado                                   AS [IDEmpleado]
                      , @IDCalculoVariablesBimestralesMaster          AS [IDCalculoVariablesBimestralesMaster]
                      , Vales.IDConcepto                              AS [IDConcepto]
                      , CASE WHEN  SUM(Vales) > SUM(TopeVales) 
                                 THEN SUM(Integrable) 
                            ELSE 0 
                        END                                           AS [Integrable]
                      , SUM(Vales.Importetotal1)                      AS [Importetotal1]
                      , SUM(TopeVales)                                AS [TopeVales]
                      , Sum(Dias)                                     AS [Dias]
                      , Sum(DiasMes)                                  AS [DiasMes]
                FROM
                    (
                        SELECT 
	            		        c.IDConcepto                                                                                                                             AS [IDConcepto]                
	            		      , CASE WHEN SUM( dp.Importetotal1 ) > ( ( temp.UMA * (
                                                                                CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN dias.Dias
                                                                                     WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES THEN dias.DiasMes
                                                                                     ELSE  CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END
                                                                                     END
                                                                               )
                                                                        ) * 0.40   ) 
                                          THEN SUM( dp.Importetotal1 ) - ( ( temp.UMA * (
                                                                                CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN dias.Dias
                                                                                     WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES THEN dias.DiasMes
                                                                                     ELSE  CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END
                                                                                     END
                                                                               )
                                                                            ) * 0.40 )  
                                     ELSE 0 
                                END                                                                                                                                      AS [Integrable]
	            		      , SUM(Importetotal1)                                                                                                                       AS [Importetotal1]
                              , UMA                                                                                                                                      AS [UMA]
                              , dias.Dias                                                                                                                                AS [Dias]
                              , dias.DiasMes                                                                                                                             AS [DiasMes]
                              , vb.CriterioDias                                                                                                                          AS [CriterioDias]
	            		      , ( ( UMA * (
                                            CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN dias.Dias
                                                 WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN dias.DiasMes
                                                 ELSE  CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END
                                                 END
                                            )
                                   ) * 0.40 )                                                                                                                            AS [TopeVales]
	            		      , SUM( dp.Importetotal1 )                                                                                                                  AS [Vales]
	            	    FROM Nomina.tblDetallePeriodo dp                WITH (NOLOCK)
                             LEFT JOIN #tempMovPrevios temp
                                    ON temp.IDEmpleado = dp.IDEmpleado
                             INNER JOIN IMSS.tblMovAfiliatorios mov     WITH(NOLOCK)
	            	                 ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
                             INNER JOIN Nomina.tblCatPeriodos p         WITH (NOLOCK) 
	            			         ON dp.IDPeriodo = p.IDPeriodo
	            				    AND p.Ejercicio  = @Ejercicio
	            				    AND p.IDMes      = temp.IDMes
	            				    AND p.Cerrado    = 1
                             INNER JOIN #tempDias dias
                                     ON dias.IDEmpleado = dp.IDEmpleado 
                                    AND p.IDMes         = dias.IDMes
	            		     INNER JOIN Nomina.tblCatConceptos c                        WITH (NOLOCK)
	            			         ON c.IDConcepto    = dp.IDConcepto
	            		     INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP      WITH(NOLOCK)
	            					 ON hep.IDEmpleado    = @IDEmpleado
	            					AND hep.IDPeriodo     = p.IDPeriodo
	            					AND hep.IDRegPatronal = @IDRegPatronal            
                             CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)       
	            	    WHERE dp.IDEmpleado = @IDEmpleado 
	            		  AND dp.IDConcepto IN ( SELECT item FROM app.Split( ( SELECT TOP 1 ConceptosValesDespensa FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK) ), ',') ) 
	            	    GROUP BY   c.IDConcepto                     
                                 , temp.UMA
                                 , dias.IDMes
                                 , dias.Dias
                                 , dias.DiasMes
                                 , VB.CriterioDias
                    ) AS [Vales]
	            GROUP BY Vales.IDConcepto
            END

           IF(ISNULL(@ConfigTopeVales,0) = 1)
            BEGIN      
               UPDATE #tempTblCalculoVariablesBimestralesDetalleVales               
		           SET Integrable = CASE WHEN  Importetotal1 > @TopeValesBimestral THEN Importetotal1 - @TopeValesBimestral ELSE 0 END               
            END
            ELSE IF(ISNULL(@ConfigTopeVales,0) = 2)
            BEGIN      
               UPDATE #tempTblCalculoVariablesBimestralesDetalleVales               
		      --  SET Integrable = CASE WHEN  Importetotal1 > @TopeValesBimestral THEN Importetotal1 - @TopeValesBimestral ELSE 0 END
              SET Integrable = CASE WHEN  Importetotal1 > ( @UMABimestre *
                                                  (CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                                                       WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN DiasMes
                                                       ELSE  CASE WHEN vb.CriterioDias = 0 THEN Dias ELSE DiasMes END END )*.40)
                                                       THEN Importetotal1 - 
                                                        ( @UMABimestre *
                                                  (CASE WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_TRABAJADOR_TOPE_VALES THEN Dias
                                                       WHEN  @ConfigCriterioDiasVales = @CRITERIO_DIAS_BIMESTRE_TOPE_VALES   THEN DiasMes
                                                       ELSE  CASE WHEN vb.CriterioDias = 0 THEN Dias ELSE DiasMes END END )*.40)
                                                        ELSE 0 END
            FROM #tempTblCalculoVariablesBimestralesDetalleVales               
            CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)                      
            END

            
                                  
            INSERT INTO #tempTblCalculoVariablesBimestralesDetalle (IDEmpleado,IDCalculoVariablesBimestralesMaster,IDConcepto,Integrable,Importetotal1) 
            SELECT  
                     [IDEmpleado]
                    ,[IDCalculoVariablesBimestralesMaster]                                                             
                    ,[IDConcepto]                                 
                    ,[Integrable]                                 
                    ,[Importetotal1]                              
            FROM #tempTblCalculoVariablesBimestralesDetalleVales
            
	        UNION ALL

            SELECT  
                      @IDEmpleado                                   AS [IDEmpleado]
                    , @IDCalculoVariablesBimestralesMaster          AS [IDCalculoVariablesBimestralesMaster]
                    , PremioPuntualidad.IDConcepto                  AS [IDConcepto]                         
                    , SUM(PremioPuntualidad.Integrable)             AS [Integrable]
                    , SUM(PremioPuntualidad.Importetotal1)          AS [Importetotal1]
            FROM
                (
                    SELECT 
	        	    	  c.IDConcepto                              AS [IDConcepto]
	        	    	, CASE WHEN SUM( dp.Importetotal1 ) > ( ( ( CASE WHEN ISNULL( vb.TopePremioPuntualidadAsistencia , 1 ) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END ) * CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END ) * 0.10 ) 
                                   THEN SUM( dp.Importetotal1 ) - ( ( ( CASE WHEN ISNULL( vb.TopePremioPuntualidadAsistencia , 1 ) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END ) * CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END ) * 0.10 ) 
                               ELSE 0 
                          END                                       AS [Integrable]
	        	    	, SUM( Importetotal1 )                      AS [Importetotal1]
                    FROM Nomina.tblDetallePeriodo dp             WITH (NOLOCK)
                        LEFT JOIN #tempMovPrevios temp
                               ON temp.IDEmpleado = dp.IDEmpleado
                        INNER JOIN IMSS.tblMovAfiliatorios mov   WITH(NOLOCK)
	        	                ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
                        INNER JOIN Nomina.tblCatPeriodos p       WITH (NOLOCK) 
	        	    		    ON dp.IDPeriodo = p.IDPeriodo
	        	    		   AND p.Ejercicio  = @Ejercicio
	        	    		   AND p.IDMes      = temp.IDMes
	        	    		   AND p.Cerrado    = 1
                        INNER JOIN #tempDias dias
                                ON dias.IDEmpleado = dp.IDEmpleado 
                               AND p.IDMes         = dias.IDMes
	        	    	INNER JOIN Nomina.tblCatConceptos c      WITH (NOLOCK)
	        	    		    ON c.IDConcepto = dp.IDConcepto
	        	    	INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
	        	    			ON hep.IDEmpleado    = @IDEmpleado
	        	    		   AND hep.IDPeriodo     = p.IDPeriodo
	        	    		   AND hep.IDRegPatronal = @IDRegPatronal
                        CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)       
	        	    WHERE dp.IDEmpleado = @IDEmpleado 
                      AND dp.IDConcepto IN ( SELECT item FROM app.Split ( ( SELECT TOP 1 ConceptosPremioPuntualidad FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK) ), ',' ) ) 
                    GROUP BY   c.IDConcepto                     
                             , dias.IDMes
                             , dias.Dias
                             , dias.DiasMes
                             , VB.CriterioDias
                             , VB.TopePremioPuntualidadAsistencia
                             , mov.SalarioDiario
                             , mov.SalarioIntegrado
                ) AS [PremioPuntualidad]
                GROUP BY PremioPuntualidad.IDConcepto


	        UNION ALL

            SELECT 
                      @IDEmpleado                                   AS [IDEmpleado]
                    , @IDCalculoVariablesBimestralesMaster          AS [IDCalculoVariablesBimestralesMaster]
                    , PremioAsistencia.IDConcepto                   AS [IDConcepto]            
                    , SUM(PremioAsistencia.Integrable)              AS [Integrable]
                    , SUM(PremioAsistencia.Importetotal1)           AS [Importetotal1]
            FROM
                (
	        	    SELECT 
	        	    	  c.IDConcepto                                AS [IDConcepto]
	        	    	, CASE WHEN SUM( dp.Importetotal1 ) > ( ( ( CASE WHEN ISNULL( vb.TopePremioPuntualidadAsistencia , 1 ) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END ) * CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END ) * 0.10 ) 
                                   THEN SUM( dp.Importetotal1 ) - ( ( ( CASE WHEN ISNULL( vb.TopePremioPuntualidadAsistencia , 1 ) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END ) * CASE WHEN vb.CriterioDias = 0 THEN dias.Dias ELSE dias.DiasMes END ) * 0.10 ) 
                               ELSE 0 
                          END                                         AS [Integrable]
	        	    	, SUM( Importetotal1 )                        AS [Importetotal1]
                    FROM Nomina.tblDetallePeriodo dp            WITH (NOLOCK)
                        LEFT JOIN #tempMovPrevios temp
                               ON temp.IDEmpleado=dp.IDEmpleado
                        INNER JOIN IMSS.tblMovAfiliatorios mov WITH(NOLOCK)
	        	                ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
                        INNER JOIN Nomina.tblCatPeriodos p     WITH (NOLOCK) 
	        	    		    ON dp.IDPeriodo = p.IDPeriodo
	        	    		   AND p.Ejercicio  = @Ejercicio
	        	    		   AND p.IDMes      = temp.IDMes
	        	    		   AND p.Cerrado    = 1
                        INNER JOIN #tempDias dias
                                ON dias.IDEmpleado = dp.IDEmpleado 
                               AND p.IDMes = dias.IDMes
	        	    	INNER JOIN Nomina.tblCatConceptos c WITH (NOLOCK)
	        	    		    ON c.IDConcepto = dp.IDConcepto
	        	    	INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
	        	    			ON hep.IDEmpleado    = @IDEmpleado
	        	    		   AND hep.IDPeriodo     = p.IDPeriodo
	        	    		   AND hep.IDRegPatronal = @IDRegPatronal
                        CROSS APPLY Nomina.tblConfigReporteVariablesBimestrales vb WITH(NOLOCK)       
	        	    WHERE dp.IDEmpleado = @IDEmpleado 
                      AND dp.IDConcepto IN (SELECT item FROM app.Split( (SELECT TOP 1 ConceptosPremioAsistencia FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK) ), ',') ) 
                    GROUP BY  c.IDConcepto                    
                            , dias.IDMes
                            , dias.Dias
                            , dias.DiasMes
                            , VB.CriterioDias
                            , vb.TopePremioPuntualidadAsistencia
                            , mov.SalarioDiario
                            , mov.SalarioIntegrado                            
                ) AS [PremioAsistencia]
                GROUP BY PremioAsistencia.IDConcepto

	        UNION ALL

	        SELECT 
                      @IDEmpleado                                   AS [IDEmpleado]
                    , @IDCalculoVariablesBimestralesMaster          AS [IDCalculoVariablesBimestralesMaster]
                    , HorasExtrasDobles.IDConcepto                  AS [IDConcepto]            
                    , SUM(HorasExtrasDobles.Integrable)             AS [Integrable]
                    , SUM(HorasExtrasDobles.Importetotal1)          AS [Importetotal1]
            FROM
                (
	                SELECT 
	        	           c.IDConcepto                            AS [IDConcepto]		         
	        	         , CASE WHEN SUM( ImporteTotal1 ) <= ( ( mov.SalarioDiario /  8.0 ) * 2.0 ) * 72.0 
                                     THEN 0
	        		            ELSE SUM( ImporteTotal1 ) - ( ( mov.SalarioDiario /  8.0 ) * 2.0 ) * 72.0
	        		       END                                     AS [Integrable]
                         , SUM( Importetotal1 )                    AS [Importetotal1]
                    FROM Nomina.tblDetallePeriodo dp WITH (NOLOCK)
                        LEFT JOIN #tempMovPrevios temp
                               ON temp.IDEmpleado = dp.IDEmpleado
                        INNER JOIN IMSS.tblMovAfiliatorios mov WITH(NOLOCK)
	                            ON mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
                        INNER JOIN Nomina.tblCatPeriodos p WITH (NOLOCK) 
	        		            ON dp.IDPeriodo = p.IDPeriodo
	        			       AND p.Ejercicio  = @Ejercicio
	        			       AND p.IDMes      = temp.IDMes
	        			       AND p.Cerrado    = 1            
	        	        INNER JOIN Nomina.tblCatConceptos c WITH (NOLOCK)
	        		            ON c.IDConcepto = dp.IDConcepto
	        	        INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
	        				    ON hep.IDEmpleado = @IDEmpleado
	        				   AND hep.IDPeriodo = p.IDPeriodo
	        				   AND hep.IDRegPatronal = @IDRegPatronal
                        WHERE  dp.IDEmpleado = @IDEmpleado 
	                      AND  dp.IDConcepto IN ( SELECT item FROM app.Split( ( SELECT TOP 1 ConceptosHorasExtrasDobles FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK) ) , ',' ) )                         
                        GROUP BY c.IDConcepto, mov.SalarioDiario
                ) AS [HorasExtrasDobles]
             GROUP BY HorasExtrasDobles.IDConcepto


	        UNION ALL

	        SELECT 
                    @IDEmpleado                                   AS [IDEmpleado]
                  , @IDCalculoVariablesBimestralesMaster          AS [IDCalculoVariablesBimestralesMaster]
                  , c.IDConcepto                                  AS [IDConcepto]
	        	  , SUM(Importetotal1)                            AS [Integrable]
	        	  , SUM(Importetotal1)                            AS [Importetotal1]
	        FROM Nomina.tblDetallePeriodo dp          WITH (NOLOCK)
	        	INNER JOIN Nomina.tblCatPeriodos p    WITH (NOLOCK) 
	        		    ON dp.IDPeriodo = p.IDPeriodo
	        		   AND p.Ejercicio = @Ejercicio
	        		   AND p.IDMes     in ( SELECT item FROM app.Split( ( SELECT TOP 1 meses FROM Nomina.tblCatBimestres WITH (NOLOCK) WHERE IDBimestre = @IDBimestre ) ,',' ) )
	        		   AND p.Cerrado   = 1
	        	INNER JOIN Nomina.tblCatConceptos c WITH (NOLOCK)
	        		    ON c.IDConcepto = dp.IDConcepto
	        	INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP WITH(NOLOCK)
	        			ON hep.IDEmpleado     = @IDEmpleado
	        			AND hep.IDPeriodo     = p.IDPeriodo
	        		    AND hep.IDRegPatronal = @IDRegPatronal
	        WHERE dp.IDEmpleado = @IDEmpleado 
	          AND dp.IDConcepto in ( SELECT item FROM app.Split( ( SELECT TOP 1 ConceptosIntegrablesVariables FROM Nomina.tblConfigReporteVariablesBimestrales WITH (NOLOCK) ) , ',' ) )
	        GROUP BY c.IDConcepto




            MERGE INTO [Nomina].[TblCalculoVariablesBimestralesDetalle] AS TARGET
            USING #tempTblCalculoVariablesBimestralesDetalle AS SOURCE
               ON TARGET.IDCalculoVariablesBimestralesMaster = SOURCE.IDCalculoVariablesBimestralesMaster      
              AND TARGET.IDEmpleado = SOURCE.IDEmpleado
              AND TARGET.IDConcepto = SOURCE.IDConcepto
            WHEN MATCHED THEN 
            UPDATE SET 
                TARGET.Integrable    = SOURCE.Integrable,
                TARGET.Importetotal1 = SOURCE.Importetotal1
            WHEN NOT MATCHED BY TARGET THEN 
            INSERT (IDCalculoVariablesBimestralesMaster, IDEmpleado, IDConcepto, Integrable, Importetotal1)
            VALUES (SOURCE.IDCalculoVariablesBimestralesMaster, SOURCE.IDEmpleado, SOURCE.IDConcepto, SOURCE.Integrable, SOURCE.Importetotal1)
            WHEN NOT MATCHED BY SOURCE AND TARGET.IDCalculoVariablesBimestralesMaster = @IDCalculoVariablesBimestralesMaster AND TARGET.IDEmpleado = @IDEmpleado
            THEN       
	        DELETE; 


            	COMMIT TRANSACTION TRANVariables

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION TRANVariables
		DECLARE @MESSAGE Varchar(max) =  ERROR_MESSAGE ( ) 
		RAISERROR(@MESSAGE,16,1)
	END CATCH



END
GO

USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCalcularControlAumentosDesempeno]
    @IDControlAumentosDesempeno INT
   ,@IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldJSON VARCHAR(MAX) = '',
                @NewJSON VARCHAR(MAX),
                @NombreSP VARCHAR(MAX) = '[Nomina].[spCalcularControlAumentosDesempeno]',
                @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempenoDetalle]',
                @Accion VARCHAR(20) = 'UPDATE';


        if object_id('tempdb..#MovimientosAfiliatorios') is not null drop table #MovimientosAfiliatorios;
        if object_id('tempdb..#ResultadosCalculadosObjetivosEvaluaciones') is not null drop table #ResultadosCalculadosObjetivosEvaluaciones;        
        if object_id('tempdb..#CalculosPreviosAumento') is not null drop table #CalculosPreviosAumento;
        if object_id('tempdb..#CalculosSueldoTope') is not null drop table #CalculosSueldoTope;        
        if object_id('tempdb..#CalculosSueldoFinal') is not null drop table #CalculosSueldoFinal;                
        if object_id('tempdb..#CalculosSueldoCalibrado') is not null drop table #CalculosSueldoCalibrado;
        if object_id('tempdb..#CalculosSueldoDiarioMovAfiliatorios') is not null drop table #CalculosSueldoDiarioMovAfiliatorios;
        if object_id('tempdb..#CalculosDetallesMovAfiliatorios') is not null drop table #CalculosDetallesMovAfiliatorios;
        
    
    DECLARE 
        @Ejercicio INT
       ,@UMA decimal(10,2)       
       ,@UMATOPADA decimal(10,2);

    SELECT @Ejercicio=DATEPART(YEAR,FechaMovAfiliatorio) FROM Nomina.tblControlAumentosDesempeno WHERE IDControlAumentosDesempeno=@IDControlAumentosDesempeno
    SELECT TOP 1 @UMA=ISNULL(UMA,0) FROM Nomina.tblSalariosMinimos WHERE DATEPART(YEAR,Fecha)=@Ejercicio ORDER BY Fecha DESC


    SET @UMATOPADA=@UMA*25

     IF(@UMA = 0)
     BEGIN
        raiserror('El valor de la UMA en el catálogo de Nómina y Seguridad Social/UMA,Salario Mínimo y Tope debe ser mayor a 0',16,1);  
		return;
     END
    
        SELECT 
                det.IDEmpleado
               ,( 
                    SELECT
                        TOP 1
                        IDMovAfiliatorio
                    FROM IMSS.tblMovAfiliatorios M WITH(NOLOCK)
                    WHERE det.IDEmpleado = M.IDEmpleado
                        AND M.IDTipoMovimiento IN (SELECT IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos WHERE Codigo <> 'B')
                        AND m.Fecha            >= det.FechaAntiguedad
                        AND m.Fecha            <= cad.FechaMovAfiliatorio
                        AND m.IDRegPatronal    = det.IDRegPatronal
                    ORDER BY m.Fecha DESC
                ) AS [IDMovAfiliatorio]
        INTO #MovimientosAfiliatorios
        FROM Nomina.tblControlAumentosDesempenoDetalle det
        INNER JOIN Nomina.tblControlAumentosDesempeno cad
            ON CAD.IDControlAumentosDesempeno = det.IDControlAumentosDesempeno
        WHERE det.IDControlAumentosDesempeno = @IDControlAumentosDesempeno

        DECLARE @ProyectosStr VARCHAR(MAX),
                @CiclosMedicionStr VARCHAR(MAX);
        
        -- Obtener string de proyectos para el control actual
        SELECT @ProyectosStr = STRING_AGG(IDProyecto, ',')
        FROM Nomina.tblControlAumentosDesempenoProyectos
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
        
        SELECT @CiclosMedicionStr = STRING_AGG(IDCicloMedicionObjetivo, ',')
        FROM Nomina.tblControlAumentosDesempenoCiclosMedicion
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
        
        CREATE TABLE #ResultadosCalculadosObjetivosEvaluaciones
        (
            IDControlAumentosDesempenoDetalle INT,        
            EvaluacionJefe DECIMAL(18,4),
            EvaluacionSubordinados DECIMAL(18,4), 
            EvaluacionColegas DECIMAL(18,4),
            TotalEvaluacionPorcentual DECIMAL(18,4),
            TotalEvaluacionPeso DECIMAL(18,6),
            TotalObjetivosPorPesoEnCicloMedicion DECIMAL(18,4),        
            TotalObjetivosPeso DECIMAL(18,4),
        );

        INSERT INTO #ResultadosCalculadosObjetivosEvaluaciones (
            IDControlAumentosDesempenoDetalle, 
            EvaluacionJefe, 
            EvaluacionSubordinados, 
            EvaluacionColegas, 
            TotalObjetivosPorPesoEnCicloMedicion)
        SELECT 
            D.IDControlAumentosDesempenoDetalle,
            [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](D.IDEmpleado, '1', @ProyectosStr) AS EvaluacionJefe,
            [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](D.IDEmpleado, '2', @ProyectosStr) AS EvaluacionSubordinados,
            [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](D.IDEmpleado, '3,6', @ProyectosStr) AS EvaluacionColegas,
            [Nomina].[fnObtenerProgresoGeneralPorCicloEmpleadoCompensaciones](D.IDEmpleado, @CiclosMedicionStr,C.TopeCumplimientoObjetivo) AS TotalObjetivosPorPesoEnCicloMedicion        
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
            ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

        -- Calcular el total de evaluación porcentual basado en los pesos de las evaluaciones de las distintas relaciones
        UPDATE #ResultadosCalculadosObjetivosEvaluaciones 
        SET TotalEvaluacionPorcentual =         
            (ISNULL(D.EvaluacionJefe,0) * (ISNULL(C.PesoEvaluacionJefe,0) / 100.0)) +        
            CASE WHEN D.EvaluacionSubordinados IS NOT NULL AND D.EvaluacionColegas IS NOT NULL
            THEN ((D.EvaluacionSubordinados + D.EvaluacionColegas) / 2) * (ISNULL(C.PesoEvaluacionOtros,0) / 100.0)
            ELSE 
                CASE WHEN D.EvaluacionSubordinados IS NOT NULL THEN ISNULL(D.EvaluacionSubordinados,0) ELSE ISNULL(D.EvaluacionColegas,0)  END *
                (ISNULL(C.PesoEvaluacionOtros,0) / 100.0)
            END              
        FROM #ResultadosCalculadosObjetivosEvaluaciones D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
            ON C.IDControlAumentosDesempeno = @IDControlAumentosDesempeno

        --Calcular el total de evaluación y objetivos basado en los pesos configurados
        UPDATE #ResultadosCalculadosObjetivosEvaluaciones 
        SET  TotalEvaluacionPeso = ISNULL(D.TotalEvaluacionPorcentual,0) * (ISNULL(C.PesoEvaluaciones,0) / 100.0)
            ,TotalObjetivosPeso = ISNULL(D.TotalObjetivosPorPesoEnCicloMedicion,0) * (ISNULL(C.PesoObjetivos,0) / 100.0)    
        FROM #ResultadosCalculadosObjetivosEvaluaciones D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
            ON C.IDControlAumentosDesempeno = @IDControlAumentosDesempeno

            
        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
        USING #ResultadosCalculadosObjetivosEvaluaciones AS source
        ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
        WHEN MATCHED THEN
            UPDATE SET
                EvaluacionJefe = source.EvaluacionJefe,
                EvaluacionSubordinados = source.EvaluacionSubordinados,
                EvaluacionColegas = source.EvaluacionColegas,
                TotalObjetivosPorPesoEnCicloMedicion = source.TotalObjetivosPorPesoEnCicloMedicion,
                TotalEvaluacionPorcentual = source.TotalEvaluacionPorcentual,
                TotalEvaluacionPeso = source.TotalEvaluacionPeso,
                TotalObjetivosPeso = source.TotalObjetivosPeso;           

        SELECT 
            D.IDControlAumentosDesempenoDetalle,
            D.IDEmpleado,
            ISNULL(CASE WHEN C.AfectarSalarioDiarioReal = 1 THEN MOV.SalarioDiarioReal ELSE MOV.SalarioDiario END,0) AS SueldoActual,
            ISNULL(ISNULL(CASE WHEN C.AfectarSalarioDiarioReal = 1 THEN MOV.SalarioDiarioReal ELSE MOV.SalarioDiario END,0)*ISNULL(C.DiasSueldoMensual,0),0) AS SueldoActualMensual,
            CASE WHEN D.FechaAntiguedad < C.FechaReferencia THEN 
            Nomina.fnObtenerPorcentajeTabuladorDesempeno(
                -- Total Evaluación: usar calibrado solo si es -1 o > 0
                CASE 
                    WHEN D.TotalEvaluacionCalibrado = -1 THEN 0
                    WHEN D.TotalEvaluacionCalibrado > 0 THEN D.TotalEvaluacionCalibrado
                    ELSE D.TotalEvaluacionPeso 
                END +
                -- Total Objetivos: usar calibrado solo si es -1 o > 0
                CASE 
                    WHEN D.TotalObjetivosCalibrado = -1 THEN 0
                    WHEN D.TotalObjetivosCalibrado > 0 THEN D.TotalObjetivosCalibrado
                    ELSE D.TotalObjetivosPeso 
                END,
                C.IDControlAumentosDesempeno
            ) ELSE -1 END AS PorcentajeIncremento,
            CASE WHEN D.FechaAntiguedad < C.FechaReferencia THEN 
            [Nomina].[fnObtenerSueldoMaximoPorNivelSalarialAumentosDesempeno](D.IDControlAumentosDesempenoDetalle) / ISNULL(C.DiasSueldoMensual,0) 
            ELSE 0 END AS TopePorNivelSalarial
        INTO #CalculosPreviosAumento
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
            INNER JOIN #MovimientosAfiliatorios MA
                    ON MA.IDEmpleado = D.IDEmpleado
            INNER JOIN IMSS.tblMovAfiliatorios MOV
                    ON MOV.IDMovAfiliatorio = MA.IDMovAfiliatorio
            INNER JOIN #ResultadosCalculadosObjetivosEvaluaciones R
                    ON R.IDControlAumentosDesempenoDetalle = D.IDControlAumentosDesempenoDetalle                            
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno 

                 
        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
        USING #CalculosPreviosAumento AS source
        ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
        WHEN MATCHED THEN
            UPDATE SET
                SueldoActual = source.SueldoActual,
                SueldoActualMensual = source.SueldoActualMensual,
                PorcentajeIncremento = source.PorcentajeIncremento;

                        
        SELECT 
            D.IDControlAumentosDesempenoDetalle,
            D.IDControlAumentosDesempeno,
            CASE WHEN (D.PorcentajeIncrementoCalibrado <> -1 AND D.PorcentajeIncrementoCalibrado >0)  OR (D.PorcentajeIncremento > 0 AND ISNULL(D.PorcentajeIncrementoCalibrado,0)=0  )  THEN D.SueldoActual * (1 + 
                CASE 
                    WHEN D.PorcentajeIncrementoCalibrado = -1 THEN 0

                    WHEN D.PorcentajeIncrementoCalibrado > 0 THEN D.PorcentajeIncrementoCalibrado
                    ELSE D.PorcentajeIncremento 

                END
            ) ELSE 0 END AS SueldoNuevoSinTope,

             CASE WHEN (D.PorcentajeIncrementoCalibrado <> -1 AND D.PorcentajeIncrementoCalibrado >0)  OR (D.PorcentajeIncremento > 0 AND ISNULL(D.PorcentajeIncrementoCalibrado,0)=0  )  THEN
             CASE WHEN D.SueldoActual * (1 + 
                CASE 
                    WHEN D.PorcentajeIncrementoCalibrado = -1 THEN 0
                    WHEN D.PorcentajeIncrementoCalibrado > 0 THEN D.PorcentajeIncrementoCalibrado
                    ELSE D.PorcentajeIncremento 
                END
            ) > CP.TopePorNivelSalarial 
            THEN CP.TopePorNivelSalarial 
            ELSE D.SueldoActual * (1 + 
                CASE 
                    WHEN D.PorcentajeIncrementoCalibrado = -1 THEN 0
                    WHEN D.PorcentajeIncrementoCalibrado > 0 THEN D.PorcentajeIncrementoCalibrado
                    ELSE D.PorcentajeIncremento 
                END
            ) END
            ELSE 0
            END AS SueldoNuevoTopado,
            CAST(0 as DECIMAL(18,2)) AS SueldoMensualNuevoSinTope,
            CAST(0 as DECIMAL(18,2)) AS SueldoMensualNuevoTopado
        INTO #CalculosSueldoTope
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C

                    ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
            INNER JOIN #CalculosPreviosAumento CP
                    ON CP.IDControlAumentosDesempenoDetalle = D.IDControlAumentosDesempenoDetalle
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
            

    

        UPDATE T
        SET T.SueldoMensualNuevoSinTope = ROUND(T.SueldoNuevoSinTope * ISNULL(C.DiasSueldoMensual,0), -2),
            T.SueldoMensualNuevoTopado = ROUND(T.SueldoNuevoTopado * ISNULL(C.DiasSueldoMensual,0), -2)
        FROM #CalculosSueldoTope T

            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = T.IDControlAumentosDesempeno

                        

        UPDATE T
        SET T.SueldoNuevoSinTope = T.SueldoMensualNuevoSinTope / ISNULL(C.DiasSueldoMensual,0),
            T.SueldoNuevoTopado = T.SueldoMensualNuevoTopado / ISNULL(C.DiasSueldoMensual,0)
        FROM #CalculosSueldoTope T
            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = T.IDControlAumentosDesempeno
        
        ---se realiza esta validacion para los numeros periodicos de .33 que hacen que no se lleguen a los sueldos mensuales pactados
        UPDATE T
        SET T.SueldoNuevoSinTope =CASE WHEN CAST(T.SueldoNuevoSinTope AS DECIMAL (18,2))-CAST(T.SueldoNuevoSinTope AS INT) = .33 THEN T.SueldoNuevoSinTope + 0.01 ELSE T.SueldoNuevoSinTope END,
            T.SueldoNuevoTopado = CASE WHEN CAST(T.SueldoNuevoTopado AS DECIMAL (18,2))-CAST(T.SueldoNuevoTopado AS INT) = .33 THEN T.SueldoNuevoTopado + 0.01 ELSE T.SueldoNuevoTopado END
        FROM #CalculosSueldoTope T
            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = T.IDControlAumentosDesempeno
            
        UPDATE T
        SET T.SueldoMensualNuevoSinTope = CAST(T.SueldoNuevoSinTope AS DECIMAL(18,2)) * ISNULL(C.DiasSueldoMensual,0),
            T.SueldoMensualNuevoTopado = CAST(T.SueldoNuevoTopado AS DECIMAL(18,2)) * ISNULL(C.DiasSueldoMensual,0)
        FROM #CalculosSueldoTope T
            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = T.IDControlAumentosDesempeno

        
                
        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
        USING #CalculosSueldoTope AS source
            ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
            WHEN MATCHED THEN
                UPDATE SET
                    SueldoNuevoSinTope = source.SueldoNuevoSinTope,
                    SueldoNuevoTopado = source.SueldoNuevoTopado,
                    SueldoMensualNuevoSinTope = source.SueldoMensualNuevoSinTope,
                    SueldoMensualNuevoTopado = source.SueldoMensualNuevoTopado;


        SELECT 
            D.IDControlAumentosDesempenoDetalle,
            D.IDEmpleado,            
            CASE WHEN D.SueldoActual>D.SueldoNuevoTopado OR D.SueldoActual=D.SueldoNuevoTopado THEN 0 ELSE D.SueldoNuevoTopado END AS SueldoNuevo,
            CASE WHEN D.SueldoActual>D.SueldoNuevoTopado OR D.SueldoActual=D.SueldoNuevoTopado THEN 0 ELSE D.SueldoNuevoTopado * ISNULL(C.DiasSueldoMensual,0) END AS SueldoMensualNuevo,
            CASE WHEN D.SueldoActual>D.SueldoNuevoTopado OR D.SueldoActual=D.SueldoNuevoTopado THEN 0 ELSE (D.SueldoNuevoTopado/D.SueldoActual)-1 END AS PorcentajeIncrementoInverso
        INTO #CalculosSueldoFinal
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
            INNER JOIN #CalculosPreviosAumento CP
                    ON CP.IDControlAumentosDesempenoDetalle = D.IDControlAumentosDesempenoDetalle
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
    
        
        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
            USING #CalculosSueldoFinal AS source
            ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
            WHEN MATCHED THEN
                UPDATE SET                    
                    SueldoNuevo = source.SueldoNuevo,
                    SueldoMensualNuevo = source.SueldoMensualNuevo,
                    PorcentajeIncrementoInverso = source.PorcentajeIncrementoInverso;   

        
        SELECT D.IDControlAumentosDesempenoDetalle,
               D.IDEmpleado,                          
               CASE 
                   WHEN D.SueldoCalibrado = -1 THEN 0 * ISNULL(C.DiasSueldoMensual,0)
                   WHEN D.SueldoCalibrado > 0 THEN D.SueldoCalibrado * ISNULL(C.DiasSueldoMensual,0)
                   ELSE NULL 
               END AS SueldoMensualCalibrado
        INTO #CalculosSueldoCalibrado
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
            ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno


        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
        USING #CalculosSueldoCalibrado AS source
        ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
        WHEN MATCHED THEN
            UPDATE SET                
                SueldoMensualCalibrado = source.SueldoMensualCalibrado;

        
        SELECT D.IDControlAumentosDesempenoDetalle,
                D.IDEmpleado,                                                                          
                CASE WHEN D.ExcluirColaborador = -1 THEN 0                     
                     WHEN C.AfectarSalarioDiarioReal = 1 THEN MOV.SalarioDiario
                     WHEN  D.SueldoCalibrado = -1 THEN 0
                     WHEN  D.SueldoCalibrado > 0 THEN D.SueldoCalibrado                      
                     ELSE D.SueldoNuevo END AS SalarioDiarioMovimiento,
                CASE WHEN D.ExcluirColaborador = -1 THEN 0                     
                     WHEN C.AfectarSalarioDiarioReal = 0 THEN MOV.SalarioDiarioReal
                     WHEN  D.SueldoCalibrado = -1 THEN 0
                     WHEN  D.SueldoCalibrado > 0 THEN D.SueldoCalibrado                      
                     ELSE D.SueldoNuevo END AS SalarioDiarioRealMovimiento,
                CASE WHEN D.ExcluirColaborador = -1 THEN 0
                     WHEN D.SueldoCalibrado = -1 THEN 0
                     WHEN D.SueldoNuevo = 0 THEN 0
                     ELSE CASE WHEN C.RespetarSalarioVariable = 1 THEN MOV.SalarioVariable ELSE 0 END                
                     END AS SalarioVariableMovimiento
        INTO #CalculosSueldoDiarioMovAfiliatorios
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
                    ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
            INNER JOIN #MovimientosAfiliatorios MA 
                    ON MA.IDEmpleado = D.IDEmpleado
            INNER JOIN IMSS.tblMovAfiliatorios MOV
                    ON MOV.IDMovAfiliatorio = MA.IDMovAfiliatorio
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno

        
        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
        USING #CalculosSueldoDiarioMovAfiliatorios AS source
        ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
        WHEN MATCHED THEN
            UPDATE SET                
                SalarioDiarioMovimiento = source.SalarioDiarioMovimiento,
                SalarioVariableMovimiento = source.SalarioVariableMovimiento,
                SalarioDiarioRealMovimiento = source.SalarioDiarioRealMovimiento;

    
        SELECT D.IDControlAumentosDesempenoDetalle,
                D.IDEmpleado,                          
                CASE WHEN (D.SalarioDiarioMovimiento > 0 AND C.AfectarSalarioDiarioReal = 0) OR (D.SalarioDiarioMovimiento > 0 AND D.SalarioDiarioRealMovimiento > 0 AND C.AfectarSalarioDiarioReal = 1)
                          THEN   ISNULL(
                                  CASE WHEN ((D.SalarioDiarioMovimiento * D.Factor) + D.SalarioVariableMovimiento)>=@UMATOPADA 
                                          THEN @UMATOPADA        

                                          ELSE (D.SalarioDiarioMovimiento * D.Factor) + D.SalarioVariableMovimiento END
                                  ,0) 
                ELSE 0 END AS SalarioIntegradoMovimiento                    
        INTO #CalculosDetallesMovAfiliatorios
        FROM Nomina.TblControlAumentosDesempenoDetalle D
            INNER JOIN Nomina.TblControlAumentosDesempeno C
            ON C.IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
        WHERE D.IDControlAumentosDesempeno = @IDControlAumentosDesempeno


        MERGE Nomina.TblControlAumentosDesempenoDetalle AS target
        USING #CalculosDetallesMovAfiliatorios AS source
        ON target.IDControlAumentosDesempenoDetalle = source.IDControlAumentosDesempenoDetalle
        WHEN MATCHED THEN
            UPDATE SET                
                SalarioIntegradoMovimiento = source.SalarioIntegradoMovimiento;

        

        DROP TABLE #MovimientosAfiliatorios;
        DROP TABLE #ResultadosCalculadosObjetivosEvaluaciones;
        DROP TABLE #CalculosPreviosAumento;
        DROP TABLE #CalculosSueldoTope;
        DROP TABLE #CalculosSueldoFinal;        
        DROP TABLE #CalculosSueldoCalibrado;
        DROP TABLE #CalculosSueldoDiarioMovAfiliatorios;
        DROP TABLE #CalculosDetallesMovAfiliatorios;
        
        

        -- Antes del COMMIT, obtener JSON final de la tabla padre
        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblControlAumentosDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDControlAumentosDesempeno,b.Descripcion,b.Ejercicio,b.Aplicado FOR XML RAW))) a
        WHERE b.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario = @IDUsuario,
            @Tabla = @Tabla,
            @Procedimiento = @NombreSP,
            @Accion = @Accion,
            @NewData = @NewJSON,
            @OldData = @OldJSON;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Limpiar tablas temporales en caso de error
                if object_id('tempdb..#MovimientosAfiliatorios') is not null drop table #MovimientosAfiliatorios;
        if object_id('tempdb..#ResultadosCalculadosObjetivosEvaluaciones') is not null drop table #ResultadosCalculadosObjetivosEvaluaciones;        
        if object_id('tempdb..#CalculosPreviosAumento') is not null drop table #CalculosPreviosAumento;
        if object_id('tempdb..#CalculosSueldoTope') is not null drop table #CalculosSueldoTope;        
        if object_id('tempdb..#CalculosSueldoFinal') is not null drop table #CalculosSueldoFinal;                
        if object_id('tempdb..#CalculosSueldoCalibrado') is not null drop table #CalculosSueldoCalibrado;
        if object_id('tempdb..#CalculosSueldoDiarioMovAfiliatorios') is not null drop table #CalculosSueldoDiarioMovAfiliatorios;
        if object_id('tempdb..#CalculosDetallesMovAfiliatorios') is not null drop table #CalculosDetallesMovAfiliatorios;
        

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

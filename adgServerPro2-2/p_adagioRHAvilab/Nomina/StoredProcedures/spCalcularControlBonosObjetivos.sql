USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [Nomina].[spCalcularControlBonosObjetivos]
      @IDControlBonosObjetivos INT,
      @IDUsuario INT
  AS
  BEGIN
      SET NOCOUNT ON;

      BEGIN TRY
          BEGIN TRANSACTION;

          DECLARE @ProyectosStr VARCHAR(MAX),
                  @MontoUtilidadMinima DECIMAL(18,2),
                  @ResultadoEjercicio DECIMAL(18,2),
                  @CODIGO_CONCEPTO_PTU VARCHAR(MAX) = '131',
                  @EjercicioActual INT,
                  @IDConceptoPTU INT,
                  @CiclosMedicionStr VARCHAR(MAX),
                  @OldJSON VARCHAR(MAX) = '',                        
                  @NewJSON VARCHAR(MAX),
                  @NombreSP VARCHAR(MAX) = '[Nomina].[spCalcularControlBonosObjetivos]',
                  @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivosDetalle]',
                  @Accion VARCHAR(20) = 'UPDATE';


          SELECT @ProyectosStr = STRING_AGG(IDProyecto, ',')
          FROM Nomina.tblControlBonosObjetivosProyectos
          WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;


          SELECT @CiclosMedicionStr = STRING_AGG(IDCicloMedicionObjetivo, ',')
          FROM Nomina.tblControlBonosObjetivosCiclosMedicion
          WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;


          SELECT @IDConceptoPTU = IDConcepto
          FROM Nomina.tblCatConceptos
          WHERE Codigo = @CODIGO_CONCEPTO_PTU;


          -- SELECT @EjercicioActual = DATEPART(YEAR, FechaReferencia)
          SELECT @EjercicioActual = DATEPART(YEAR, FechaInformacionColaboradores)
          FROM Nomina.TblControlBonosObjetivos
          WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

          if object_id('tempdb..#ResultadosCalculadosObjetivosEvaluaciones') is not null drop table #ResultadosCalculadosObjetivosEvaluaciones;        
          if object_id('tempdb..#MovimientosAfiliatorios') is not null drop table #MovimientosAfiliatorios;
          if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados;
          if object_id('tempdb..#acumuladoDias') is not null drop table #acumuladoDias;
          if object_id('tempdb..#ptuEmpleados') is not null drop table #ptuEmpleados;
          if object_id('tempdb..#pagosBonoEmpleado') is not null drop table #pagosBonoEmpleado;


          
          SELECT @MontoUtilidadMinima = PresupuestoUtilidadBruta * (PorcentajeUtilidadMinima / 100.0),
              @ResultadoEjercicio = ResultadoEjercicio
          FROM Nomina.TblControlBonosObjetivos
          WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

          IF @MontoUtilidadMinima > @ResultadoEjercicio
          BEGIN              
              raiserror('El resultado del ejercicio es menor al monto de utilidad mínima',16,1);  		
              RETURN;
          END


          DECLARE 
          @Ejercicio INT       
      ,@FechaInicioIncidenciaIncapacidad DATE
      ,@FechaFinIncidenciaIncapacidad DATE
      ,@FechaInicioEjercicio DATE
      ,@FechaFinEjercicio DATE
      ,@FechaInformacionColaboradores DATE
      ,@dtEmpleados RH.dtEmpleados
      ,@dtFechas app.dtFechas
      

          SELECT @Ejercicio=Ejercicio 
                ,@FechaInformacionColaboradores = FechaInformacionColaboradores
          FROM Nomina.TblControlBonosObjetivos 
          WHERE IDControlBonosObjetivos=@IDControlBonosObjetivos


          SET @FechaInicioIncidenciaIncapacidad = (SELECT FechaInicioIncidenciaIncapacidad FROM Nomina.TblControlBonosObjetivos WHERE IDControlBonosObjetivos=@IDControlBonosObjetivos)
          SET @FechaFinIncidenciaIncapacidad = (SELECT FechaFinIncidenciaIncapacidad FROM Nomina.TblControlBonosObjetivos WHERE IDControlBonosObjetivos=@IDControlBonosObjetivos)
          SET @FechaInicioEjercicio = (CAST(@Ejercicio AS VARCHAR) + '-01-01')
          SET @FechaFinEjercicio = (CAST(@Ejercicio AS VARCHAR) + '-12-31')

          
          INSERT INTO @dtFechas  
          EXEC [App].[spListaFechas] @FechaIni = @FechaInicioEjercicio, @FechaFin = @FechaFinEjercicio  


          INSERT INTO @dtEmpleados(IDEmpleado)
          SELECT DISTINCT IDEmpleado
          FROM Nomina.TblControlBonosObjetivosDetalle
          WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos


          
          CREATE TABLE #tempVigenciaEmpleados (  
              IDEmpleado int null,  
              Fecha Date null,  
              Vigente bit null  
          )  

          INSERT INTO #tempVigenciaEmpleados 
          EXEC [RH].[spBuscarListaFechasVigenciaEmpleado]
          @dtEmpleados = @dtEmpleados
          ,@Fechas = @dtFechas
          ,@IDUsuario = @IDUsuario


  
      DELETE  #tempVigenciaEmpleados WHERE Vigente = 0


      SELECT IDEmpleado, Count(*) AS Dias,null as Incapacidades,null as Ausentismos    
      INTO #acumuladoDias
      FROM #tempVigenciaEmpleados
      GROUP BY IDEmpleado

      UPDATE #acumuladoDias
      SET Ausentismos = CASE WHEN config.DescuentaAusentismos = 1 THEN (SELECT COUNT(ie.IDIncidencia) 
                                      FROM Asistencia.tblIncidenciaEmpleado ie WITH(NOLOCK)										
                                      WHERE ie.IDIncidencia IN (SELECT item FROM App.split((SELECT AusentismosDescontar FROM Nomina.TblControlBonosObjetivos WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos), ','))
                                          AND ( ie.Fecha BETWEEN @FechaInicioIncidenciaIncapacidad AND @FechaFinIncidenciaIncapacidad)
                                          AND ie.IDEmpleado = temp_data.IDEmpleado
                                          AND ISNULL(ie.Autorizado,0) = 1
                                      ) else 0 end
                                      
          ,Incapacidades = CASE WHEN config.DescuentaIncapacidad = 1 THEN 
                                      (SELECT ISNULL(COUNT(ie.IDIncidencia),0) 
                                      FROM Asistencia.tblIncidenciaEmpleado ie WITH(NOLOCK)
                                          INNER JOIN Asistencia.tblIncapacidadEmpleado ii WITH(NOLOCK) 
                                              ON ii.IDIncapacidadEmpleado = ie.IDIncapacidadEmpleado										
                                      WHERE ii.IDTipoIncapacidad IN (SELECT item FROM App.split((SELECT TiposIncapacidadDescontar FROM Nomina.TblControlBonosObjetivos WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos), ','))
                                          AND (ie.Fecha BETWEEN @FechaInicioIncidenciaIncapacidad AND @FechaFinIncidenciaIncapacidad)
                                          AND ie.IDEmpleado = temp_data.IDEmpleado
                                          AND ISNULL(ie.Autorizado,0) = 1
                                      ) else 0 end
      FROM #acumuladoDias temp_data
      CROSS JOIN Nomina.TblControlBonosObjetivos config


          
      SELECT 
          det.IDControlBonosObjetivosDetalle
          ,det.IDEmpleado                    
          ,( 
                  SELECT
                      TOP 1
                      IDMovAfiliatorio
                  FROM IMSS.tblMovAfiliatorios M WITH(NOLOCK)
                  WHERE det.IDEmpleado = M.IDEmpleado
                      AND M.IDTipoMovimiento IN (SELECT IDTipoMovimiento FROM IMSS.tblCatTipoMovimientos WHERE Codigo <> 'B')
                      AND m.Fecha            >= det.FechaAntiguedad
                      AND m.Fecha            <= @FechaInformacionColaboradores
                      AND m.IDRegPatronal    = det.IDRegPatronal
                  ORDER BY m.Fecha DESC
              ) AS [IDMovAfiliatorio]
          ,cad.AfectarSalarioDiarioReal
          ,cad.DiasCriterioMes
          ,cad.DiasAnio
          ,CAST(0.00 AS DECIMAL(18,2)) as SueldoActual                   
          ,CAST(0.00 AS DECIMAL(18,2)) as SueldoActualMensual
          ,CAST(0.00 AS DECIMAL(18,2)) as SueldoActualAnual
      INTO #MovimientosAfiliatorios
      FROM Nomina.TblControlBonosObjetivosDetalle det
      INNER JOIN Nomina.TblControlBonosObjetivos cad
          ON CAD.IDControlBonosObjetivos = det.IDControlBonosObjetivos
      WHERE det.IDControlBonosObjetivos = @IDControlBonosObjetivos
          


      UPDATE #MovimientosAfiliatorios
      SET SueldoActual = ISNULL(ISNULL(CASE WHEN MA.AfectarSalarioDiarioReal = 1 THEN MOV.SalarioDiarioReal ELSE MOV.SalarioDiario END,0),0)       
      FROM #MovimientosAfiliatorios MA
      INNER JOIN IMSS.tblMovAfiliatorios MOV
      ON MOV.IDMovAfiliatorio = MA.IDMovAfiliatorio

      UPDATE #MovimientosAfiliatorios
      SET SueldoActualMensual = SueldoActual * ISNULL(MA.DiasCriterioMes,0)
      ,SueldoActualAnual = SueldoActual * ISNULL(MA.DiasCriterioMes,0) * 12
      FROM #MovimientosAfiliatorios MA


      MERGE Nomina.TblControlBonosObjetivosDetalle AS target
      USING #MovimientosAfiliatorios AS source
      ON target.IDControlBonosObjetivosDetalle = source.IDControlBonosObjetivosDetalle
      WHEN MATCHED THEN
          UPDATE SET
              SueldoActual = source.SueldoActual,
              SueldoActualMensual = source.SueldoActualMensual,
              SueldoActualAnual = source.SueldoActualAnual;

      MERGE Nomina.TblControlBonosObjetivosDetalle AS target
      USING #acumuladoDias AS source
      ON target.IDEmpleado = source.IDEmpleado
      WHEN MATCHED THEN
          UPDATE SET
              Dias = source.Dias,
              Ausentismos = source.Ausentismos,
              Incapacidades = source.Incapacidades;

      UPDATE Nomina.TblControlBonosObjetivosDetalle
      SET  DiasEjercicio = CASE WHEN (CASE WHEN D.CalibracionDias = -1 THEN 0
                                  WHEN D.CalibracionDias > 0 THEN D.CalibracionDias
                                  ELSE D.Dias
                                  END) -
                          (
                              CASE WHEN C.DescuentaAusentismos = 1 THEN
                                      CASE WHEN D.CalibracionAusentismos = -1 THEN 0
                                          WHEN D.CalibracionAusentismos > 0 THEN D.CalibracionAusentismos
                                          ELSE D.Ausentismos
                                          END
                                  ELSE 0 END 
                          )
                          -
                          (
                              CASE WHEN C.DescuentaIncapacidad = 1 THEN 
                                  CASE WHEN D.CalibracionIncapacidades = -1 THEN 0
                                      WHEN D.CalibracionIncapacidades > 0 THEN D.CalibracionIncapacidades
                                      ELSE D.Incapacidades
                                      END
                              ELSE 0 END 
                          ) > 0 
                          THEN (CASE WHEN D.CalibracionDias = -1 THEN 0
                                  WHEN D.CalibracionDias > 0 THEN D.CalibracionDias
                                  ELSE D.Dias
                                  END) -
                          (
                              CASE WHEN C.DescuentaAusentismos = 1 THEN
                                      CASE WHEN D.CalibracionAusentismos = -1 THEN 0
                                          WHEN D.CalibracionAusentismos > 0 THEN D.CalibracionAusentismos
                                          ELSE D.Ausentismos
                                          END
                                  ELSE 0 END 
                          )
                          -
                          (
                              CASE WHEN C.DescuentaIncapacidad = 1 THEN 
                                  CASE WHEN D.CalibracionIncapacidades = -1 THEN 0
                                      WHEN D.CalibracionIncapacidades > 0 THEN D.CalibracionIncapacidades
                                      ELSE D.Incapacidades
                                      END
                              ELSE 0 END 
                          )
                          ELSE 0
                          END
      FROM Nomina.TblControlBonosObjetivosDetalle D
      INNER JOIN Nomina.TblControlBonosObjetivos C
      ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos
      WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;
          
          CREATE TABLE #ResultadosCalculadosObjetivosEvaluaciones
          (
              IDControlBonosObjetivosDetalle INT,        
              EvaluacionJefe DECIMAL(18,4),
              EvaluacionSubordinados DECIMAL(18,4), 
              EvaluacionColegas DECIMAL(18,4),
              TotalEvaluacionPorcentual DECIMAL(18,4),            
              TotalObjetivos DECIMAL(18,4),        
              
          );

          INSERT INTO #ResultadosCalculadosObjetivosEvaluaciones (
              IDControlBonosObjetivosDetalle, 
              EvaluacionJefe, 
              EvaluacionSubordinados, 
              EvaluacionColegas, 
              TotalObjetivos)
          SELECT 
              D.IDControlBonosObjetivosDetalle,
              CASE WHEN C.AplicaMatrizPagoBono = 1 THEN [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](D.IDEmpleado, '1', @ProyectosStr) ELSE NULL END AS EvaluacionJefe,
              CASE WHEN C.AplicaMatrizPagoBono = 1 THEN [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](D.IDEmpleado, '2', @ProyectosStr) ELSE NULL END AS EvaluacionSubordinados,
              CASE WHEN C.AplicaMatrizPagoBono = 1 THEN [Nomina].[fnObtenerResultadoProyectoPorTipoRelacionCompensaciones](D.IDEmpleado, '3,6', @ProyectosStr) ELSE NULL END AS EvaluacionColegas,
              [Nomina].[fnObtenerProgresoGeneralPorCicloEmpleadoCompensaciones](D.IDEmpleado, @CiclosMedicionStr,C.TopeCumplimientoObjetivos) AS TotalObjetivos        
          FROM Nomina.TblControlBonosObjetivosDetalle D
              INNER JOIN Nomina.TblControlBonosObjetivos C
              ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos
          WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;


          -- Calcular el total de evaluación porcentual basado en los pesos de las evaluaciones de las distintas relaciones
          UPDATE #ResultadosCalculadosObjetivosEvaluaciones 
          SET TotalEvaluacionPorcentual =         
              (ISNULL(D.EvaluacionJefe,0) * (ISNULL(C.PesoEvaluacionJefe,0) / 100.0)) +        
              CASE WHEN D.EvaluacionSubordinados IS NOT NULL AND D.EvaluacionColegas IS NOT NULL
              THEN ((D.EvaluacionSubordinados + D.EvaluacionColegas) / 2) * (ISNULL(C.PesoEvaluacionOtros,0) / 100.0)
              ELSE 
                  CASE WHEN D.EvaluacionSubordinados IS NOT NULL THEN D.EvaluacionSubordinados ELSE D.EvaluacionColegas END *
                  (ISNULL(C.PesoEvaluacionOtros,0) / 100.0)
              END              
          FROM #ResultadosCalculadosObjetivosEvaluaciones D
              INNER JOIN Nomina.TblControlBonosObjetivos C
              ON C.IDControlBonosObjetivos = @IDControlBonosObjetivos
          
          MERGE Nomina.TblControlBonosObjetivosDetalle AS target
          USING #ResultadosCalculadosObjetivosEvaluaciones AS source
          ON target.IDControlBonosObjetivosDetalle = source.IDControlBonosObjetivosDetalle
          WHEN MATCHED THEN
              UPDATE SET                
                  TotalObjetivos = source.TotalObjetivos,
                  TotalEvaluacionPorcentual = source.TotalEvaluacionPorcentual;        
          
              
          UPDATE Nomina.TblControlBonosObjetivosDetalle
          SET FactorParaBono = IIF(C.ResultadoEjercicio/C.PresupuestoUtilidadBruta > (C.TopeFactorUtilidad/100.0),(C.TopeFactorUtilidad/100.0) ,C.ResultadoEjercicio/C.PresupuestoUtilidadBruta )           
              ,FactorObjetivos = CASE WHEN ((CASE WHEN CalibracionTotalObjetivos = -1 THEN 0
                                                  WHEN CalibracionTotalObjetivos > 0 THEN CalibracionTotalObjetivos
                                                  ELSE TotalObjetivos
                                                  END) / (ResultadoMinimoBono/100)-1) < 0 THEN 0                                             
                                  WHEN (CASE WHEN CalibracionTotalObjetivos = -1 THEN 0
                                                  WHEN CalibracionTotalObjetivos > 0 THEN CalibracionTotalObjetivos
                                                  ELSE TotalObjetivos
                                                  END / (ResultadoMinimoBono/100)-1) > (TopeFactorObjetivos/100.0) THEN (TopeFactorObjetivos/100.0)
                                  ELSE (CASE WHEN CalibracionTotalObjetivos = -1 THEN 0
                                                  WHEN CalibracionTotalObjetivos > 0 THEN CalibracionTotalObjetivos
                                                  ELSE TotalObjetivos
                                                  END / (ResultadoMinimoBono/100)-1) END
          FROM Nomina.TblControlBonosObjetivosDetalle D
              INNER JOIN Nomina.TblControlBonosObjetivos C
              ON C.IDControlBonosObjetivos = @IDControlBonosObjetivos
          WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;


          
      UPDATE Nomina.TblControlBonosObjetivosDetalle
      SET  ResultadoUtilidadDesempeno = (CASE WHEN CalibracionFactorParaBono = -1 THEN 0
                                              WHEN CalibracionFactorParaBono > 0 THEN CalibracionFactorParaBono
                                              ELSE FactorParaBono
                                              END ) * (ISNULL(T.PorcentajeResultadoUtilidad,0) / 100.0)
                                      +
                                      (CASE WHEN CalibracionFactorObjetivos = -1 THEN 0
                                              WHEN CalibracionFactorObjetivos > 0 THEN CalibracionFactorObjetivos
                                              ELSE FactorObjetivos
                                              END ) * (ISNULL(T.PorcentajeDesempenoEvaluacionPersonal,0) / 100.0)
                                      

      FROM Nomina.TblControlBonosObjetivosDetalle D
      INNER JOIN Nomina.TblControlBonosObjetivos C
      ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos
      INNER JOIN Nomina.tblTabuladorNivelSalarialBonosObjetivosDetalle T
      ON T.IDTabuladorNivelSalarialBonosObjetivos = C.IDTabuladorNivelSalarialBonosObjetivos 
      AND CASE WHEN D.CalibracionNivelSalarial <> 0 THEN D.CalibracionNivelSalarial ELSE  D.NivelSalarial END = T.Nivel
      WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;



    
      UPDATE Nomina.TblControlBonosObjetivosDetalle
      SET  BonoAnual = CASE WHEN D.FechaAntiguedad < C.FechaReferencia THEN 
                                              (D.SueldoActualAnual * (CASE WHEN CalibracionResultadoUtilidadDesempeno = -1 THEN 0
                                              WHEN CalibracionResultadoUtilidadDesempeno > 0 THEN CalibracionResultadoUtilidadDesempeno
                                              ELSE ResultadoUtilidadDesempeno
                                              END ) * (ISNULL(T.PorcentajeBonoAnual,0) / 100.0))
                                              * 
                                              (CASE WHEN D.CalibracionDiasEjercicio = -1 THEN 0
                                                    WHEN D.CalibracionDiasEjercicio > 0 THEN D.CalibracionDiasEjercicio 
                                                    ELSE D.DiasEjercicio
                                              END) / C.DiasAnio
                          ELSE 0 END                                                       
      FROM Nomina.TblControlBonosObjetivosDetalle D
      INNER JOIN Nomina.TblControlBonosObjetivos C
      ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos
      INNER JOIN Nomina.tblTabuladorNivelSalarialBonosObjetivosDetalle T
      ON T.IDTabuladorNivelSalarialBonosObjetivos = C.IDTabuladorNivelSalarialBonosObjetivos 
      AND CASE WHEN D.CalibracionNivelSalarial <> 0 THEN D.CalibracionNivelSalarial ELSE  D.NivelSalarial END = T.Nivel
      WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;
      
      -- WHERE DATEDIFF(DAY, e.FechaAntiguedad, @FechaReferencia) >= @DiasMinimosLaborados



      SELECT DP.IDEmpleado,SUM(DP.ImporteTotal1) AS ImporteTotal1
      INTO #ptuEmpleados
      FROM Nomina.tblDetallePeriodo DP
      INNER JOIN Nomina.tblCatPeriodos P
          ON P.IDPeriodo=DP.IDPeriodo
      WHERE P.Ejercicio=@EjercicioActual AND P.Cerrado=1 AND DP.IDConcepto=@IDConceptoPTU
      GROUP BY DP.IDEmpleado



      UPDATE Nomina.TblControlBonosObjetivosDetalle
      SET PTU = CASE WHEN D.FechaAntiguedad < C.FechaReferencia  THEN  ISNULL(ptu.ImporteTotal1,0) ELSE 0 END
      FROM Nomina.TblControlBonosObjetivosDetalle D    
      INNER JOIN Nomina.TblControlBonosObjetivos C
      ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos
      LEFT JOIN #ptuEmpleados ptu
          ON ptu.IDEmpleado = D.IDEmpleado
      WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;


      CREATE TABLE #pagosBonoEmpleado (
          IDEmpleado INT,
          PagoBono BIT
      );

      IF EXISTS(
          SELECT TOP 1 1 FROM Nomina.tblControlBonosObjetivos
          WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos
          AND AplicaMatrizPagoBono = 1
      )
      BEGIN
              INSERT INTO #pagosBonoEmpleado (IDEmpleado,PagoBono)
              SELECT D.IDEmpleado,Nomina.fnDeterminarBonoEmpleado(
                  CASE WHEN D.TotalEvaluacionPorcentual = -1 THEN 0
                  WHEN D.TotalEvaluacionPorcentual > 0 THEN D.TotalEvaluacionPorcentual
                  ELSE D.TotalEvaluacionPorcentual
                  END,
                  CASE WHEN D.CalibracionTotalObjetivos = -1 THEN 0
                  WHEN D.CalibracionTotalObjetivos > 0 THEN D.CalibracionTotalObjetivos
                  ELSE D.TotalObjetivos
                  END,
                  C.IDTabuladorRelacionEvaluacionesObjetivos) AS PagoBono            
              FROM Nomina.TblControlBonosObjetivosDetalle D
              INNER JOIN Nomina.TblControlBonosObjetivos C
                  ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos
              WHERE C.IDControlBonosObjetivos = @IDControlBonosObjetivos
      END

      

      UPDATE Nomina.TblControlBonosObjetivosDetalle
      SET Complemento = CASE WHEN D.ExcluirColaborador = -1 THEN 0
                          WHEN D.FechaAntiguedad >= C.FechaReferencia   THEN 0
                          WHEN C.AplicaMatrizPagoBono = 1 AND ISNULL(P.PagoBono,0) = 0 THEN 0
                          WHEN (C.Complemento * (CASE WHEN D.CalibracionDiasEjercicio = -1 THEN 0
                          WHEN D.CalibracionDiasEjercicio > 0 THEN D.CalibracionDiasEjercicio 
                          ELSE D.DiasEjercicio
                          END) / C.DiasAnio) - CASE WHEN D.CalibracionPTU = -1 THEN 0
                                                      WHEN D.CalibracionPTU > 0 THEN D.CalibracionPTU
                                                      ELSE ISNULL(D.PTU,0)
                                                      END > 0 
                                                      THEN (C.Complemento * (CASE WHEN D.CalibracionDiasEjercicio = -1 THEN 0
                                                                                  WHEN D.CalibracionDiasEjercicio > 0 THEN D.CalibracionDiasEjercicio 
                                                                                  ELSE D.DiasEjercicio
                                                                              END) / C.DiasAnio)                                                                                        
                                              - CASE WHEN D.CalibracionPTU = -1 THEN 0
                                              WHEN D.CalibracionPTU > 0 THEN D.CalibracionPTU
                                              ELSE ISNULL(D.PTU,0)
                                              END 
                                              ELSE 0
                                              END
      FROM Nomina.TblControlBonosObjetivosDetalle D
      INNER JOIN Nomina.TblControlBonosObjetivos C
      ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos    
      LEFT JOIN #pagosBonoEmpleado P
          ON P.IDEmpleado = D.IDEmpleado
      WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;


                  UPDATE Nomina.TblControlBonosObjetivosDetalle
      SET  BonoFinal = 
                      CASE WHEN D.ExcluirColaborador = -1 THEN 0
                      WHEN D.FechaAntiguedad >= C.FechaReferencia   THEN 0
                      WHEN C.AplicaMatrizPagoBono = 1 AND ISNULL(P.PagoBono,0) = 0 THEN 0
                      ELSE 
                          CASE WHEN 
                                  ((CASE WHEN D.CalibracionBonoAnual = -1 THEN 0
                                          WHEN D.CalibracionBonoAnual > 0 THEN D.CalibracionBonoAnual
                                          ELSE D.BonoAnual
                                          END) 
                                  )
                                  -
                                  CASE WHEN D.CalibracionPTU = -1 THEN 0
                                  WHEN D.CalibracionPTU > 0 THEN D.CalibracionPTU
                                  ELSE ISNULL(D.PTU,0)
                                  END
                                  -
                                  CASE WHEN D.CalibracionComplemento = -1 THEN 0
                                  WHEN D.CalibracionComplemento > 0 THEN D.CalibracionComplemento
                                  ELSE ISNULL(D.Complemento,0)
                                  END   
                          >0 THEN 
                              ((CASE WHEN D.CalibracionBonoAnual = -1 THEN 0
                              WHEN D.CalibracionBonoAnual > 0 THEN D.CalibracionBonoAnual
                              ELSE D.BonoAnual
                              END) 
                              )
                              -
                              CASE WHEN D.CalibracionPTU = -1 THEN 0
                              WHEN D.CalibracionPTU > 0 THEN D.CalibracionPTU
                              ELSE ISNULL(D.PTU,0)
                              END
                              -
                              CASE WHEN D.CalibracionComplemento = -1 THEN 0
                              WHEN D.CalibracionComplemento > 0 THEN D.CalibracionComplemento
                              ELSE ISNULL(D.Complemento,0)
                              END   
                          ELSE 0 END
                      END
      FROM Nomina.TblControlBonosObjetivosDetalle D
      INNER JOIN Nomina.TblControlBonosObjetivos C
      ON C.IDControlBonosObjetivos = D.IDControlBonosObjetivos    
      LEFT JOIN #pagosBonoEmpleado P
          ON P.IDEmpleado = D.IDEmpleado
      WHERE D.IDControlBonosObjetivos = @IDControlBonosObjetivos;

                              
          
          -- Antes del COMMIT, obtener JSON final de la tabla padre
          SELECT @NewJSON = a.JSON
          FROM [Nomina].[tblControlBonosObjetivos] b
          CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDControlBonosObjetivos,b.Descripcion,b.Ejercicio,b.Aplicado FOR XML RAW))) a
          WHERE b.IDControlBonosObjetivos = @IDControlBonosObjetivos;

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
      
          DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
          DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
          DECLARE @ErrorState INT = ERROR_STATE();

          RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
      END CATCH
  END
GO

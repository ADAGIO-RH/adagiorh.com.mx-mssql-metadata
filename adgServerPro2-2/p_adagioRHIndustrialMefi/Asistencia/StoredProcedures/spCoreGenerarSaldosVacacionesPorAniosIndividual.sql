USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[Asistencia].[spCoreGenerarSaldosVacacionesPorAniosIndividual] 706,1
[Asistencia].[spCoreBuscarSaldoVacacionesPorAnioNew] 706
*/
CREATE proc [Asistencia].[spCoreGenerarSaldosVacacionesPorAniosIndividual] 
(
    @IDEmpleado int,
	@IDUsuario	int
) as  
BEGIN
  SET NOCOUNT ON;

	Declare 
	@SegmentacionPrestacion bit,  
    @FechaIngresoVacaciones bit,
	@IDMovAfiliatorio int,
	@IDCliente int,
	@FechaAntiguedad DATE,
	@MaxFechaPrestacion DATE,
    @DiasVigenciaVacaciones int,
	@Fechas [App].[dtFechas],
    @ERROR VARCHAR(MAX),
	@tran int,
    @JsonOutput NVARCHAR(max),
    @MaxAñosVigencia int = 36500;

    
	

    BEGIN TRY
      	set @tran = @@TRANCOUNT



            SELECT TOP 1 @FechaIngresoVacaciones = CASE WHEN cast(isNULL(Valor,0) as BIT)  = 0 THEN 0  ELSE Cast(isNULL(Valor,0) AS BIT)  END
                FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
                INNER JOIN RH.tblEmpleadosMaster e WITH(NOLOCK) on e.IDCliente = c.IDCliente   
                WHERE e.IDEmpleado = @IDEmpleado  AND IDTipoConfiguracionCliente = 'FechaIngresoVacaciones'
            
            IF NOT EXISTS ( SELECT *
                            FROM RH.tblEmpleadosMaster  M WITH(NOLOCK)
                            INNER JOIN RH.tblCatTiposPrestacionesDetalle pd ON m.IDTipoPrestacion  = pd.IDTipoPrestacion
                            WHERE M.IDEmpleado = @IDEmpleado)
            BEGIN  
            RAISERROR('La prestacion del colaborador no contiene detalle de antiguedades', 16,1) 
                RETURN  
            END;


            IF(ISNULL(@FechaIngresoVacaciones,0) = 0)
            BEGIN
                SELECT 
                    @IDMovAfiliatorio = mov.IDMovAfiliatorio, 
                    @FechaAntiguedad =  M.FechaAntiguedad,
                    @MaxFechaPrestacion = DATEADD(YEAR,(SELECT MAX(Antiguedad)  FROM RH.tblCatTiposPrestacionesDetalle WHERE IDTipoPrestacion = M.IDTipoPrestacion),M.FechaAntiguedad),
                    @IDCliente = M.IDCliente
                FROM IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
                    INNER JOIN RH.tblEmpleadosMaster  M WITH(NOLOCK)
                        ON Mov.IDEmpleado = M.IDEmpleado
                        AND Mov.Fecha =  M.FechaAntiguedad 
                    WHERE M.IDEmpleado = @IDEmpleado
            END

            ELSE 
            BEGIN
                SELECT 
                    @IDMovAfiliatorio = mov.IDMovAfiliatorio, 
                    @FechaAntiguedad =  M.FechaIngreso,
                    @MaxFechaPrestacion = DATEADD(YEAR,(SELECT MAX(Antiguedad)  FROM RH.tblCatTiposPrestacionesDetalle WHERE IDTipoPrestacion = M.IDTipoPrestacion),M.FechaIngreso),
                    @IDCliente = M.IDCliente
                FROM IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
                    INNER JOIN RH.tblEmpleadosMaster  M WITH(NOLOCK)
                        ON Mov.IDEmpleado = M.IDEmpleado
                        AND Mov.Fecha = M.FechaAntiguedad 
                    WHERE M.IDEmpleado = @IDEmpleado
            END
            


            SELECT TOP 1 @SegmentacionPrestacion = CAST(isnull(Valor,0) as bit)
            FROM RH.tblConfiguracionesCliente vigencia  WITH(NOLOCK)
            WHERE vigencia.IDCliente = @IDCliente and vigencia.IDTipoConfiguracionCliente = 'SegmentacionPrestacionesVacaciones'

            SELECT TOP 1  @DiasVigenciaVacaciones = Case when CAST(isnull(Valor,0) as int) = 0 then @MaxAñosVigencia else CAST(isnull(Valor,0) as int) END
            FROM RH.tblConfiguracionesCliente vigencia  WITH(NOLOCK)
            WHERE vigencia.IDCliente = @IDCliente and vigencia.IDTipoConfiguracionCliente = 'VacacionesCaducanEn'

          

            IF ( (SELECT MAX(Antiguedad)
                            FROM RH.tblEmpleadosMaster  M WITH(NOLOCK)
                            Inner join RH.tblCatTiposPrestacionesDetalle pd on m.IDTipoPrestacion  = pd.IDTipoPrestacion
                            WHERE M.IDEmpleado = @IDEmpleado)  < DATEDIFF(YEAR,@FechaAntiguedad,GETDATE()) OR (SELECT MAX(Antiguedad)
                            FROM RH.tblEmpleadosMaster  M WITH(NOLOCK)
                            Inner join RH.tblCatTiposPrestacionesDetalle pd on m.IDTipoPrestacion  = pd.IDTipoPrestacion
                            WHERE M.IDEmpleado = @IDEmpleado) < 10 )
            BEGIN  
            RAISERROR('La antiguedad del colaborador es mayor que la antiguedad del detalle de la prestación', 16,1) 
                RETURN  
            END;
            
            INSERT INTO @Fechas
            EXEC [App].[spListaFechas] @FechaAntiguedad,@MaxFechaPrestacion

            IF object_ID('TEMPDB..#TempEmpleadosFechas') IS NOT NULL DROP TABLE #TempEmpleadosFechas

            SELECT M.IDEmpleado,
                CASE WHEN ISNULL(@FechaIngresoVacaciones,0) = 0 THEN M.FechaAntiguedad ELSE M.FechaIngreso END as FechaAntiguedad,
                Fecha.Fecha
                INTO #TempEmpleadosFechas
            FROM RH.tblEmpleadosMaster  M WITH(NOLOCK)
                ,@Fechas  Fecha
            WHERE M.IDEmpleado = @IDEmpleado
            ORDER BY Fecha.Fecha

            
--select * from #TempEmpleadosFechas
            
            IF object_ID('TEMPDB..#TempEmpleadosCalendario') IS NOT NULL DROP TABLE #TempEmpleadosCalendario

			CREATE TABLE #TempEmpleadosCalendario(
				IDEmpleado int,
				FechaAntiguedad date,
				Fecha date,
                FechaIniAntiguedad date,
                FechaFinAntiguedad date,
                IDTipoPrestacion int ,
                FechaIniPrestacion date,
                FechaFinPrestacion date,
                Antiguedad int,
                DiasVacaciones int
				)

			CREATE NONCLUSTERED INDEX idx_Temp_TempEmpleadosCalendario ON #TempEmpleadosCalendario ([IDEmpleado],[Fecha]) INCLUDE ([FechaAntiguedad],[FechaIniAntiguedad],[FechaFinAntiguedad],[IDTipoPrestacion],[FechaIniPrestacion],[FechaFinPrestacion],[Antiguedad],[DiasVacaciones])
           

			INSERT INTO #TempEmpleadosCalendario
            select F.IDEmpleado,
                F.FechaAntiguedad,
                F.Fecha,
                DATEADD(YEAR,TPD.Antiguedad-1,F.FechaAntiguedad) FechaIniAntiguedad,
                DATEADD(DAY,-1,DATEADD(YEAR,TPD.Antiguedad,F.FechaAntiguedad)) FechaFinAntiguedad,
                CASE WHEN ISNULL(@SegmentacionPrestacion,0) = 1 THEN TPD.IDTipoPrestacion
                        ELSE (Select IDTipoPrestacion from RH.tblPrestacionesEmpleado WITH(NOLOCK) where IDEmpleado = F.IDEmpleado AND FechaIni<= DATEADD(DAY,-1,DATEADD(YEAR,TPD.Antiguedad,F.FechaAntiguedad)) AND FechaFin >= DATEADD(DAY,-1,DATEADD(YEAR,TPD.Antiguedad,F.FechaAntiguedad)) )--MAX(TPD.IDTipoPrestacion) OVER (PARTITION BY TPD.Antiguedad order by F.Fecha  ) 
                        END as IDTipoPrestacion,
                PE.FechaIni as FechaIniPrestacion,
                PE.FechaFin as FechaFinPrestacion,
                TPD.Antiguedad,
                DiasVacaciones = CASE WHEN ISNULL(@SegmentacionPrestacion,0) = 1 THEN TPD.DiasVacaciones
                            ELSE (Select ISNULL(DiasVacaciones,0) + ISNULL(DiasExtras,0) from RH.tblPrestacionesEmpleado pr WITH(NOLOCK) Inner join RH.tblCatTiposPrestacionesDetalle det on pr.IDTipoPrestacion = det.IDTipoPrestacion where IDEmpleado = F.IDEmpleado AND  FLOOR(DATEDIFF(DAY,F.FechaAntiguedad, F.Fecha)/365.2425)+1 = Antiguedad AND FechaIni<= DATEADD(DAY,-1,DATEADD(YEAR,TPD.Antiguedad,F.FechaAntiguedad)) AND FechaFin >= DATEADD(DAY,-1,DATEADD(YEAR,TPD.Antiguedad,F.FechaAntiguedad)) )
                            END
            from #TempEmpleadosFechas F
                left join RH.tblPrestacionesEmpleado PE with(nolock)
                    on F.IDEmpleado = PE.IDEmpleado
                    and F.Fecha Between PE.FechaIni and PE.FechaFin
                left join RH.tblCatTiposPrestacionesDetalle TPD with(nolock)
                    on PE.IDTipoPrestacion = TPD.IDTipoPrestacion
                    and FLOOR(DATEDIFF(DAY,F.FechaAntiguedad, F.Fecha)/365.2425)+1 = TPD.Antiguedad
            ORDER BY f.Fecha

        

            IF object_ID('TEMPDB..#TempEmpleadosFactor') IS NOT NULL DROP TABLE #TempEmpleadosFactor

            SELECT IDEmpleado,
                    FechaAntiguedad,
                    FechaIniAntiguedad,
                    FechaFinAntiguedad,
                    IDTipoPrestacion,
                    Antiguedad,
                    FechaIniPrestacion,
                    FechaFinPrestacion,
                    DiasVacaciones,
                    COUNT(*) DiasEnPrestacion,
                    (DiasVacaciones / 365.2425) Factor,
                    CASE
                                WHEN FechaIniPrestacion IS NULL THEN FechaIniAntiguedad -- NO HUBO CAMBIO
                                WHEN FechaIniPrestacion<= FechaIniAntiguedad and FechaFinPrestacion>FechaFinAntiguedad THEN FechaIniAntiguedad --TODO EL AÑO TUVO LA MISMA PRESTACION
                                WHEN FechaIniPrestacion<FechaIniAntiguedad and FechaFinPrestacion between FechaIniAntiguedad and FechaFinAntiguedad THEN FechaIniAntiguedad---YA TENIA LA PRESTACION ANTES DEL BLOQUE PERO NO TERMINO EL BLOQUE CON ELLA
                                WHEN FechaFinPrestacion>FechaFinAntiguedad and FechaIniPrestacion between FechaIniAntiguedad and FechaFinAntiguedad THEN FechaIniPrestacion --
                                WHEN (FechaIniPrestacion between FechaIniAntiguedad and FechaFinAntiguedad) and (FechaFinPrestacion between FechaIniAntiguedad and FechaFinAntiguedad) THEN FechaIniPrestacion
                                
                        END as  FechaCalculada,
                        DATEADD(DAY,-1,LEAD(
                            CASE
                                    WHEN FechaIniPrestacion IS NULL THEN FechaIniAntiguedad -- NO HUBO CAMBIO
                                    WHEN FechaIniPrestacion<= FechaIniAntiguedad and FechaFinPrestacion>FechaFinAntiguedad THEN FechaIniAntiguedad --TODO EL AÑO TUVO LA MISMA PRESTACION
                                    WHEN FechaIniPrestacion<FechaIniAntiguedad and FechaFinPrestacion between FechaIniAntiguedad and FechaFinAntiguedad THEN FechaIniAntiguedad---YA TENIA LA PRESTACION ANTES DEL BLOQUE PERO NO TERMINO EL BLOQUE CON ELLA
                                    WHEN FechaFinPrestacion>FechaFinAntiguedad and FechaIniPrestacion between FechaIniAntiguedad and FechaFinAntiguedad THEN FechaIniPrestacion --
                                    WHEN (FechaIniPrestacion between FechaIniAntiguedad and FechaFinAntiguedad) and (FechaFinPrestacion between FechaIniAntiguedad and FechaFinAntiguedad) THEN FechaIniPrestacion
                                
                            END
                        )OVER(ORDER BY CASE
                                    WHEN FechaIniPrestacion IS NULL THEN FechaIniAntiguedad -- NO HUBO CAMBIO
                                    WHEN FechaIniPrestacion<= FechaIniAntiguedad and FechaFinPrestacion>FechaFinAntiguedad THEN FechaIniAntiguedad --TODO EL AÑO TUVO LA MISMA PRESTACION
                                    WHEN FechaIniPrestacion<FechaIniAntiguedad and FechaFinPrestacion between FechaIniAntiguedad and FechaFinAntiguedad THEN FechaIniAntiguedad---YA TENIA LA PRESTACION ANTES DEL BLOQUE PERO NO TERMINO EL BLOQUE CON ELLA
                                    WHEN FechaFinPrestacion>FechaFinAntiguedad and FechaIniPrestacion between FechaIniAntiguedad and FechaFinAntiguedad THEN FechaIniPrestacion --
                                    WHEN (FechaIniPrestacion between FechaIniAntiguedad and FechaFinAntiguedad) and (FechaFinPrestacion between FechaIniAntiguedad and FechaFinAntiguedad) THEN FechaIniPrestacion
                                
                            END ASC)  )FechaFinCalculada
            into #TempEmpleadosFactor
            FROM #TempEmpleadosCalendario
            WHERE Antiguedad is not null
            GROUP BY IDEmpleado,
                    FechaAntiguedad,
                    FechaIniAntiguedad,
                    FechaFinAntiguedad,
                    IDTipoPrestacion,
                    Antiguedad,
                    FechaIniPrestacion,
                    FechaFinPrestacion,
                    DiasVacaciones
                ORDER BY Antiguedad

            --select * from #TempEmpleadosFactor

            IF object_ID('TEMPDB..#TempEmpleadosFactorGeneral') IS NOT NULL DROP TABLE #TempEmpleadosFactorGeneral

            SELECT c.*, F.Factor
                    , SUM(F.Factor) OVER (ORDER BY Fecha ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS FactorAcumulado
                    , CEILING(SUM(F.Factor) OVER (ORDER BY Fecha ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS FactorAbsoluto
                into #TempEmpleadosFactorGeneral
            FROM #TempEmpleadosCalendario c
            inner join #TempEmpleadosFactor F
                on c.IDEmpleado = F.IDEmpleado
                and c.Fecha Between F.FechaCalculada and F.FechaFinCalculada
           
    IF object_ID('TEMPDB..#TempEmpleadosFactorGeneralFinal') IS NOT NULL DROP TABLE #TempEmpleadosFactorGeneralFinal
            
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY FactorAbsoluto ORDER BY TotalDias desc) AS RNLeastTotal
        INTO #TempEmpleadosFactorGeneralFinal
    FROM
    (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY FactorAbsoluto ORDER BY Fecha DESC) AS RN,
            ROW_NUMBER() OVER (PARTITION BY FactorAbsoluto, IDTipoPrestacion ORDER BY Fecha DESC) AS RN2,
            COUNT(*) OVER (PARTITION BY FactorAbsoluto, IDTipoPrestacion) AS TotalDias
        FROM 
            #TempEmpleadosFactorGeneral
    ) AS t where rn = 1 or rn2 = 1

    Delete from #TempEmpleadosFactorGeneralFinal where RNLeastTotal <> 1


			BEGIN TRAN TransVacacionesEmpleado   
            
            DELETE FROM Asistencia.tblSaldoVacacionesEmpleado WHERE IDEmpleado = @IDEmpleado AND (ISNULL(@FechaIngresoVacaciones,0) = 1 OR (ISNULL(@FechaIngresoVacaciones,0) = 0 AND IDMovAfiliatorio = @IDMovAfiliatorio)) 

            INSERT INTO Asistencia.tblSaldoVacacionesEmpleado(IDEmpleado,Anio,IDMovAfiliatorio,IDTipoPrestacion,DiasVigencia,FechaInicio,FechaFin,FechaInicioDisponible,FechaFinDisponible)
            SELECT T.IDEmpleado,
                t.Antiguedad,
                @IDMovAfiliatorio as IDMovAfiliatorio,
                t.IDTipoPrestacion,
                ISNULL(@DiasVigenciaVacaciones,@MaxAñosVigencia) as DiasVigenciaVacaciones,
                T.FechaIniAntiguedad,
                t.FechaFinAntiguedad,
                t.Fecha as FechaInicioDisponible,
                DATEADD(DAY,ISNULL(@DiasVigenciaVacaciones,@MaxAñosVigencia), t.FechaFinAntiguedad) as FechaFinDisponible
                --t.Fecha
                
            FROM
                
                    #TempEmpleadosFactorGeneralFinal
                as t
            WHERE t.FactorAbsoluto > 0
            
            -- - --- --- -- --- --- -- --- -- --- --- -- --- -- --- --- -- -- - --- -- -- -- AJUSTE DE SALDOS --- -- --- -- --- --- -- -- -- -- -- -- -- --- -- -- --- -- -- --- -- -- --- ---


                    Declare 
                    @DiasInsertar int,
                    @DiasAjuste int,
                    @IDAjusteSaldo int,
                    @FechaAjuste DATE


                    Select 
                        @IDAjusteSaldo = IDAjusteSaldo, 
                        @FechaAjuste = FechaAjuste,
                        @DiasAjuste = SaldoFinal 
                    from Asistencia.tblAjustesSaldoVacacionesEmpleado with(nolock)
                        where IDEmpleado = @IDEmpleado 
                        and IDMovAfiliatorio = @IDMovAfiliatorio

                    IF(@DiasAjuste is not null)
                    BEGIN

                        Declare @TempDetalleVacacionesEmpleado [Asistencia].[dtSaldosDeVacaciones]
                        
                        Insert into @TempDetalleVacacionesEmpleado
                        Exec [Asistencia].[spConsultarVacacionesPorAnio] @IDEmpleado = @IDEmpleado , @Date = @FechaAjuste

                        
                        Select 
                            @DiasInsertar = SUM(DiasGenerados) - ISNULL(@DiasAjuste,0)
                        from @TempDetalleVacacionesEmpleado


                        ;WITH CTEVacacionesAjuste AS (
                            SELECT 
                                IDSaldoVacacionEmpleado,
                                ROW_NUMBER() OVER (ORDER BY (FechaInicioDisponible)) AS RowNum 
                            FROM Asistencia.tblSaldoVacacionesEmpleado WITH(NOLOCK)
                                WHERE IDEmpleado = @IDEmpleado
                                and IDMovAfiliatorio = @IDMovAfiliatorio 
                                and IDIncidenciaEmpleado IS NULL 
                                and IDAjusteSaldo IS NULL
                            
                        )


                        UPDATE Vacaciones 
                        SET Vacaciones.IDAjusteSaldo = @IDAjusteSaldo
                        FROM CTEVacacionesAjuste 
                        JOIN Asistencia.tblSaldoVacacionesEmpleado vacaciones WITH(NOLOCK) ON CTEVacacionesAjuste.IDSaldoVacacionEmpleado = vacaciones.IDSaldoVacacionEmpleado
                        WHERE CTEVacacionesAjuste.RowNum <= @DiasInsertar 
                    END

            -- - --- --- -- --- --- -- --- -- --- --- -- --- -- --- --- -- -- - --- -- -- -- AJUSTE DE SALDOS --- -- --- -- --- --- -- -- -- -- -- -- -- --- -- -- --- -- -- --- -- -- --- --- --- 


            -- - --- --- -- --- --- -- --- -- --- --- -- --- -- --- --- -- -- - --- -- -- -- AJUSTE DE INCIDENCIAS --- -- --- -- --- --- -- -- -- -- -- -- -- --- -- -- --- -- -- --- -- -- --- --
                    
                    -- UPDATE Asistencia.tblSaldoVacacionesEmpleado --Validacion para eliminar Incidencias que se insertaron posterior a una fecha de baja.
                    -- set IDIncidenciaEmpleado = NULL
                    -- WHERE IDIncidenciaEmpleado  IN ( 
                    -- SELECT sve.IDIncidenciaEmpleado FROM Asistencia.tblIncidenciaEmpleado ie WITH(NOLOCK) 
                    -- INNER JOIN Asistencia.tblSaldoVacacionesEmpleado sve ON sve.IDIncidenciaEmpleado = ie.IDIncidenciaEmpleado
                    -- WHERE sve.IDEmpleado = @IDEmpleado AND IDIncidencia = 'V' AND Fecha >= @FechaAntiguedad)

                    DECLARE @RowCountIncidencia INT = (SELECT COUNT(*) FROM Asistencia.tblIncidenciaEmpleado WITH(NOLOCK) Where IDEmpleado = @IDEmpleado AND IDIncidencia IN ('V', 'VP') AND Fecha >= @FechaAntiguedad)
                    ,@IDIncidenciaEmpleado INT
                    ,@IDSaldoVacacionEmpleado INT;

                    WHILE (@RowCountIncidencia > 0)
                    BEGIN

                        SELECT 
                            @IDIncidenciaEmpleado = IDIncidenciaEmpleado
                        FROM Asistencia.tblIncidenciaEmpleado with(nolock)
                            Where IDEmpleado = @IDEmpleado 
                            and IDIncidencia in ('V' , 'VP')
                            and Fecha >= @FechaAntiguedad 
                        ORDER BY Fecha DESC OFFSET @RowCountIncidencia - 1 ROWS FETCH NEXT 1 ROWS ONLY;
                            
                        SELECT 
                            TOP 1 @IDSaldoVacacionEmpleado = IDSaldoVacacionEmpleado
                        FROM Asistencia.tblSaldoVacacionesEmpleado SVE with(nolock)
                        INNER JOIN Asistencia.tblIncidenciaEmpleado IE with(nolock) 
                            ON IE.Fecha < SVE.FechaFinDisponible AND IE.IDIncidenciaEmpleado = @IDIncidenciaEmpleado
                        WHERE SVE.IDEmpleado = @IDEmpleado 
                                And SVE.IDMovAfiliatorio = @IDMovAfiliatorio 
                                AND SVE.IDincidenciaEmpleado IS NULL 
                                AND SVE.IDAjusteSaldo IS NULL 
                        ORDER BY SVE.FechaInicioDisponible ASC  

                        Update Asistencia.tblSaldoVacacionesEmpleado
                            Set IDIncidenciaEmpleado = @IDIncidenciaEmpleado
                        Where IDSaldoVacacionEmpleado = @IDSaldoVacacionEmpleado
                        
                        set @RowCountIncidencia -= 1 
                    END
                            
                    
            -- - --- --- -- --- --- -- --- -- --- --- -- --- -- --- --- -- -- - --- -- -- -- AJUSTE DE INCIDENCIAS --- -- --- -- --- --- -- -- -- -- -- -- -- --- -- -- --- -- -- --- -- -- --- --

            -- - --- --- -- --- --- -- --- -- --- --- -- --- -- --- --- -- -- - --- -- -- -- AJUSTE DE FINIQUITOS --- --- --- -- --- --- -- -- -- -- -- -- -- --- -- -- --- -- -- --- -- -- --- --

                    IF EXISTS 
                            (   SELECT TOP 1 1 
                                FROM Nomina.tblControlFiniquitos CF 
                                INNER JOIN Nomina.tblCatPeriodos cp ON CF.idperiodo = cp.idperiodo
                                    WHERE IDEmpleado = @IDEmpleado 
                                    AND FechaAntiguedad =  @FechaAntiguedad 
                                    AND IDEstatusFiniquito = 2
                                    AND cp.Cerrado = 1  )
                    BEGIN

                        Declare 
                        @DiasFiniquito int,
                        @IDFiniquito int,
                        @FechaBajaFiniquito DATE;

                        SELECT 
                        @DiasFiniquito = Floor(DiasVacaciones), 
                        @IDFiniquito = IDFiniquito,
                        @FechaBajaFiniquito = FechaBaja 
                        FROM Nomina.tblControlFiniquitos 
                            WHERE IDEmpleado = @IDEmpleado 
                            AND FechaAntiguedad = @FechaAntiguedad 
                            AND IDEstatusFiniquito = 2


                 

                        ;WITH CTEVacacionesFiniquitos AS (
                                    SELECT 
                                        IDSaldoVacacionEmpleado,
                                        ROW_NUMBER() OVER (ORDER BY (FechaInicioDisponible)) AS RowNum 
                                    FROM Asistencia.tblSaldoVacacionesEmpleado WITH(NOLOCK)
                                        WHERE IDEmpleado = @IDEmpleado
                                        and IDMovAfiliatorio = @IDMovAfiliatorio 
                                        and IDIncidenciaEmpleado IS NULL 
                                        and IDAjusteSaldo IS NULL     
                                        and FechaFinDisponible > @FechaBajaFiniquito                      
                                )

                                

                        UPDATE Vacaciones 
                        SET Vacaciones.IDFiniquito = @IDFiniquito
                        FROM CTEVacacionesFiniquitos 
                        JOIN Asistencia.tblSaldoVacacionesEmpleado vacaciones WITH(NOLOCK) 
                            ON CTEVacacionesFiniquitos.IDSaldoVacacionEmpleado = vacaciones.IDSaldoVacacionEmpleado
                        WHERE CTEVacacionesFiniquitos.RowNum <= @DiasFiniquito 
                    END 
            

			COMMIT TRAN TransVacacionesEmpleado 

            SELECT @JsonOutput = (SELECT
                                @IDEmpleado as IDEmpleado,
                                @IDUsuario as IDUsuario, 
                                ISNULL(@SegmentacionPrestacion,0) AS SegmentacionPrestacion,
                                ISNULL(@IDMovAfiliatorio,0) AS IDMovAfiliatorio,
                                ISNULL(@IDCliente,0) AS IDCliente,
                                ISNULL(@FechaAntiguedad,'9999-01-01') AS FechaAntiguedad,
                                ISNULL(@MaxFechaPrestacion,'9999-01-01') AS MaxFechaPrestacion,
                                ISNULL(@DiasVigenciaVacaciones,@MaxAñosVigencia) AS DiasVigenciaVacaciones
                                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 
            
            exec [log].[spILogHistory]	
			@LogLevel	   = 'INFO'
			,@Mensaje	   = 'VACACIONES GENERADAS CORRECTAMENTE'
			,@IDSource	   = 'STORED-PROCEDURE'
			,@IDCategory   = 'Vacaciones'
			,@IDAplicacion = 'ASISTENCIA'
			,@Data		   = @JsonOutput
			,@IDUsuario		= @IDUsuario
        -- - --- --- -- --- --- -- --- -- --- --- -- --- -- --- --- -- -- - --- -- -- -- AJUSTE DE FINIQUITOS --- --- --- -- --- --- -- -- -- -- -- -- -- --- -- -- --- -- -- --- -- -- --- --
    END TRY
    BEGIN CATCH  
		set @tran = @@TRANCOUNT
		IF (@tran > 0) ROLLBACK TRAN TransVacacionesEmpleado    
			SET @ERROR = ERROR_MESSAGE () 

            SELECT @JsonOutput = (SELECT
                                @IDEmpleado as IDEmpleado,
                                @IDUsuario as IDUsuario, 
                                ISNULL(@SegmentacionPrestacion,0) AS SegmentacionPrestacion,
                                ISNULL(@IDMovAfiliatorio,0) AS IDMovAfiliatorio,
                                ISNULL(@IDCliente,0) AS IDCliente,
                                ISNULL(@FechaAntiguedad,'9999-01-01') AS FechaAntiguedad,
                                ISNULL(@MaxFechaPrestacion,'9999-01-01') AS MaxFechaPrestacion,
                                ISNULL(@DiasVigenciaVacaciones,@MaxAñosVigencia) AS DiasVigenciaVacaciones
                                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 

            exec [log].[spILogHistory]	
			@LogLevel	   = 'ERROR'
			,@Mensaje	   = @ERROR
			,@IDSource	   = 'STORED-PROCEDURE'
			,@IDCategory   = 'Vacaciones'
			,@IDAplicacion = 'ASISTENCIA'
			,@Data		   = @JsonOutput
			,@IDUsuario		= @IDUsuario

        EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1700002', @CustomMessage= @ERROR
    END CATCH
END
GO

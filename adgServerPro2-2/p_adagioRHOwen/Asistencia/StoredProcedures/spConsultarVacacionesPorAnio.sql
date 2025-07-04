USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Consulta el Saldo de vacaciones de un colaborador directa,ente de la tabla [Asistencia].[tblSaldoVacacionesEmpleado] .
** Autor   : Julio Castillo  
** Email   : jcastillo@adagio.com.mx  
** FechaCreacion : 2019-01-01  
** Paremetros  :                
  
 Si se modifica el result set de este sp será necesario modificar los siguientes SP's:  
  [Asistencia].[spBuscarVacacionesPendientesEmpleado]  
  
** DataTypes Relacionados:   [Asistencia].[dtSaldosDeVacaciones]  
  
  SELECT * from RH.tblEmpleadosMaster where claveEmpleado= 'adg0001'
[Asistencia].[spBuscarSaldosVacacionesPorAnios] 1279,1,NULL,1  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  

[Asistencia].[spConsultarVacacionesPorAnio] @IDEmpleado = 17260,@Proporcional = 1,@Date = '2027-01-23'

***************************************************************************************************/  
 CREATE PROC [Asistencia].[spConsultarVacacionesPorAnio] (  
    @IDEmpleado INT, 
	@IDUsuario	INT  = 1,
    @Date DATE = NULL,
    @Proporcional BIT = NULL,
    @IDMovimientoBaja int = 0
) AS  
BEGIN

    IF(@DATE is NULL) SET @DATE = GETDATE()


    DECLARE 
    @DiasProporcional INT = 0,
    @FechaIngresoVacaciones bit,
    @FechaAntiguedad DATE,
    @IDMovAfiliatorio INT,
    @MaxFechaAdelantada DATE,
    @ConfigDecimalesPorporcional INT  


    IF object_id('tempdb..#tempMovimientosAfiliatorios') IS NOT NULL DROP TABLE #tempMovimientosAfiliatorios; 
    IF object_id('tempdb..#tempCatTipoMovimiento') IS NOT NULL DROP TABLE #tempCatTipoMovimiento; 
    IF object_id('tempdb..#tempMovAfil') IS NOT NULL DROP TABLE #tempMovAfil; 
    


    SELECT TOP 1 @FechaIngresoVacaciones = CASE WHEN cast(isNULL(Valor,0) as BIT)  = 0 THEN 0  ELSE Cast(isNULL(Valor,0) AS BIT)  END
                FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
                INNER JOIN RH.tblEmpleadosMaster e WITH(NOLOCK) on e.IDCliente = c.IDCliente   
                WHERE e.IDEmpleado = @IDEmpleado  AND IDTipoConfiguracionCliente = 'FechaIngresoVacaciones'

    SELECT TOP 1 @ConfigDecimalesPorporcional = CASE WHEN cast(isNULL(Valor,0) as BIT)  = 0 THEN 0  ELSE Cast(isNULL(Valor,0) AS BIT)  END
                FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
                INNER JOIN RH.tblEmpleadosMaster e WITH(NOLOCK) on e.IDCliente = c.IDCliente   
                WHERE e.IDEmpleado = @IDEmpleado  AND IDTipoConfiguracionCliente = 'ConfigDecimalesProporcional'

                
    IF(@IDMovimientoBaja != 0)
    BEGIN
    SELECT @IDMovAfiliatorio = IDMovAfiliatorio 
            from IMSS.tblMovAfiliatorios m
            inner join IMSS.tblCatTipoMovimientos tm on m.IDTipoMovimiento = tm.IDTipoMovimiento
            where Fecha = (Select FechaAntiguedad 
                                    from IMSS.tblMovAfiliatorios 
                                    where IDMovAfiliatorio = @IDMovimientoBaja) 
            AND IDEmpleado = @IDEmpleado 
            AND tm.Descripcion in ('ALTA','REINGRESO')
    END
    ELSE
    BEGIN
        IF(ISNULL(@FechaIngresoVacaciones,0) = 0)
                BEGIN
                    SELECT 
                        @IDMovAfiliatorio = mov.IDMovAfiliatorio, 
                        @FechaAntiguedad =  M.FechaAntiguedad
                        
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
                        @FechaAntiguedad =  M.FechaIngreso                   
                    FROM IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
                        INNER JOIN RH.tblEmpleadosMaster  M WITH(NOLOCK)
                            ON Mov.IDEmpleado = M.IDEmpleado
                            AND Mov.Fecha = M.FechaAntiguedad 
                        WHERE M.IDEmpleado = @IDEmpleado
                END
    END

    IF(@IDMovAfiliatorio IS NULL) 
    BEGIN  
        RAISERROR('No se encontró ningún movimiento afiliatorio; Revisar la fecha de Ingreso o Antiguedad del colaborador', 16,1)
        RETURN			
    END


    IF(@DiasProporcional IS NOT NULL AND DATEDIFF(DAY,@FechaAntiguedad,@Date)  <  @DiasProporcional) 
    BEGIN
        DECLARE @Mensaje VARCHAR(max) = 'Faltan ' + CAST(ABS(DATEDIFF(DAY,@FechaAntiguedad,@Date) - @DiasProporcional) AS VARCHAR(max)) + ' días para poder completar su proporcional del primer año'
        RAISERROR(@Mensaje, 16,1)
        RETURN			
    END
    IF(@Proporcional IS NULL)
        BEGIN
            IF EXISTS (SELECT TOP 1 1  
                        FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
                        INNER JOIN RH.tblEmpleadosMaster e WITH(NOLOCK) ON e.IDCliente = c.idcliente   
                        WHERE e.IDEmpleado = @IDEmpleado  AND IDTipoConfiguracionCliente = 'VacacionesProporcionales')  
            BEGIN  
                SELECT TOP 1 @Proporcional = CASE WHEN cast(isNULL(Valor,0) as BIT)  = 0 THEN 0  ELSE Cast(isNULL(Valor,0) AS BIT)  END
                FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
                INNER JOIN RH.tblEmpleadosMaster e WITH(NOLOCK) on e.IDCliente = c.idcliente   
                WHERE e.IDEmpleado = @IDEmpleado  AND IDTipoConfiguracionCliente = 'VacacionesProporcionales'
            END ELSE   
            BEGIN  
                SET @Proporcional = 0
            END; 
        END

    IF @Proporcional = 0
    BEGIN
            SELECT 
            anio,
            FechaInicio as FechaIni,
            FechaFin,
            (SELECT TOP 1 DiasVacaciones 
                FROM rh.tblCatTiposPrestacionesDetalle TPD 
            WHERE TPD.Antiguedad = VE.anio 
            AND TPD.IDTipoPrestacion = TP.IDTipoPrestacion) AS Dias,
            COUNT(*) AS DiasGenerados,
            COUNT(IDincidenciaEmpleado) + COUNT(IDAjusteSaldo ) + COUNT(IDFiniquito) AS DiasTomados,
            COUNT(CASE WHEN IDincidenciaEmpleado IS NULL AND IDAjusteSaldo IS NULL AND IDFiniquito IS NULL AND FechaFinDisponible <= @Date THEN 1 END) AS DiasVencidos,
            COUNT(CASE WHEN IDincidenciaEmpleado IS NULL AND IDAjusteSaldo IS NULL AND IDFiniquito IS NULL AND FechaFinDisponible > @Date THEN 1 END) AS DiasDisponibles,
            TP.Descripcion as TipoPrestacion,
            FechaInicio as FechaIniDisponible,
            FechaFinDisponible
        FROM Asistencia.tblSaldoVacacionesEmpleado VE WITH(NOLOCK)
        INNER JOIN RH.TblCatTiposPrestaciones TP ON TP.IDTipoPrestacion = VE.IDTipoPrestacion
        WHERE 
            IDEmpleado = @IDEmpleado
            AND IDMovAfiliatorio = @IDMovAfiliatorio
            AND FechaInicioDisponible <= @Date
            AND FechaFin <= @Date
        GROUP BY 
        IDempleado, Anio, FechaInicio, FechaFin,FechaFinDisponible, TP.Descripcion,tp.IDTipoPrestacion 
        ORDER BY ANIO DESC
    END
    ELSE IF @Proporcional = 1
    BEGIN  
    IF object_id('tempdb..#TempVacacionesRef') IS NOT NULL DROP TABLE #TempVacacionesRef; 

        IF @ConfigDecimalesPorporcional = 1
        BEGIN
                SELECT 
                anio,
                FechaInicio as FechaIni,
                FechaFin,
                ( SELECT TOP 1 DiasVacaciones 
                    FROM rh.tblCatTiposPrestacionesDetalle TPD 
                    WHERE TPD.Antiguedad = VE.anio 
                    AND TPD.IDTipoPrestacion = TP.IDTipoPrestacion ) AS Dias,
                CAST ( ( ( SELECT TOP 1 DiasVacaciones 
                    FROM rh.tblCatTiposPrestacionesDetalle TPD 
                    WHERE TPD.Antiguedad = VE.anio 
                    AND TPD.IDTipoPrestacion = TP.IDTipoPrestacion ) / 365.24 * ( DATEDIFF( DAY,FechaInicio,CASE WHEN @Date > FechaFin then FechaFin else @Date END ) ) ) As Decimal(10,2) ) AS ProporcionalDecimal,
                COUNT(*) AS DiasGenerados,
                COUNT(IDincidenciaEmpleado) + COUNT(IDAjusteSaldo ) + COUNT(IDFiniquito) AS DiasTomados,
                COUNT(CASE WHEN IDincidenciaEmpleado IS NULL AND IDAjusteSaldo IS NULL AND IDFiniquito IS NULL AND FechaFinDisponible <= @Date THEN 1 END) AS DiasVencidos,
                COUNT(CASE WHEN IDincidenciaEmpleado IS NULL AND IDAjusteSaldo IS NULL AND IDFiniquito IS NULL AND FechaFinDisponible > @Date THEN 1 END) AS DiasDisponibles,
                TP.Descripcion as TipoPrestacion,
                FechaInicio as FechaIniDisponible,
                FechaFinDisponible

                INTO #TempVacacionesRef

                FROM Asistencia.tblSaldoVacacionesEmpleado VE WITH(NOLOCK)
                INNER JOIN RH.TblCatTiposPrestaciones TP ON TP.IDTipoPrestacion = VE.IDTipoPrestacion
                WHERE 
                    IDEmpleado = @IDEmpleado
                    AND IDMovAfiliatorio = @IDMovAfiliatorio
                    AND FechaInicioDisponible <= @Date
                GROUP BY 
                    IDempleado, Anio, FechaInicio, FechaFin,FechaFinDisponible, TP.Descripcion,tp.IDTipoPrestacion;                 
                        
                WITH MaxYear AS (
                    SELECT MAX(Anio) AS MaxAnio
                    FROM #TempVacacionesRef
                )
                Select 
                [Anio],
                [FechaIni],
                [FechaFin],
                [Dias],
                CAST( CASE WHEN anio = (SELECT Maxanio FROM MaxYear ) 
                        THEN DiasGenerados + CASE WHEN DiasGenerados < ProporcionalDecimal 
                                                THEN (ProporcionalDecimal - FLOOR(ProporcionalDecimal) ) 
                                                ELSE 0 END
                        ELSE [DiasGenerados] END AS DECIMAL(10,2)) 
                AS  [DiasGenerados],
                [DiasTomados],
                [DiasVencidos],
                [DiasDisponibles],
                [TipoPrestacion],
                [FechaIniDisponible],
                [FechaFinDisponible] from #TempVacacionesRef ORDER BY ANIO DESC
        END
        
        ELSE 
        BEGIN 
                SELECT 
                anio,
                FechaInicio as FechaIni,
                FechaFin,
                (SELECT TOP 1 DiasVacaciones 
                    FROM rh.tblCatTiposPrestacionesDetalle TPD 
                WHERE TPD.Antiguedad = VE.anio 
                AND TPD.IDTipoPrestacion = TP.IDTipoPrestacion) AS Dias,
                COUNT(*) AS DiasGenerados,
                COUNT(IDincidenciaEmpleado) + COUNT(IDAjusteSaldo ) + COUNT(IDFiniquito) AS DiasTomados,
                COUNT(CASE WHEN IDincidenciaEmpleado IS NULL AND IDAjusteSaldo IS NULL AND IDFiniquito IS NULL AND FechaFinDisponible <= @Date THEN 1 END) AS DiasVencidos,
                COUNT(CASE WHEN IDincidenciaEmpleado IS NULL AND IDAjusteSaldo IS NULL AND IDFiniquito IS NULL AND FechaFinDisponible > @Date THEN 1 END) AS DiasDisponibles,
                TP.Descripcion as TipoPrestacion,
                FechaInicio as FechaIniDisponible,
                FechaFinDisponible
            FROM Asistencia.tblSaldoVacacionesEmpleado VE WITH(NOLOCK)
            INNER JOIN RH.TblCatTiposPrestaciones TP ON TP.IDTipoPrestacion = VE.IDTipoPrestacion
            WHERE 
                IDEmpleado = @IDEmpleado
                AND IDMovAfiliatorio = @IDMovAfiliatorio
                AND FechaInicioDisponible <= @Date
            GROUP BY 
            IDempleado, Anio, FechaInicio, FechaFin,FechaFinDisponible, TP.Descripcion,tp.IDTipoPrestacion 
            ORDER BY ANIO DESC
            END

    END   
END
GO

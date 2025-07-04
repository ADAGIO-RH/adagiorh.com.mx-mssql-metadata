USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Consulta el Saldo de vacaciones de un colaborador.
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



***************************************************************************************************/  
 CREATE    PROC [Asistencia].[spCoreBuscarSaldoVacacionesPorAnioNew](  
    @IDEmpleado INT, 
	@IDUsuario	INT  = 1,
    @Date DATE = NULL,
    @Proporcional BIT = NULL
) AS  
BEGIN

    IF(@DATE is NULL) SET @DATE = GETDATE()


    DECLARE 
    @DiasProporcional INT = 0,
    @FechaIngresoVacaciones bit,
    @FechaAntiguedad DATE,
    @IDMovAfiliatorio INT,
    @MaxFechaAdelantada DATE


    IF object_id('tempdb..#tempMovimientosAfiliatorios') IS NOT NULL DROP TABLE #tempMovimientosAfiliatorios; 
    IF object_id('tempdb..#tempCatTipoMovimiento') IS NOT NULL DROP TABLE #tempCatTipoMovimiento; 
    IF object_id('tempdb..#tempMovAfil') IS NOT NULL DROP TABLE #tempMovAfil; 


    SELECT TOP 1 @FechaIngresoVacaciones = CASE WHEN cast(isNULL(Valor,0) as BIT)  = 0 THEN 0  ELSE Cast(isNULL(Valor,0) AS BIT)  END
                FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
                INNER JOIN RH.tblEmpleadosMaster e WITH(NOLOCK) on e.IDCliente = c.IDCliente   
                WHERE e.IDEmpleado = @IDEmpleado  AND IDTipoConfiguracionCliente = 'FechaIngresoVacaciones'

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

    IF(@IDMovAfiliatorio IS NULL) BEGIN
    
    RAISERROR('No se encontró ningún movimiento afiliatorio; Revisar la fecha de Ingreso o Antiguedad del colaborador', 16,1)
    RETURN			
    END


    IF(@DiasProporcional IS NOT NULL AND DATEDIFF(DAY,@FechaAntiguedad,@Date)  <  @DiasProporcional) BEGIN
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


        Print 'NORMAL'
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    SELECT 
        anio,
        FechaInicio as FechaIni,
        FechaFin,
        COUNT(*) AS Dias,
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
        AND FechaInicioDisponible <= @Date';

    IF @Proporcional = 0
    BEGIN
        SET @SQL = @SQL + ' AND FechaFin <= @Date';
    END

    SET @SQL = @SQL + '
    GROUP BY 
        IDempleado, Anio, FechaInicio, FechaFin,FechaFinDisponible, TP.Descripcion 
        ORDER BY Anio DESC;';

    EXEC sp_executesql @SQL, N'@Date DATE, @IDEmpleado INT, @IDMovAfiliatorio INT', @Date = @Date, @IDEmpleado = @IDEmpleado, @IDMovAfiliatorio = @IDMovAfiliatorio;
    --END


END
GO

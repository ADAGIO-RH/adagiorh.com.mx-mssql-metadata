USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : Consulta el total de días disponibles de vacaciones de colaboradores.
** Autor        : ANEUDY ABREU
** Email        : aabreu@adagio.com.mx  
** FechaCreacion: 2024-11-03  
** Paremetros   : @IDCliente INT, @IDUsuario INT, @Date DATE, @Proporcional BIT                
*****************************************************************************************************/  
CREATE   PROC [Asistencia].[spBuscarTotalDiasDisponiblesVacaciones] (
	@empleados [RH].[dtEmpleados] readonly,
    @IDCliente INT,
    @IDUsuario INT,
    @Date DATE = NULL,
    @Proporcional BIT = NULL
) AS  
BEGIN

    IF(@DATE is NULL) SET @DATE = GETDATE()

    -- Tabla temporal para almacenar la información de los empleados
    CREATE TABLE #TempEmpleados (
        IDEmpleado INT,
        FechaAntiguedad DATE,
        IDMovAfiliatorio INT
    )

    DECLARE @FechaIngresoVacaciones bit

    -- Obtener configuración de FechaIngresoVacaciones por cliente
    SELECT TOP 1 @FechaIngresoVacaciones = CASE WHEN cast(isNULL(Valor,0) as BIT) = 0 THEN 0 ELSE Cast(isNULL(Valor,0) AS BIT) END
    FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
    WHERE c.IDcliente = @IDCliente AND IDTipoConfiguracionCliente = 'FechaIngresoVacaciones'

    -- Insertar datos de empleados según la configuración de FechaIngresoVacaciones
    IF(ISNULL(@FechaIngresoVacaciones,0) = 0)
    BEGIN
        INSERT INTO #TempEmpleados (IDEmpleado, FechaAntiguedad, IDMovAfiliatorio)
        SELECT 
            M.IDEmpleado,
            M.FechaAntiguedad,
            Mov.IDMovAfiliatorio
        FROM RH.tblEmpleadosMaster M WITH(NOLOCK)
        LEFT JOIN IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
            ON Mov.IDEmpleado = M.IDEmpleado
            AND Mov.Fecha = M.FechaAntiguedad
        WHERE M.IDCliente = @IDCliente
    END
    ELSE 
    BEGIN
        INSERT INTO #TempEmpleados (IDEmpleado, FechaAntiguedad, IDMovAfiliatorio)
        SELECT 
            M.IDEmpleado,
            M.FechaIngreso,
            Mov.IDMovAfiliatorio
        FROM RH.tblEmpleadosMaster M WITH(NOLOCK)
        LEFT JOIN IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
            ON Mov.IDEmpleado = M.IDEmpleado
            AND Mov.Fecha = M.FechaIngreso
        WHERE M.IDCliente = @IDCliente
    END

    -- Manejo de configuración de vacaciones proporcionales por cliente
    IF(@Proporcional IS NULL)
    BEGIN
        SELECT TOP 1 @Proporcional = CASE 
            WHEN cast(isNULL(Valor,0) as BIT) = 0 THEN 0 
            ELSE Cast(isNULL(Valor,0) AS BIT) 
        END
        FROM RH.TblConfiguracionesCliente c WITH (NOLOCK)
        WHERE c.IDCliente = @IDCliente 
        AND IDTipoConfiguracionCliente = 'VacacionesProporcionales'

        SET @Proporcional = ISNULL(@Proporcional, 0)
    END

    -- Query principal para obtener saldos de vacaciones
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = '
    SELECT 
        VE.IDEmpleado,
        E.ClaveEmpleado,
        E.Nombre,
		E.SegundoNombre,
        E.Paterno,
        E.Materno,
			MAX(VE.FechaInicio) as FechaInicio,
		MAX(VE.FechaFin) as FechaFin,
        COUNT(CASE WHEN IDincidenciaEmpleado IS NULL 
                   AND IDAjusteSaldo IS NULL 
                   AND IDFiniquito IS NULL 
                   AND FechaFinDisponible > @Date THEN 1 END) AS DiasDisponibles,
        TE.FechaAntiguedad,
        DATEDIFF(YEAR, TE.FechaAntiguedad, @Date) as AniosAntiguedad
    FROM #TempEmpleados TE
    INNER JOIN Asistencia.tblSaldoVacacionesEmpleado VE WITH(NOLOCK)
        ON TE.IDEmpleado = VE.IDEmpleado
        AND TE.IDMovAfiliatorio = VE.IDMovAfiliatorio
    INNER JOIN RH.tblEmpleadosMaster E WITH(NOLOCK)
        ON E.IDEmpleado = VE.IDEmpleado
    INNER JOIN RH.TblCatTiposPrestaciones TP 
        ON TP.IDTipoPrestacion = VE.IDTipoPrestacion
    WHERE FechaInicioDisponible <= @Date';

    IF @Proporcional = 0
    BEGIN
        SET @SQL = @SQL + ' AND FechaFin <= @Date';
    END

    SET @SQL = @SQL + '
    GROUP BY 
        VE.IDEmpleado,
        E.ClaveEmpleado,
        E.Nombre,
		E.SegundoNombre,
        E.Paterno,
        E.Materno,
        TE.FechaAntiguedad
    ORDER BY E.ClaveEmpleado';

    EXEC sp_executesql @SQL, 
        N'@Date DATE', 
        @Date = @Date;

    -- Limpieza
    DROP TABLE #TempEmpleados
END
GO

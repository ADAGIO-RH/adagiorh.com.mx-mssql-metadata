USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCambiarEstatusControlAumentosDesempeno](    
    @IDControlAumentosDesempeno INT,
    @Aplicar BIT = 0,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @EstatusActual BIT,
        @IDRazonMovimiento INT,
        @FechaMovAfiliatorio DATE,
        @ID_TIPO_MOVIMIENTO_MOVIMIENTO_SALARIAL INT = 4;

    -- Obtener datos necesarios del control
    SELECT 
        @EstatusActual = Aplicado,
        @IDRazonMovimiento = IDRazonMovimiento,
        @FechaMovAfiliatorio = FechaMovAfiliatorio
    FROM Nomina.tblControlAumentosDesempeno
    WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

    -- Validaciones
    IF @Aplicar = 1 AND @Aplicar = @EstatusActual
    BEGIN
        RAISERROR('No se puede aplicar un cálculo que ya fue aplicado', 16, 1);
        RETURN;
    END

    IF @Aplicar = 0 AND @Aplicar = @EstatusActual
    BEGIN
        RAISERROR('No se puede desaplicar un cálculo que no ha sido aplicado', 16, 1);
        RETURN;
    END

    IF ISNULL(@IDRazonMovimiento, 0) = 0
    BEGIN
        RAISERROR('Para poder aplicar el cálculo debe configurar una razón de movimiento afiliatorio', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Aplicar = 1
        BEGIN
            if object_id('tempdb..#MovimientosGenerados') is not null drop table #MovimientosGenerados;
            -- Crear tabla temporal para los movimientos generados
            CREATE TABLE #MovimientosGenerados (
                IDMovAfiliatorio INT,
                IDEmpleado INT
            );

            -- Insertar movimientos afiliatorios
            INSERT INTO IMSS.tblMovAfiliatorios (
                Fecha,
                IDEmpleado,
                IDTipoMovimiento,
                IDRazonMovimiento,
                SalarioDiario,
                SalarioIntegrado,
                SalarioVariable,
                SalarioDiarioReal,
                IDRegPatronal,
                IDTipoPrestacion,
                FechaAntiguedad
            )
            OUTPUT INSERTED.IDMovAfiliatorio, INSERTED.IDEmpleado INTO #MovimientosGenerados
            SELECT 
                @FechaMovAfiliatorio,
                d.IDEmpleado,
                @ID_TIPO_MOVIMIENTO_MOVIMIENTO_SALARIAL,
                @IDRazonMovimiento,
                d.SalarioDiarioMovimiento,
                d.SalarioIntegradoMovimiento,
                d.SalarioVariableMovimiento,
                d.SalarioDiarioRealMovimiento,
                d.IDRegPatronal,
                d.IDTipoPrestacion,
                d.FechaAntiguedad
            FROM Nomina.TblControlAumentosDesempenoDetalle d
            WHERE d.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
                AND d.ExcluirColaborador = 0
                AND NOT EXISTS (
                    SELECT 1 
                    FROM IMSS.tblMovAfiliatorios m
                    WHERE m.Fecha = @FechaMovAfiliatorio
                        AND m.IDEmpleado = d.IDEmpleado                        
                );

            -- Actualizar los IDs de movimientos en la tabla detalle
            UPDATE d
            SET d.IDMovAfiliatorio = m.IDMovAfiliatorio
            FROM Nomina.TblControlAumentosDesempenoDetalle d
            INNER JOIN #MovimientosGenerados m ON d.IDEmpleado = m.IDEmpleado
            WHERE d.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

            -- Actualizar estatus del control
            UPDATE Nomina.tblControlAumentosDesempeno
            SET Aplicado = 1
            WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

            DROP TABLE #MovimientosGenerados;
        END
        ELSE
        BEGIN
            -- Eliminar movimientos afiliatorios
            DELETE m
            FROM IMSS.tblMovAfiliatorios m
            INNER JOIN Nomina.TblControlAumentosDesempenoDetalle d 
                ON m.IDMovAfiliatorio = d.IDMovAfiliatorio
            WHERE d.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

            -- Limpiar referencias a movimientos
            UPDATE Nomina.TblControlAumentosDesempenoDetalle
            SET IDMovAfiliatorio = NULL
            WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

            -- Actualizar estatus del control
            UPDATE Nomina.tblControlAumentosDesempeno
            SET Aplicado = 0
            WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
        END

        -- Sincronizar empleados master
        EXEC [RH].[spSincronizarEmpleadosMaster];

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
    END CATCH;
END
GO

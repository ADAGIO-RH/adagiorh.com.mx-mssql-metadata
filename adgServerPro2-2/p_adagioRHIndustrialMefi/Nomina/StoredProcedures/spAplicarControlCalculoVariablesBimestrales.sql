USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spAplicarControlCalculoVariablesBimestrales](    
    @IDControlCalculoVariables INT,
    @Aplicar BIT = 0,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; 

    DECLARE 
         @IDRegPatronal                             INT,
         @EstatusActualControlCalculoVariables      BIT, 
         @IDRazonMovimiento                         INT = 0,
         @ID_TIPO_MOVIMIENTO_MOVIMIENTO_SALARIAL    INT = 4,
         @OldJSON                                   VARCHAR(MAX) = '',
         @NewJSON                                   VARCHAR(MAX),
         @NombreSP                                  VARCHAR(MAX) = '[Nomina].[spAplicarControlCalculoVariablesBimestrales]',
         @Tabla                                     VARCHAR(MAX) = '[Nomina].[tblControlCalculoVariablesBimestrales]',
         @Accion                                    VARCHAR(20) = '',
         @Mensaje                                   VARCHAR(MAX),
         @InformacionExtra                          VARCHAR(MAX);

    BEGIN TRY
        
        SELECT 
              @IDRegPatronal = IDRegPatronal,
              @EstatusActualControlCalculoVariables = Aplicar 
        FROM Nomina.tblControlCalculoVariablesBimestrales
        WHERE IDControlCalculoVariables = @IDControlCalculoVariables;
        
        SELECT @IDRazonMovimiento = IDRazonMovimiento
        FROM Nomina.tblConfigReporteVariablesBimestrales;

        SELECT @OldJSON = a.JSON
        FROM (
            SELECT *
            FROM Nomina.tblControlCalculoVariablesBimestrales
            WHERE IDControlCalculoVariables = @IDControlCalculoVariables
        ) b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML Raw))) a;

        
        IF @Aplicar = 1 AND @Aplicar = @EstatusActualControlCalculoVariables
        BEGIN
            RAISERROR('No se puede aplicar un cálculo que ya fue aplicado', 16, 1);  
            RETURN;  
        END

        IF @Aplicar = 0 AND @Aplicar = @EstatusActualControlCalculoVariables
        BEGIN
            RAISERROR('No se puede desaplicar un cálculo que no ha sido aplicado', 16, 1);  
            RETURN;  
        END

        IF ISNULL(@IDRazonMovimiento, 0) = 0
        BEGIN
            RAISERROR('Para poder aplicar el cálculo debe configurar una razón de movimiento afiliatorio, vaya a la configuración general de cálculo de variables', 16, 1);  
            RETURN;  
        END

        
        BEGIN TRANSACTION;
        
        IF ISNULL(@Aplicar, 0) = 1
        BEGIN
            
            IF OBJECT_ID('tempdb..#IdentityMovAfiliatorios') IS NOT NULL DROP TABLE #IdentityMovAfiliatorios;

            CREATE TABLE #IdentityMovAfiliatorios (IDMovAfiliatorio INT, IDEmpleado INT);

            INSERT INTO IMSS.tblMovAfiliatorios(  
                Fecha,  
                IDEmpleado,  
                IDTipoMovimiento,  
                IDRazonMovimiento,  
                SalarioDiario,  
                SalarioIntegrado,  
                SalarioVariable,  
                SalarioDiarioReal,
                IDRegPatronal,
                FechaAntiguedad,
                IDTipoPrestacion
            )  
            OUTPUT INSERTED.IDEmpleado, INSERTED.IDMovAfiliatorio INTO #IdentityMovAfiliatorios (IDEmpleado, IDMovAfiliatorio)
            SELECT 
                DiaAplicacion,  
                IDEmpleado,  				
                @ID_TIPO_MOVIMIENTO_MOVIMIENTO_SALARIAL, 
                @IDRazonMovimiento,  
                CAST(SalarioDiario AS DECIMAL(18,2)) AS SalarioDiario,
                CAST(SalarioIntegrado AS DECIMAL(18,2)) AS SalarioIntegrado, 
                CAST(SalarioVariable AS DECIMAL(18,2)) AS SalarioVariable,
                CAST(SalarioDiarioReal AS DECIMAL(18,2)) AS SalarioDiarioReal,
                @IDRegPatronal, 
                FechaAntiguedad,
                IDTipoPrestacion
            FROM Nomina.TblCalculoVariablesBimestralesMaster d
            WHERE d.IDControlCalculoVariables = @IDControlCalculoVariables
              AND NOT EXISTS ( 
                    SELECT 1
                    FROM IMSS.tblMovAfiliatorios t2
                    WHERE d.DiaAplicacion = t2.Fecha
                      AND d.IDEmpleado = t2.IDEmpleado
                      AND (CAST(d.SalarioDiario AS DECIMAL(18,2)) = CAST(t2.SalarioDiario AS DECIMAL(18,2)))
                      AND (CAST(d.SalarioIntegrado AS DECIMAL(18,2)) = CAST(t2.SalarioIntegrado AS DECIMAL(18,2)))
                      AND (CAST(d.SalarioVariable AS DECIMAL(18,2)) = CAST(t2.SalarioVariable AS DECIMAL(18,2)))
                      AND (CAST(d.SalarioDiarioReal AS DECIMAL(18,2)) = CAST(t2.SalarioDiarioReal AS DECIMAL(18,2)))
                      AND @IDRegPatronal = t2.IDRegPatronal
                ) 
              AND d.AFECTAR = 1; 

            
            IF NOT EXISTS (SELECT TOP 1 1 FROM #IdentityMovAfiliatorios)
            BEGIN
                RAISERROR('No fue posible generar ningun movimiento afiliatorio', 16, 1);  		        
                RETURN;
            END
            
            
            UPDATE Nomina.TblCalculoVariablesBimestralesMaster
            SET IDMovAfiliatorio = registrosInsertados.IDMovAfiliatorio
            FROM Nomina.TblCalculoVariablesBimestralesMaster m
            INNER JOIN #IdentityMovAfiliatorios registrosInsertados
                    ON registrosInsertados.IDEmpleado = m.IDEmpleado
                   AND m.IDControlCalculoVariables = @IDControlCalculoVariables
            WHERE m.IDControlCalculoVariables = @IDControlCalculoVariables 
              AND m.Afectar = 1  
              AND m.IDMovAfiliatorio IS NULL;

            UPDATE Nomina.tblControlCalculoVariablesBimestrales
            SET Aplicar = 1
            WHERE IDControlCalculoVariables = @IDControlCalculoVariables;
            
        END
        ELSE
        BEGIN        
            
            DELETE IMSS.tblMovAfiliatorios
            WHERE IDMovAfiliatorio IN (
                SELECT IDMovAfiliatorio 
                FROM Nomina.TblCalculoVariablesBimestralesMaster BM
                WHERE IDControlCalculoVariables = @IDControlCalculoVariables 
                  AND IDMovAfiliatorio IS NOT NULL
            );

            UPDATE Nomina.tblControlCalculoVariablesBimestrales
            SET Aplicar = 0
            WHERE IDControlCalculoVariables = @IDControlCalculoVariables;

            
        END

        EXEC [RH].[spSincronizarEmpleadosMaster];
        
        SELECT @NewJSON = a.JSON
        FROM (
            SELECT *
            FROM Nomina.tblControlCalculoVariablesBimestrales
            WHERE IDControlCalculoVariables = @IDControlCalculoVariables
        ) b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML Raw))) a;

        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario = @IDUsuario,
            @Tabla = @Tabla,
            @Procedimiento = @NombreSP,
            @Accion = @Accion,
            @NewData = @NewJSON,
            @OldData = @OldJSON,
            @Mensaje = @Mensaje,
            @InformacionExtra = @InformacionExtra;

        
        COMMIT;
    END TRY
    BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK;
        END
        
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();

        THROW;
    END CATCH;
END
GO

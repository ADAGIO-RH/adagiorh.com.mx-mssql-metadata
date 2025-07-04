USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUAumentoMasivoEmpleado]
(
    @IDAumentoMasivoEmpleado INT = 0,
    @IDAumentoMasivo INT,
    @IDEmpleado INT,
    @SalarioDiario DECIMAL(18, 2),
    @SalarioIntegrado DECIMAL(18, 2),
    @SalarioVariable DECIMAL(18, 2),
    @SalarioDiarioReal DECIMAL(18, 2),
    @IDRegPatronal INT,
    @IDMovAfiliatorio INT = NULL,    
    @IDUsuario INT
)
AS
BEGIN
    DECLARE @OldJSON VARCHAR(MAX),
            @NewJSON VARCHAR(MAX);

    IF (@IDAumentoMasivoEmpleado = 0 OR @IDAumentoMasivoEmpleado IS NULL)
    BEGIN
        INSERT INTO [Nomina].[tblAumentoMasivoEmpleado]
        (
            [IDAumentoMasivo],
            [IDEmpleado],
            [SalarioDiario],
            [SalarioIntegrado],
            [SalarioVariable],
            [SalarioDiarioReal],
            [IDRegPatronal],
            [IDMovAfiliatorio]          
        )
        VALUES
        (
            @IDAumentoMasivo,
            @IDEmpleado,
            @SalarioDiario,
            @SalarioIntegrado,
            @SalarioVariable,
            @SalarioDiarioReal,
            @IDRegPatronal,
            @IDMovAfiliatorio            
        );

        SET @IDAumentoMasivoEmpleado = @@IDENTITY;

        SELECT @NewJSON = a.JSON FROM [Nomina].[tblAumentoMasivoEmpleado] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
        WHERE b.[IDAumentoMasivoEmpleado] = @IDAumentoMasivoEmpleado;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblAumentoMasivoEmpleado]', '[Nomina].[spIUAumentoMasivoEmpleado]', 'INSERT', @NewJSON, ''
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON FROM [Nomina].[tblAumentoMasivoEmpleado] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
        WHERE b.[IDAumentoMasivoEmpleado] = @IDAumentoMasivoEmpleado;

        UPDATE [Nomina].[tblAumentoMasivoEmpleado]
        SET
            [IDAumentoMasivo] = @IDAumentoMasivo,
            [IDEmpleado] = @IDEmpleado,
            [SalarioDiario] = @SalarioDiario,
            [SalarioIntegrado] = @SalarioIntegrado,
            [SalarioVariable] = @SalarioVariable,
            [SalarioDiarioReal] = @SalarioDiarioReal,
            [IDRegPatronal] = @IDRegPatronal,
            [IDMovAfiliatorio] = @IDMovAfiliatorio         
        WHERE [IDAumentoMasivoEmpleado] = @IDAumentoMasivoEmpleado;

        SELECT @NewJSON = a.JSON FROM [Nomina].[tblAumentoMasivoEmpleado] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
        WHERE b.[IDAumentoMasivoEmpleado] = @IDAumentoMasivoEmpleado;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblAumentoMasivoEmpleado]', '[Nomina].[spIUAumentoMasivoEmpleado]', 'UPDATE', @NewJSON, @OldJSON
    END
END;
GO

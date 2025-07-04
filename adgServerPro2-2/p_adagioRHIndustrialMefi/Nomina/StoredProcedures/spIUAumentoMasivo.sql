USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUAumentoMasivo]
(
    @IDAumentoMasivo INT = 0,
    @Descripcion VARCHAR(MAX),
    @Ejercicio INT,
    @FechaCreacion DATE,
    @IDTipoAumentoMasivo INT,
    @IDEstatusAumentoMasivo INT,
    @IDRazonMovimiento INT,
    @FechaAplicacionMov DATETIME,
    @RespetarSalarioVariable BIT = 1,    
    @AfectaSalarioDiario BIT = 1,
    @AfectaSalarioDiarioReal BIT = 0,
    @ValorAumento DECIMAL(18,2),
    @IDUsuario INT
)
AS
BEGIN
    DECLARE @OldJSON VARCHAR(MAX),
            @NewJSON VARCHAR(MAX);

    SET @Descripcion = UPPER(@Descripcion);

    IF (ISNULL(@IDAumentoMasivo,0) = 0)
    BEGIN
        INSERT INTO [Nomina].[tblAumentoMasivo]
        (
            [Descripcion],
            [Ejercicio],            
            [IDTipoAumentoMasivo],
            [IDEstatusAumentoMasivo],
            [IDRazonMovimiento],
            [FechaAplicacionMov],
            [RespetarSalarioVariable],
            [AfectaSalarioDiario],
            [AfectaSalarioDiarioReal],                 
            [ValorAumento],
            [IDUsuario]
        )
        VALUES
        (
            @Descripcion,
            @Ejercicio,            
            @IDTipoAumentoMasivo,
            @IDEstatusAumentoMasivo,
            CASE WHEN @IDRazonMovimiento=0 THEN NULL ELSE @IDRazonMovimiento END,
            @FechaAplicacionMov,
            @RespetarSalarioVariable,                        
            @AfectaSalarioDiario,
            @AfectaSalarioDiarioReal,
            @ValorAumento,
            @IDUsuario
        );

        SET @IDAumentoMasivo = @@IDENTITY

        SELECT @NewJSON = a.JSON FROM [Nomina].[tblAumentoMasivo] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
        WHERE b.[IDAumentoMasivo] = @IDAumentoMasivo;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblAumentoMasivo]', '[Nomina].[spIUAumentoMasivo]', 'INSERT', @NewJSON, ''
        
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON FROM [Nomina].[tblAumentoMasivo] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
        WHERE b.[IDAumentoMasivo] = @IDAumentoMasivo;

        UPDATE [Nomina].[tblAumentoMasivo]
        SET
            [Descripcion] = @Descripcion,
            [Ejercicio] = @Ejercicio,            
            [IDTipoAumentoMasivo] = @IDTipoAumentoMasivo,
            [IDEstatusAumentoMasivo] = @IDEstatusAumentoMasivo,
            [IDRazonMovimiento] = CASE WHEN @IDRazonMovimiento=0 THEN NULL ELSE @IDRazonMovimiento END,
            [FechaAplicacionMov] = @FechaAplicacionMov,
            [RespetarSalarioVariable] = @RespetarSalarioVariable,
            [AfectaSalarioDiario] = @AfectaSalarioDiario,
            [AfectaSalarioDiarioReal] = @AfectaSalarioDiarioReal,            
            [ValorAumento] = @ValorAumento        
            
        WHERE [IDAumentoMasivo] = @IDAumentoMasivo;

        SELECT @NewJSON = a.JSON FROM [Nomina].[tblAumentoMasivo] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
        WHERE b.[IDAumentoMasivo] = @IDAumentoMasivo;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblAumentoMasivo]', '[Nomina].[spIUAumentoMasivo]', 'UPDATE', @NewJSON, @OldJSON

        
    END

    EXEC [Nomina].[spBuscarAumentoMasivo] @IDAumentoMasivo=@IDAumentoMasivo,@IDUsuario=@IDUsuario
END;
GO

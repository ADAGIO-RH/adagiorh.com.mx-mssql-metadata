USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spIUTabuladorNivelSalarialAumentosDesempenoDetalle]
(
    @IDTabuladorNivelSalarialAumentosDesempenoDetalle INT = 0,
    @IDTabuladorNivelSalarialAumentosDesempeno INT,
    @Nivel INT,
    @Minimo DECIMAL(18, 4),
    @Maximo DECIMAL(18, 4),
    @IDUsuario INT
)
AS
BEGIN
    DECLARE @OldJSON VARCHAR(MAX),
            @NewJSON VARCHAR(MAX);

    IF (ISNULL(@IDTabuladorNivelSalarialAumentosDesempenoDetalle, 0) = 0)
    BEGIN
        INSERT INTO [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]
        (
            [IDTabuladorNivelSalarialAumentosDesempeno],
            [Nivel],
            [Minimo],
            [Maximo]
        )
        VALUES
        (
            @IDTabuladorNivelSalarialAumentosDesempeno,
            @Nivel,
            @Minimo,
            @Maximo
        );

        SET @IDTabuladorNivelSalarialAumentosDesempenoDetalle = @@IDENTITY;

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] WHERE [IDTabuladorNivelSalarialAumentosDesempenoDetalle] = @IDTabuladorNivelSalarialAumentosDesempenoDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]', '[Nomina].[spIUTabuladorNivelSalarialAumentosDesempenoDetalle]', 'INSERT', @NewJSON, '';
    END
    ELSE
    BEGIN
        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] WHERE [IDTabuladorNivelSalarialAumentosDesempenoDetalle] = @IDTabuladorNivelSalarialAumentosDesempenoDetalle FOR JSON AUTO);

        UPDATE [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]
        SET
            [Nivel] = @Nivel,
            [Minimo] = @Minimo,
            [Maximo] = @Maximo
        WHERE [IDTabuladorNivelSalarialAumentosDesempenoDetalle] = @IDTabuladorNivelSalarialAumentosDesempenoDetalle;

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] WHERE [IDTabuladorNivelSalarialAumentosDesempenoDetalle] = @IDTabuladorNivelSalarialAumentosDesempenoDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]', '[Nomina].[spIUTabuladorNivelSalarialAumentosDesempenoDetalle]', 'UPDATE', @NewJSON, @OldJSON;
    END
END;
GO

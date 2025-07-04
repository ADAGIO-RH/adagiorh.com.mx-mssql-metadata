USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTabuladorResultadoDesempenoDetalle]
(
    @IDTabuladorResultadoDesempenoDetalle INT,
    @IDTabuladorResultadoDesempeno INT,
    @Nivel VARCHAR(50),
    @Descripcion VARCHAR(250),
    @MinimoEvaluaciones DECIMAL(18,4),
    @MaximoEvaluaciones DECIMAL(18,4),
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldJSON VARCHAR(MAX),
            @NewJSON VARCHAR(MAX);
    SET @Nivel = UPPER(@Nivel)
    SET @Descripcion = UPPER(@Descripcion)

    IF (ISNULL(@IDTabuladorResultadoDesempenoDetalle, 0) = 0)
    BEGIN
        INSERT INTO [Nomina].[tblTabuladorResultadoDesempenoDetalle]
        (
            [IDTabuladorResultadoDesempeno],
            [Nivel],
            [Descripcion],
            [MinimoEvaluaciones],
            [MaximoEvaluaciones]
        )
        VALUES
        (
            @IDTabuladorResultadoDesempeno,
            @Nivel,
            @Descripcion,
            @MinimoEvaluaciones,
            @MaximoEvaluaciones
        );

        SET @IDTabuladorResultadoDesempenoDetalle = SCOPE_IDENTITY();

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle] 
                          WHERE [IDTabuladorResultadoDesempenoDetalle] = @IDTabuladorResultadoDesempenoDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, 
            '[Nomina].[tblTabuladorResultadoDesempenoDetalle]', 
            '[Nomina].[spIUTabuladorResultadoDesempenoDetalle]', 
            'INSERT', @NewJSON, '';
    END
    ELSE
    BEGIN
        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle] 
                          WHERE [IDTabuladorResultadoDesempenoDetalle] = @IDTabuladorResultadoDesempenoDetalle FOR JSON AUTO);

        UPDATE [Nomina].[tblTabuladorResultadoDesempenoDetalle]
        SET
            [Nivel] = @Nivel,
            [Descripcion] = @Descripcion,
            [MinimoEvaluaciones] = @MinimoEvaluaciones,
            [MaximoEvaluaciones] = @MaximoEvaluaciones
        WHERE [IDTabuladorResultadoDesempenoDetalle] = @IDTabuladorResultadoDesempenoDetalle;

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle] 
                          WHERE [IDTabuladorResultadoDesempenoDetalle] = @IDTabuladorResultadoDesempenoDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, 
            '[Nomina].[tblTabuladorResultadoDesempenoDetalle]', 
            '[Nomina].[spIUTabuladorResultadoDesempenoDetalle]', 
            'UPDATE', @NewJSON, @OldJSON;
    END
END;
GO

USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTabuladorRelacionEvaluacionesObjetivosDetalle]
(
    @IDTabuladorRelacionEvaluacionesObjetivosDetalle INT,
    @IDTabuladorRelacionEvaluacionesObjetivos INT,
    @Nivel VARCHAR(50),
    @Descripcion VARCHAR(250),
    @MinimoEvaluaciones DECIMAL(18,4),
    @MaximoEvaluaciones DECIMAL(18,4),
    @MinimoObjetivos DECIMAL(18,4),
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldJSON VARCHAR(MAX),
            @NewJSON VARCHAR(MAX);
    SET @Nivel = UPPER(@Nivel)
    SET @Descripcion = UPPER(@Descripcion)

    IF (ISNULL(@IDTabuladorRelacionEvaluacionesObjetivosDetalle, 0) = 0)
    BEGIN
        INSERT INTO [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]
        (
            [IDTabuladorRelacionEvaluacionesObjetivos],
            [Nivel],
            [Descripcion],
            [MinimoEvaluaciones],
            [MaximoEvaluaciones],
            [MinimoObjetivos]
        )
        VALUES
        (
            @IDTabuladorRelacionEvaluacionesObjetivos,
            @Nivel,
            @Descripcion,
            @MinimoEvaluaciones,
            @MaximoEvaluaciones,
            @MinimoObjetivos
        );

        SET @IDTabuladorRelacionEvaluacionesObjetivosDetalle = SCOPE_IDENTITY();

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle] 
                          WHERE [IDTabuladorRelacionEvaluacionesObjetivosDetalle] = @IDTabuladorRelacionEvaluacionesObjetivosDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, 
            '[Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]', 
            '[Nomina].[spIUTabuladorRelacionEvaluacionesObjetivosDetalle]', 
            'INSERT', @NewJSON, '';
    END
    ELSE
    BEGIN
        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle] 
                          WHERE [IDTabuladorRelacionEvaluacionesObjetivosDetalle] = @IDTabuladorRelacionEvaluacionesObjetivosDetalle FOR JSON AUTO);

        UPDATE [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]
        SET
            [Nivel] = @Nivel,
            [Descripcion] = @Descripcion,
            [MinimoEvaluaciones] = @MinimoEvaluaciones,
            [MaximoEvaluaciones] = @MaximoEvaluaciones,
            [MinimoObjetivos] = @MinimoObjetivos
        WHERE [IDTabuladorRelacionEvaluacionesObjetivosDetalle] = @IDTabuladorRelacionEvaluacionesObjetivosDetalle;

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle] 
                          WHERE [IDTabuladorRelacionEvaluacionesObjetivosDetalle] = @IDTabuladorRelacionEvaluacionesObjetivosDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, 
            '[Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]', 
            '[Nomina].[spIUTabuladorRelacionEvaluacionesObjetivosDetalle]', 
            'UPDATE', @NewJSON, @OldJSON;
    END
END;
GO

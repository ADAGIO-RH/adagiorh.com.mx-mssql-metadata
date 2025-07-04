USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCopiarTabuladorResultadoDesempeno]
(
    @IDControlAumentosDesempeno INT,
    @IDTabuladorResultadoDesempeno INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NuevoIDTabuladorResultadoDesempeno INT;
    DECLARE @OldJSON VARCHAR(MAX) = '',
            @NewJSON VARCHAR(MAX),
            @NombreSP VARCHAR(MAX) = '[Nomina].[spCopiarTabuladorResultadoDesempeno]',
            @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorResultadoDesempeno]',
            @Accion VARCHAR(20) = 'INSERT';

    INSERT INTO [Nomina].[tblTabuladorResultadoDesempeno] (Descripcion)
    SELECT 
        COALESCE(Descripcion, '') 
    FROM [Nomina].[tblTabuladorResultadoDesempeno]
    WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;

    SET @NuevoIDTabuladorResultadoDesempeno = SCOPE_IDENTITY();

    INSERT INTO [Nomina].[tblTabuladorResultadoDesempenoDetalle]
    (
        IDTabuladorResultadoDesempeno,
        Nivel,
        Descripcion,
        MinimoEvaluaciones,
        MaximoEvaluaciones
    )
    SELECT 
        @NuevoIDTabuladorResultadoDesempeno,
        Nivel,
        Descripcion,
        MinimoEvaluaciones,
        MaximoEvaluaciones
    FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle]
    WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;

    UPDATE [Nomina].[tblControlAumentosDesempeno]
    SET IDTabuladorResultadoDesempeno = @NuevoIDTabuladorResultadoDesempeno
    WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

    SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorResultadoDesempeno] 
                      WHERE IDTabuladorResultadoDesempeno = @NuevoIDTabuladorResultadoDesempeno FOR JSON AUTO);

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT *
    FROM [Nomina].[tblTabuladorResultadoDesempeno]
    WHERE IDTabuladorResultadoDesempeno = @NuevoIDTabuladorResultadoDesempeno;
END;
GO

USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCopiarTabuladorRelacionEvaluacionesObjetivos]
(
    @IDControlBonosObjetivos INT,
    @IDTabuladorRelacionEvaluacionesObjetivos INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NuevoIDTabuladorRelacionEvaluacionesObjetivos INT;
    DECLARE @OldJSON VARCHAR(MAX) = '',
            @NewJSON VARCHAR(MAX),
            @NombreSP VARCHAR(MAX) = '[Nomina].[spCopiarTabuladorRelacionEvaluacionesObjetivos]',
            @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]',
            @Accion VARCHAR(20) = 'INSERT';

    INSERT INTO [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] (Descripcion)
    SELECT 
        COALESCE(Descripcion, '') 
    FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]
    WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

    SET @NuevoIDTabuladorRelacionEvaluacionesObjetivos = SCOPE_IDENTITY();

    INSERT INTO [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]
    (
        IDTabuladorRelacionEvaluacionesObjetivos,
        Nivel,
        Descripcion,
        MinimoEvaluaciones,
        MaximoEvaluaciones,
        MinimoObjetivos
    )
    SELECT 
        @NuevoIDTabuladorRelacionEvaluacionesObjetivos,
        Nivel,
        Descripcion,
        MinimoEvaluaciones,
        MaximoEvaluaciones,
        MinimoObjetivos
    FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]
    WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

    UPDATE [Nomina].[tblControlBonosObjetivos]
    SET IDTabuladorRelacionEvaluacionesObjetivos = @NuevoIDTabuladorRelacionEvaluacionesObjetivos
    WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

    SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] 
                      WHERE IDTabuladorRelacionEvaluacionesObjetivos = @NuevoIDTabuladorRelacionEvaluacionesObjetivos FOR JSON AUTO);

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT *
    FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]
    WHERE IDTabuladorRelacionEvaluacionesObjetivos = @NuevoIDTabuladorRelacionEvaluacionesObjetivos;
END;
GO

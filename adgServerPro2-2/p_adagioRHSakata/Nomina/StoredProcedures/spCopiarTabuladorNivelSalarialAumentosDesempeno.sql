USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCopiarTabuladorNivelSalarialAumentosDesempeno]
    @IDControlAumentosDesempeno INT,
    @IDTabuladorNivelSalarialCompensaciones INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NuevoIDTabuladorNivelSalarialAumentosDesempeno INT;
    DECLARE @OldJSON VARCHAR(MAX) = '',
            @NewJSON VARCHAR(MAX),
            @NombreSP VARCHAR(MAX) = '[Nomina].[spCopiarTabuladorNivelSalarialAumentosDesempeno]',
            @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorNivelSalarialAumentosDesempeno]',
            @Accion VARCHAR(20) = 'INSERT';

    
    INSERT INTO [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno] (Descripcion)
    SELECT 
        COALESCE(Descripcion, '') + ' ' + 
        COALESCE(
            (SELECT TOP 1 Descripcion 
             FROM [Nomina].[tblControlAumentosDesempeno] 
             WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno), 
            ''
        )
    FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones]
    WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;


    
    SET @NuevoIDTabuladorNivelSalarialAumentosDesempeno = SCOPE_IDENTITY();

    
    SELECT @NewJSON = a.JSON
    FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
    WHERE IDTabuladorNivelSalarialAumentosDesempeno = @NuevoIDTabuladorNivelSalarialAumentosDesempeno;

    
    INSERT INTO [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] (IDTabuladorNivelSalarialAumentosDesempeno, Nivel, Minimo, Maximo)
    SELECT @NuevoIDTabuladorNivelSalarialAumentosDesempeno, Nivel, Minimo, Maximo
    FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
    WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

    
    UPDATE [Nomina].[tblControlAumentosDesempeno]
    SET IDTabuladorNivelSalarialAumentosDesempeno = @NuevoIDTabuladorNivelSalarialAumentosDesempeno
    WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

    
    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON

    SELECT *
    FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno]
    WHERE IDTabuladorNivelSalarialAumentosDesempeno = @NuevoIDTabuladorNivelSalarialAumentosDesempeno

END;
GO

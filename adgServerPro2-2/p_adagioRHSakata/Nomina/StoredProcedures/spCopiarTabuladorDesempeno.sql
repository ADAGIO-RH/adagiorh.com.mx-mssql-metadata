USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCopiarTabuladorDesempeno]
    @IDControlAumentosDesempeno INT,
    @IDTabuladorDesempeno INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NuevoIDTabuladorDesempeno INT;
    DECLARE @OldJSON VARCHAR(MAX) = '',
            @NewJSON VARCHAR(MAX),
            @NombreSP VARCHAR(MAX) = '[Nomina].[spCopiarTabuladorDesempeno]',
            @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorDesempeno]',
            @Accion VARCHAR(20) = 'INSERT';

    
    INSERT INTO [Nomina].[tblTabuladorDesempeno] (Descripcion)
    SELECT 
        Descripcion
        
    FROM [Nomina].[tblControlAumentosDesempeno]
    WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

    
    SET @NuevoIDTabuladorDesempeno = SCOPE_IDENTITY();

    
    SELECT @NewJSON = a.JSON
    FROM [Nomina].[tblTabuladorDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
    WHERE IDTabuladorDesempeno = @NuevoIDTabuladorDesempeno;

    
    INSERT INTO [Nomina].[tblTabuladorDesempenoDetalle] (IDTabuladorDesempeno, Minimo, Maximo, Porcentaje)
    SELECT @NuevoIDTabuladorDesempeno,  Minimo, Maximo,Porcentaje
    FROM [Nomina].[tblTabuladorDesempenoDetalle]D
    WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno;

    
    UPDATE [Nomina].[tblControlAumentosDesempeno]
    SET IDTabuladorDesempeno = @NuevoIDTabuladorDesempeno
    WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

    
    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON

    SELECT *
    FROM [Nomina].[tblTabuladorDesempeno]
    WHERE IDTabuladorDesempeno = @NuevoIDTabuladorDesempeno

END;
GO

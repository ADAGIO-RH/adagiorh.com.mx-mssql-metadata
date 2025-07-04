USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTabuladorDesempeno]
(
    @IDTabuladorDesempeno INT = 0,
    @IDControlAumentosDesempeno INT = 0,
    @Descripcion VARCHAR(255),
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUTabuladorDesempeno]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorDesempeno]',
        @Accion VARCHAR(20) = '';

    SET @Descripcion = UPPER(@Descripcion);

    IF (@IDTabuladorDesempeno = 0 OR @IDTabuladorDesempeno IS NULL)
    BEGIN
        
        IF(@IDControlAumentosDesempeno<>0 AND @Descripcion IS NULL)
        BEGIN
            SELECT @Descripcion = Descripcion
            FROM Nomina.tblControlAumentosDesempeno
            WHERE IDControlAumentosDesempeno=@IDControlAumentosDesempeno
        END

        INSERT INTO [Nomina].[tblTabuladorDesempeno] (Descripcion)
        VALUES (@Descripcion);

        SELECT @IDTabuladorDesempeno = @@IDENTITY;

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblTabuladorDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno;

        IF(@IDControlAumentosDesempeno<>0)
        BEGIN
            UPDATE Nomina.tblControlAumentosDesempeno
            SET IDTabuladorDesempeno = @IDTabuladorDesempeno
            WHERE IDControlAumentosDesempeno=@IDControlAumentosDesempeno
        END
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON,
               @Accion = 'UPDATE'
        FROM [Nomina].[tblTabuladorDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno;

        UPDATE [Nomina].[tblTabuladorDesempeno]
        SET Descripcion = @Descripcion
        WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno;

        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblTabuladorDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno;
    END;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblTabuladorDesempeno]
    WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno;
END;
GO

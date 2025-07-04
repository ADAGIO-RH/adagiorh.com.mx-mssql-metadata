USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE [Nomina].[spIUTabuladorResultadoDesempeno]
(
    @IDTabuladorResultadoDesempeno INT = 0,
    @IDControlAumentosDesempeno INT = 0,
    @Descripcion VARCHAR(255),
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUTabuladorResultadoDesempeno]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorResultadoDesempeno]',
        @Accion VARCHAR(20) = '';

    SET @Descripcion = UPPER(@Descripcion);

    IF (@IDTabuladorResultadoDesempeno = 0 OR @IDTabuladorResultadoDesempeno IS NULL)
    BEGIN
        
        IF(@IDControlAumentosDesempeno <> 0 AND @Descripcion IS NULL)
        BEGIN
            SELECT @Descripcion = Descripcion
            FROM Nomina.tblControlAumentosDesempeno
            WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno
        END

        INSERT INTO [Nomina].[tblTabuladorResultadoDesempeno] (Descripcion)
        VALUES (@Descripcion);

        SELECT @IDTabuladorResultadoDesempeno = @@IDENTITY;

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblTabuladorResultadoDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;

        IF(@IDControlAumentosDesempeno <> 0)
        BEGIN
            UPDATE Nomina.tblControlAumentosDesempeno
            SET IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno
            WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno
        END
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON,
               @Accion = 'UPDATE'
        FROM [Nomina].[tblTabuladorResultadoDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;

        UPDATE [Nomina].[tblTabuladorResultadoDesempeno]
        SET Descripcion = @Descripcion
        WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;

        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblTabuladorResultadoDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;
    END;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblTabuladorResultadoDesempeno]
    WHERE IDTabuladorResultadoDesempeno = @IDTabuladorResultadoDesempeno;
END;
GO

USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTabuladorRelacionEvaluacionesObjetivos]
(
    @IDTabuladorRelacionEvaluacionesObjetivos INT = 0,
    @IDControlBonosObjetivos INT = 0,
    @Descripcion VARCHAR(255),
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUTabuladorRelacionEvaluacionesObjetivos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]',
        @Accion VARCHAR(20) = '';

    SET @Descripcion = UPPER(@Descripcion);

    IF (@IDTabuladorRelacionEvaluacionesObjetivos = 0 OR @IDTabuladorRelacionEvaluacionesObjetivos IS NULL)
    BEGIN
        
        IF(@IDControlBonosObjetivos <> 0 AND @Descripcion IS NULL)
        BEGIN
            SELECT @Descripcion = Descripcion
            FROM Nomina.tblControlBonosObjetivos
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos
        END

        INSERT INTO [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] (Descripcion)
        VALUES (@Descripcion);

        SELECT @IDTabuladorRelacionEvaluacionesObjetivos = @@IDENTITY;

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

        IF(@IDControlBonosObjetivos <> 0)
        BEGIN
            UPDATE Nomina.tblControlBonosObjetivos
            SET IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos
        END
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON,
               @Accion = 'UPDATE'
        FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

        UPDATE [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]
        SET Descripcion = @Descripcion
        WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;
    END;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]
    WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;
END;
GO

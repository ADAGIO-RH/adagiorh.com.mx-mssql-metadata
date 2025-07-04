USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spIUTabuladorDesempenoDetalle]
(
    @IDTabuladorDesempenoDetalle INT = 0,
    @IDTabuladorDesempeno INT,
    @Minimo DECIMAL(18, 4),
    @Maximo DECIMAL(18, 4),
    @Porcentaje DECIMAL(5, 2),
    @IDUsuario INT
) AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUTabuladorDesempenoDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorDesempenoDetalle]',
        @Accion VARCHAR(20) = '';

    IF (@IDTabuladorDesempenoDetalle = 0 OR @IDTabuladorDesempenoDetalle IS NULL)
    BEGIN
        INSERT INTO [Nomina].[tblTabuladorDesempenoDetalle] (IDTabuladorDesempeno, Minimo, Maximo, Porcentaje)
        VALUES (@IDTabuladorDesempeno, @Minimo, @Maximo, @Porcentaje);

        SELECT @IDTabuladorDesempenoDetalle = @@IDENTITY;

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblTabuladorDesempenoDetalle] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle;
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON,
               @Accion = 'UPDATE'
        FROM [Nomina].[tblTabuladorDesempenoDetalle] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle;

        UPDATE [Nomina].[tblTabuladorDesempenoDetalle]
        SET Minimo = @Minimo,
            Maximo = @Maximo,
            Porcentaje = @Porcentaje
        WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle;

        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblTabuladorDesempenoDetalle] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle;
    END;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblTabuladorDesempenoDetalle]
    WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle;
END;
GO

USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Nomina].[spITabuladorNivelSalarialCompensacionesDetalle] (
    @IDTabuladorNivelSalarialCompensaciones INT,
    @detalle [Nomina].[dtTabuladorNivelSalarialCompensacionesDetalle] READONLY,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spITabuladorNivelSalarialCompensacionesDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]',
        @Accion VARCHAR(20) = 'INSERT';

    BEGIN TRY
        -- Validación de parámetros
        IF @IDTabuladorNivelSalarialCompensaciones IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('IDTabuladorNivelSalarialCompensaciones e IDUsuario son obligatorios.', 16, 1);
            RETURN;
        END;

        IF NOT EXISTS (SELECT 1 FROM @detalle)
        BEGIN
            RAISERROR ('El parámetro @detalle no contiene registros válidos.', 16, 1);
            RETURN;
        END;

        
        SELECT @OldJSON = (SELECT * 
                           FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
                           WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones
                           FOR JSON AUTO);

        
        IF EXISTS (SELECT 1 
                   FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] 
                   WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones)
        BEGIN
            DELETE FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
            WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;
        END;

        
        INSERT INTO [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] (
            IDTabuladorNivelSalarialCompensaciones, 
            Nivel, 
            Minimo, 
            Maximo
        ) 

        SELECT 
            @IDTabuladorNivelSalarialCompensaciones, 
            Nivel, 
            Minimo, 
            Maximo
        FROM @detalle
        WHERE Nivel IS NOT NULL;

        
        SELECT @NewJSON = (SELECT * 
                           FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
                           WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones
                           FOR JSON AUTO);

        
        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario       = @IDUsuario,
            @Tabla           = @Tabla,
            @Procedimiento   = @NombreSP,
            @Accion          = @Accion,
            @NewData         = @NewJSON,
            @OldData         = @OldJSON;

        
        SELECT * 
        FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
        WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spIUTabuladorNivelSalarialCompensacionesDetalle].', 16, 1);
    END CATCH;
END;
GO

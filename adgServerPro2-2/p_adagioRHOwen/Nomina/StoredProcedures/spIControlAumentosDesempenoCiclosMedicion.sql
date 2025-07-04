USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [Nomina].[spIControlAumentosDesempenoCiclosMedicion] (
    @IDControlAumentosDesempeno INT,
    @IDCicloMedicionObjetivo INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @IDControlAumentosDesempenoCiclo INT,
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIControlAumentosDesempenoCiclosMedicion]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempenoCiclosMedicion]',
        @Accion VARCHAR(20) = 'INSERT';

    BEGIN TRY
        -- Validación de parámetros
        IF @IDControlAumentosDesempeno IS NULL OR @IDUsuario IS NULL OR @IDCicloMedicionObjetivo IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;
        
                    
        INSERT INTO [Nomina].[tblControlAumentosDesempenoCiclosMedicion] (
            IDControlAumentosDesempeno, 
            IDCicloMedicionObjetivo
        ) 
        VALUES (
            @IDControlAumentosDesempeno, 
            @IDCicloMedicionObjetivo
        )
        
        SET @IDControlAumentosDesempenoCiclo = SCOPE_IDENTITY();

        SELECT @NewJSON = (SELECT * 
                           FROM [Nomina].[tblControlAumentosDesempenoCiclosMedicion]
                           WHERE IDControlAumentosDesempenoCiclo = @IDControlAumentosDesempenoCiclo
                           FOR JSON AUTO);

        
        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario       = @IDUsuario,
            @Tabla           = @Tabla,
            @Procedimiento   = @NombreSP,
            @Accion          = @Accion,
            @NewData         = @NewJSON,
            @OldData         = @OldJSON;
        
        SELECT * 
        FROM [Nomina].[tblControlAumentosDesempenoCiclosMedicion]
        WHERE IDControlAumentosDesempenoCiclo = @IDControlAumentosDesempenoCiclo

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spIControlAumentosDesempenoCiclosMedicion].', 16, 1);
    END CATCH;
END;
GO

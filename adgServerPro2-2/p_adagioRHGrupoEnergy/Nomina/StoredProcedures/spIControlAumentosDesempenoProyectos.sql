USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [Nomina].[spIControlAumentosDesempenoProyectos] (
    @IDControlAumentosDesempeno INT,
    @IDProyecto INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @IDControlAumentosDesempenoProyecto INT,
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIControlAumentosDesempenoProyectos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempenoProyectos]',
        @Accion VARCHAR(20) = 'INSERT';

    BEGIN TRY
        -- Validación de parámetros
        IF @IDControlAumentosDesempeno IS NULL OR @IDUsuario IS NULL OR @IDProyecto IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;
        
                    
        INSERT INTO [Nomina].[tblControlAumentosDesempenoProyectos] (
            IDControlAumentosDesempeno, 
            IDProyecto
        ) 
        VALUES (
            @IDControlAumentosDesempeno, 
            @IDProyecto
        );
        
        SET @IDControlAumentosDesempenoProyecto = SCOPE_IDENTITY();

        SELECT @NewJSON = (SELECT * 
                           FROM [Nomina].[tblControlAumentosDesempenoProyectos]
                           WHERE IDControlAumentosDesempenoProyecto = @IDControlAumentosDesempenoProyecto
                           FOR JSON AUTO);

        
        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario       = @IDUsuario,
            @Tabla           = @Tabla,
            @Procedimiento   = @NombreSP,
            @Accion          = @Accion,
            @NewData         = @NewJSON,
            @OldData         = @OldJSON;
        
        SELECT * 
        FROM [Nomina].[tblControlAumentosDesempenoProyectos]
     WHERE IDControlAumentosDesempenoProyecto = @IDControlAumentosDesempenoProyecto

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spIControlAumentosDesempenoProyectos].', 16, 1);
    END CATCH;
END;
GO

USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Nomina].[spBorrarControlAumentosDesempenoProyectos] (
    @IDControlAumentosDesempenoProyecto INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarControlAumentosDesempenoProyectos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempenoProyectos]',
        @Accion VARCHAR(20) = 'DELETE';

    BEGIN TRY
        
        IF @IDControlAumentosDesempenoProyecto IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;

        
        SELECT @OldJSON = (SELECT * 
                           FROM [Nomina].[tblControlAumentosDesempenoProyectos]
                           WHERE IDControlAumentosDesempenoProyecto = @IDControlAumentosDesempenoProyecto
                           FOR JSON AUTO);

        IF @OldJSON IS NULL
        BEGIN
            RAISERROR ('El registro especificado no existe.', 16, 1);
            RETURN;
        END;

        
        DELETE FROM [Nomina].[tblControlAumentosDesempenoProyectos]
        WHERE IDControlAumentosDesempenoProyecto = @IDControlAumentosDesempenoProyecto;

        
        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario       = @IDUsuario,
            @Tabla           = @Tabla,
            @Procedimiento   = @NombreSP,
            @Accion          = @Accion,
            @NewData         = NULL,
            @OldData         = @OldJSON;

        
        SELECT 'El registro ha sido eliminado correctamente.' AS Message;

    END TRY
    BEGIN CATCH
        
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spBorrarControlAumentosDesempenoProyectos].', 16, 1);
    END CATCH;
END;
GO

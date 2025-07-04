USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Nomina].[spBorrarControlAumentosDesempenoCiclosMedicion] (
    @IDControlAumentosDesempenoCiclo INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarControlAumentosDesempenoCiclosMedicion]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempenoCiclosMedicion]',
        @Accion VARCHAR(20) = 'DELETE';

    BEGIN TRY
        
        IF @IDControlAumentosDesempenoCiclo IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;

        
        SELECT @OldJSON = (SELECT * 
                           FROM [Nomina].[tblControlAumentosDesempenoCiclosMedicion]
                           WHERE IDControlAumentosDesempenoCiclo = @IDControlAumentosDesempenoCiclo
                           FOR JSON AUTO);

        IF @OldJSON IS NULL
        BEGIN
            RAISERROR ('El registro especificado no existe.', 16, 1);
            RETURN;
        END;

        
        DELETE FROM [Nomina].[tblControlAumentosDesempenoCiclosMedicion]
        WHERE IDControlAumentosDesempenoCiclo = @IDControlAumentosDesempenoCiclo;

        
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

        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spBorrarControlAumentosDesempenoCiclosMedicion].', 16, 1);
    END CATCH;
END;
GO

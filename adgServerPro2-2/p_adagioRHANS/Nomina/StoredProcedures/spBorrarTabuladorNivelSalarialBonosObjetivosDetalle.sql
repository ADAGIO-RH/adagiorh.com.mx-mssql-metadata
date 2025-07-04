USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarTabuladorNivelSalarialBonosObjetivosDetalle]
(
    @IDTabuladorNivelSalarialBonosObjetivosDetalle INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldJSON VARCHAR(MAX);

    BEGIN TRY
        IF @IDTabuladorNivelSalarialBonosObjetivosDetalle IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;

        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] WHERE [IDTabuladorNivelSalarialBonosObjetivosDetalle] = @IDTabuladorNivelSalarialBonosObjetivosDetalle FOR JSON AUTO);

        IF @OldJSON IS NULL
        BEGIN
            RAISERROR ('El registro especificado no existe.', 16, 1);
            RETURN;
        END;

        DELETE FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]
        WHERE [IDTabuladorNivelSalarialBonosObjetivosDetalle] = @IDTabuladorNivelSalarialBonosObjetivosDetalle;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]', '[Nomina].[spBorrarTabuladorNivelSalarialBonosObjetivosDetalle]', 'DELETE', NULL, @OldJSON;

        SELECT 'El registro ha sido eliminado correctamente.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() AS ErrorLine;
        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spBorrarTabuladorNivelSalarialBonosObjetivosDetalle].', 16, 1);
    END CATCH;
END;
GO

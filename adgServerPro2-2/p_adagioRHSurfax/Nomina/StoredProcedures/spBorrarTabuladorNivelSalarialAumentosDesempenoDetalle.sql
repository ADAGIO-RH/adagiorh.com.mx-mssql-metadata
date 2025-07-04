USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarTabuladorNivelSalarialAumentosDesempenoDetalle]
(
    @IDTabuladorNivelSalarialAumentosDesempenoDetalle INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldJSON VARCHAR(MAX);

    BEGIN TRY
        IF @IDTabuladorNivelSalarialAumentosDesempenoDetalle IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;

        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] WHERE [IDTabuladorNivelSalarialAumentosDesempenoDetalle] = @IDTabuladorNivelSalarialAumentosDesempenoDetalle FOR JSON AUTO);

        IF @OldJSON IS NULL
        BEGIN
            RAISERROR ('El registro especificado no existe.', 16, 1);
            RETURN;
        END;

        DELETE FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]
        WHERE [IDTabuladorNivelSalarialAumentosDesempenoDetalle] = @IDTabuladorNivelSalarialAumentosDesempenoDetalle;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]', '[Nomina].[spBorrarTabuladorNivelSalarialAumentosDesempenoDetalle]', 'DELETE', NULL, @OldJSON;

        SELECT 'El registro ha sido eliminado correctamente.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() AS ErrorLine;
        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spBorrarTabuladorNivelSalarialAumentosDesempenoDetalle].', 16, 1);
    END CATCH;
END;
GO

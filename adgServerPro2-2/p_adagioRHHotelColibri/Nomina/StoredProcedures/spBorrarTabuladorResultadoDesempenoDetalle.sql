USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarTabuladorResultadoDesempenoDetalle]
(
    @IDTabuladorResultadoDesempenoDetalle INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldJSON VARCHAR(MAX);

    BEGIN TRY
        IF @IDTabuladorResultadoDesempenoDetalle IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;

        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle] 
                          WHERE [IDTabuladorResultadoDesempenoDetalle] = @IDTabuladorResultadoDesempenoDetalle FOR JSON AUTO);

        IF @OldJSON IS NULL
        BEGIN
            RAISERROR ('El registro especificado no existe.', 16, 1);
            RETURN;
        END;

        DELETE FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle]
        WHERE [IDTabuladorResultadoDesempenoDetalle] = @IDTabuladorResultadoDesempenoDetalle;

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, 
            '[Nomina].[tblTabuladorResultadoDesempenoDetalle]', 
            '[Nomina].[spBorrarTabuladorResultadoDesempenoDetalle]', 
            'DELETE', NULL, @OldJSON;

        SELECT 'El registro ha sido eliminado correctamente.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() AS ErrorLine;
        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spBorrarTabuladorResultadoDesempenoDetalle].', 16, 1);
    END CATCH;
END;
GO

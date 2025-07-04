USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spBorrarTabuladorDesempenoDetalle]
(
    @IDTabuladorDesempenoDetalle INT,
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX) = '',
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarTabuladorDesempenoDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorDesempenoDetalle]',
        @Accion VARCHAR(20) = 'DELETE',
        @Mensaje VARCHAR(MAX);

    BEGIN TRY  
        -- Obtener datos antiguos para auditoría
        SELECT @OldJSON = a.JSON
        FROM (
            SELECT *
            FROM [Nomina].[tblTabuladorDesempenoDetalle]
            WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle
        ) b
        CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML RAW))) a;

        -- Eliminar el registro
        DELETE FROM [Nomina].[tblTabuladorDesempenoDetalle]
        WHERE IDTabuladorDesempenoDetalle = @IDTabuladorDesempenoDetalle;

        -- Ejecutar auditoría
        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario      = @IDUsuario,
            @Tabla          = @Tabla,
            @Procedimiento  = @NombreSP,
            @Accion         = @Accion,
            @NewData        = @NewJSON,
            @OldData        = @OldJSON,
            @Mensaje        = @Mensaje,
            @InformacionExtra = NULL;

        -- Respuesta exitosa
        SELECT 'Registro eliminado correctamente.' AS Mensaje, 0 AS TipoRespuesta;
    END TRY  
    BEGIN CATCH  
        -- Manejo de errores
        SELECT 'Ocurrió un error no controlado: ' + ERROR_MESSAGE() AS Mensaje, -1 AS TipoRespuesta;
    END CATCH;
END;
GO

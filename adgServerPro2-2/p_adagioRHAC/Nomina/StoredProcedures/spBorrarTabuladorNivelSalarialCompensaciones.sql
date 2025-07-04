USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción       : Eliminar un registro de la tabla tblTabuladorNivelSalarialCompensaciones
** Autor             : Javier Peña
** Email             : jpena@adagio.com.mx
** FechaCreacion     : 2024-12-17
** Parámetros        :   
            @IDTabuladorNivelSalarialCompensaciones int
            @ConfirmarEliminar bit = 0
            @IDUsuario int
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)    Autor                Comentario
-------------------  -------------------  ------------------------------------------------------------

***************************************************************************************************/
CREATE   PROC [Nomina].[spBorrarTabuladorNivelSalarialCompensaciones](
    @IDTabuladorNivelSalarialCompensaciones INT,
    @ConfirmarEliminar BIT = 0,
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX) = '',
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarTabuladorNivelSalarialCompensaciones]',
        @Tabla VARCHAR(MAX) = '[Nomina.tblTabuladorNivelSalarialCompensaciones]',
        @Accion VARCHAR(20) = 'DELETE',
        @Mensaje VARCHAR(MAX),
        @TotalDependencias INT;

    IF OBJECT_ID('tempdb..#tempResponse') IS NOT NULL DROP TABLE #tempResponse;

    BEGIN TRY  
        
        SELECT @TotalDependencias = COUNT(*)
        FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
        WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

        
        IF (@TotalDependencias > 0 AND @ConfirmarEliminar = 0)
        BEGIN
            SELECT 
                'Este nivel salarial tiene ' + CAST(@TotalDependencias AS VARCHAR) +
                CASE 
                    WHEN @TotalDependencias = 1 THEN ' dependencia asociada y será eliminada. ¿Desea continuar?'
                    ELSE ' dependencias asociadas y serán eliminadas. ¿Desea continuar?'
                END AS Mensaje,
                1 AS TipoRespuesta;

            RETURN;
        END
        ELSE
        BEGIN
            
            SELECT @OldJSON = a.JSON
            FROM (
                SELECT *
                FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones]
                WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones
            ) b
            CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML RAW))) a;

            
            DELETE FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
            WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

            -- Eliminar el registro principal
            DELETE FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones]
            WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

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
            RETURN;
        END
    END TRY  
    BEGIN CATCH  
        -- Manejo de errores
        SELECT 'Ocurrió un error no controlado: ' + ERROR_MESSAGE() AS Mensaje, -1 AS TipoRespuesta;
    END CATCH;
END;
GO

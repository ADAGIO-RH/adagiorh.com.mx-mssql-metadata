USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción       : Eliminar un registro de la tabla tblControlAumentosDesempeno
** Autor             : Javier Peña
** Email             : jpena@adagio.com.mx
** FechaCreacion     : 2024-12-19
** Parámetros        :   
            @IDControlAumentosDesempeno int
            @ConfirmarEliminar bit = 0
            @IDUsuario int
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)    Autor                Comentario
-------------------  -------------------  ------------------------------------------------------------

***************************************************************************************************/
CREATE PROC [Nomina].[spBorrarControlAumentosDesempeno](
    @IDControlAumentosDesempeno INT,
    @ConfirmarEliminar BIT = 0,
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX) = '',
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarControlAumentosDesempeno]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempeno]',
        @Accion VARCHAR(20) = 'DELETE',
        @Mensaje VARCHAR(MAX) = '',
        @IDTabuladorNivelSalarialAumentosDesempeno INT,
        @IDTabuladorDesempeno INT,
        @TotalRegistrosAplicados INT,        

        @TotalRegistros INT,        

        @Aplicado BIT;


    BEGIN TRY  
        
        
        SELECT @TotalRegistrosAplicados = COUNT(*) 
        FROM [Nomina].[tblControlAumentosDesempenoDetalle]
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno
         AND IDMovAfiliatorio IS NOT NULL;

         SELECT @TotalRegistros = COUNT(*) 
        FROM [Nomina].[tblControlAumentosDesempenoDetalle]
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno         


        SELECT @Aplicado = ISNULL(Aplicado, 0)
        FROM [Nomina].[tblControlAumentosDesempeno]
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

        IF(@Aplicado = 1 AND @ConfirmarEliminar = 0)
        BEGIN
            SET @Mensaje = @Mensaje + '<li>El cálculo se encuentra aplicado</li>';
        END

        IF(@TotalRegistrosAplicados > 0 AND @ConfirmarEliminar = 0)
        BEGIN
            SET @Mensaje = @Mensaje + '<li>Se eliminarán ' + CAST(@TotalRegistrosAplicados AS VARCHAR) + ' movimientos afiliatorios asociados a este cálculo</li>';

        END

        IF(@TotalRegistros > 0 AND @ConfirmarEliminar = 0)
        BEGIN
            SET @Mensaje = @Mensaje + '<li>Se eliminarán ' + CAST(@TotalRegistros AS VARCHAR) + ' registros cálculados</li>';
        END

        IF(@Mensaje IS NOT NULL AND @Mensaje <> '')

        BEGIN            
            SELECT @Mensaje AS Mensaje, 1 AS TipoRespuesta;
            RETURN;
        END
        ELSE
        BEGIN
            BEGIN TRANSACTION;

            -- Obtener JSON del registro a eliminar
            SELECT @OldJSON = a.JSON
            FROM (
                SELECT IDControlAumentosDesempeno,Descripcion,Ejercicio,Aplicado
                FROM [Nomina].[tblControlAumentosDesempeno]
                WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno
            ) b
            CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML RAW))) a;

            SELECT @IDTabuladorNivelSalarialAumentosDesempeno=IDTabuladorNivelSalarialAumentosDesempeno
                  ,@IDTabuladorDesempeno=IDTabuladorDesempeno
            FROM [Nomina].[tblControlAumentosDesempeno]
            WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno
            


            DELETE FROM [Nomina].[tblControlAumentosDesempenoProyectos] WHERE IDControlAumentosDesempeno=@IDControlAumentosDesempeno
            DELETE FROM [Nomina].[tblControlAumentosDesempenoCiclosMedicion] WHERE IDControlAumentosDesempeno=@IDControlAumentosDesempeno

            DELETE m
            FROM IMSS.tblMovAfiliatorios m
            INNER JOIN Nomina.TblControlAumentosDesempenoDetalle d 
                ON m.IDMovAfiliatorio = d.IDMovAfiliatorio
            WHERE d.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

            DELETE FROM [Nomina].[tblControlAumentosDesempenoDetalle] WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

            DELETE FROM [Nomina].[tblControlAumentosDesempeno] WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
            

            DELETE FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle] WHERE IDTabuladorNivelSalarialAumentosDesempeno = @IDTabuladorNivelSalarialAumentosDesempeno
            DELETE FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno] WHERE IDTabuladorNivelSalarialAumentosDesempeno = @IDTabuladorNivelSalarialAumentosDesempeno

            DELETE FROM [Nomina].[tblTabuladorDesempenoDetalle] WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno
            DELETE FROM [Nomina].[tblTabuladorDesempeno] WHERE IDTabuladorDesempeno = @IDTabuladorDesempeno

            EXEC [RH].[spSincronizarEmpleadosMaster];
                    
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

            COMMIT TRANSACTION;

            -- Respuesta exitosa
            SELECT 'Registro eliminado correctamente.' AS Mensaje, 0 AS TipoRespuesta;
            RETURN;
        END
    END TRY  
    BEGIN CATCH  
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 'Ocurrió un error no controlado: ' + ERROR_MESSAGE() AS Mensaje, -1 AS TipoRespuesta;
    END CATCH;
END;
GO

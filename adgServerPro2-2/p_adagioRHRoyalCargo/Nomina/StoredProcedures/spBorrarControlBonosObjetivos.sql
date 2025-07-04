USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarControlBonosObjetivos](
    @IDControlBonosObjetivos INT,
    @ConfirmarEliminar BIT = 0,
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX) = '',
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarControlBonosObjetivos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivos]',
        @Accion VARCHAR(20) = 'DELETE',
        @Mensaje VARCHAR(MAX) = '',
        @IDTabuladorNivelSalarialBonosObjetivos INT,
        @IDTabuladorRelacionEvaluacionesObjetivos INT,              
        @TotalRegistros INT,        

        @Aplicado BIT;

    BEGIN TRY  
        SELECT @Aplicado = ISNULL(Aplicado, 0)
        FROM [Nomina].[tblControlBonosObjetivos]
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;


        SELECT @TotalRegistros = COUNT(*)
        FROM Nomina.tblControlBonosObjetivosDetalle
        WHERE IDControlBonosObjetivos=@IDControlBonosObjetivos
        

        IF(@Aplicado = 1 )
        BEGIN
            SELECT 'El cálculo no puede ser eliminado ya que se encuentra aplicado.' AS Mensaje, -1 AS TipoRespuesta;
            RETURN
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

            SELECT @OldJSON = a.JSON
            FROM (
                SELECT IDControlBonosObjetivos,Descripcion,Ejercicio,Aplicado
                FROM [Nomina].[tblControlBonosObjetivos]
                WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos
            ) b
            CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML RAW))) a;

            SELECT @IDTabuladorNivelSalarialBonosObjetivos = IDTabuladorNivelSalarialBonosObjetivos
                  ,@IDTabuladorRelacionEvaluacionesObjetivos = IDTabuladorRelacionEvaluacionesObjetivos
            FROM [Nomina].[tblControlBonosObjetivos]
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

            DELETE FROM [Nomina].[tblControlBonosObjetivosProyectos] 
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

            DELETE FROM [Nomina].[tblControlBonosObjetivosCiclosMedicion] 
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

            DELETE FROM [Nomina].[tblControlBonosObjetivos] 
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

            DELETE FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] 
            WHERE IDTabuladorNivelSalarialBonosObjetivos = @IDTabuladorNivelSalarialBonosObjetivos;

            DELETE FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivos] 
            WHERE IDTabuladorNivelSalarialBonosObjetivos = @IDTabuladorNivelSalarialBonosObjetivos;

            DELETE FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle] 
            WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

            DELETE FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos] 
            WHERE IDTabuladorRelacionEvaluacionesObjetivos = @IDTabuladorRelacionEvaluacionesObjetivos;

            EXEC [Auditoria].[spIAuditoria]
                @IDUsuario      = @IDUsuario,
                @Tabla          = @Tabla,
                @Procedimiento  = @NombreSP,
                @Accion         = @Accion,
                @NewData        = @NewJSON,
                @OldData        = @OldJSON;

            COMMIT TRANSACTION;

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

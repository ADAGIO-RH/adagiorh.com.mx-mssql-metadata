USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Expedientes Digitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
2024-01-16          Jose Vargas             añadir control del mensaje de error cuando se elimina un registro del que dependen otros registros.
***************************************************************************************************/


CREATE PROCEDURE [RH].[spBorrarCatExpedientesDigitales]
(
	@IDExpedienteDigital int,
	@IDUsuario int
)
AS
BEGIN

    SELECT
        [IDExpedienteDigital],
        [Codigo],
        [Descripcion],
        [Requerido],
        ROW_NUMBER() OVER (ORDER BY [IDExpedienteDigital]) AS ROWNUMBER
    INTO #TempCatExpedientesDigitales
    FROM [RH].[tblCatExpedientesDigitales]
    WHERE IDExpedienteDigital = @IDExpedienteDigital;


    BEGIN TRY        

        DELETE [RH].[tblCatExpedientesDigitales]
        WHERE IDExpedienteDigital = @IDExpedienteDigital;
        
        IF @@ROWCOUNT = 0
        BEGIN
            raiserror('No se encontró el registro para eliminar.', 16, 1);
        END
        ELSE
        BEGIN
            DECLARE @OldJSON VARCHAR(MAX);

            SELECT @OldJSON = a.JSON
            FROM #TempCatExpedientesDigitales b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML Raw))) a;            
            EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[RH].[tblCatExpedienteDigital]', '[RH].[spBorrarCatExpedientesDigitales]', 'DELETE', '', @OldJSON;            

            SELECT  * FROM #TempCatExpedientesDigitales
            DROP TABLE #TempCatExpedientesDigitales;
        END
    END TRY
    BEGIN CATCH        
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();        

        IF CHARINDEX('REFERENCE constraint', @ErrorMessage) > 0
        BEGIN
            raiserror('Este registro no puede ser eliminado ya que depende de otros.', @ErrorSeverity, 1);
        END
        ELSE
        BEGIN
            raiserror('Error no controlado.', @ErrorSeverity, 1);
        END
    END CATCH;
END
GO

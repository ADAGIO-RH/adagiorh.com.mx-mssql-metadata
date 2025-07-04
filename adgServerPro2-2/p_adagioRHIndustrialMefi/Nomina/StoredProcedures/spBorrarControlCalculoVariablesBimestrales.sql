USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Procedimiento de Borrar de Control de calculo de variables 
					  bimestrales.
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2024-07-09
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Nomina].[spBorrarControlCalculoVariablesBimestrales]
(
	@IDControlCalculoVariables int,
    @ConfirmarEliminar BIT=0,
	@IDUsuario int
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TransactionName VARCHAR(20) = 'TransBorrarControlCalculo';

    
	DECLARE 
        @OldJSON                              VARCHAR(MAX),
        @NewJSON                              VARCHAR(MAX),
        @EstatusActualControlCalculoVariables INT,
        @Mensaje                              VARCHAR(MAX) = '',
        @TotalRegistros                       INT;

    BEGIN TRANSACTION @TransactionName;

    BEGIN TRY
        
        SELECT @EstatusActualControlCalculoVariables = Aplicar
        FROM Nomina.tblControlCalculoVariablesBimestrales
        WHERE IDControlCalculoVariables = @IDControlCalculoVariables;

        
        SELECT @OldJSON = a.JSON 
        FROM [Nomina].[tblControlCalculoVariablesBimestrales] b
        CROSS APPLY (SELECT JSON=[Utilerias].[fnStrJSON](0,1,(SELECT b.* FOR XML RAW)) ) a
        WHERE b.IDControlCalculoVariables = @IDControlCalculoVariables;

        
        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblControlCalculoVariablesBimestrales]','[Nomina].[spBorrarControlCalculoVariablesBimestrales]','DELETE',@NewJSON,@OldJSON;

        
        IF(@EstatusActualControlCalculoVariables = 1 AND @ConfirmarEliminar = 0 )
        BEGIN
            SET @Mensaje = @Mensaje + '<li>El cálculo se encuentra aplicado</li>';
        END;

        IF ((SELECT COUNT(*) FROM Nomina.TblCalculoVariablesBimestralesMaster WHERE IDControlCalculoVariables = @IDControlCalculoVariables AND IDMovAfiliatorio IS NOT NULL) > 0 AND @ConfirmarEliminar = 0)
        BEGIN
            SELECT @TotalRegistros = COUNT(*) 
            FROM Nomina.TblCalculoVariablesBimestralesMaster 
            WHERE IDControlCalculoVariables = @IDControlCalculoVariables AND IDMovAfiliatorio IS NOT NULL;

            SET @Mensaje = @Mensaje + '<li>Se eliminarán ' + CAST(@TotalRegistros AS VARCHAR) + ' movimientos afiliatorios asociados a este cálculo</li>';                
        END;

        IF(@Mensaje IS NOT NULL AND @Mensaje <> '')
        BEGIN
            ROLLBACK TRANSACTION @TransactionName;
            SELECT @Mensaje AS Mensaje, 1 AS TipoRespuesta;
            RETURN;          
        END;
        ELSE
        BEGIN
            SET @ConfirmarEliminar = 1
        END
        
        IF(@ConfirmarEliminar = 1)
        BEGIN
            DELETE IMSS.tblMovAfiliatorios
            WHERE IDMovAfiliatorio IN(
                SELECT IDMovAfiliatorio 
                FROM Nomina.TblCalculoVariablesBimestralesMaster 
                WHERE IDControlCalculoVariables = @IDControlCalculoVariables AND IDMovAfiliatorio IS NOT NULL
            );

            DELETE [Nomina].[tblControlCalculoVariablesBimestrales]
            WHERE IDControlCalculoVariables = @IDControlCalculoVariables;

            EXEC [RH].[spSincronizarEmpleadosMaster]

            COMMIT TRANSACTION @TransactionName;
            SELECT 'Cálculo eliminado correctamente.' AS Mensaje, 0 AS TipoRespuesta;
            RETURN;
        END;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION @TransactionName;
        SELECT 'Ocurrio un error no controlado' AS Mensaje, -1 AS TipoRespuesta;
    END CATCH;
END
GO

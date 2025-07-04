USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualizar estatus del proyecto
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-06-14
** Paremetros		: @IDProyecto			- Identificador del proyecto.
					  @IDEstatus			- Identificador del estatus.
					  @IDUsuario			- Identificador del usuario.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Evaluacion360].[spIEstatusProyecto](
	@IDProyecto	INT
	,@IDEstatus	INT
	,@IDUsuario	INT
)
AS
	
	DECLARE @NewJSON VARCHAR(MAX);

	BEGIN TRY
	
		IF EXISTS(SELECT IDProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto)
		BEGIN						
			BEGIN TRAN										
				IF NOT EXISTS(SELECT TOP 1 1 FROM [Evaluacion360].[tblCatEstatus] WHERE IDEstatus = @IDEstatus AND IDTipoEstatus = 1)
				BEGIN
					EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318004'
					RETURN;
				END

				INSERT [Evaluacion360].[tblEstatusProyectos] ([IDProyecto],[IDEstatus],[IDUsuario])
				VALUES(@IDProyecto, @IDEstatus, @IDUsuario)

			IF @@ROWCOUNT = 1
				COMMIT TRAN
			ELSE
				ROLLBACK TRAN 

			SELECT @NewJSON = a.JSON FROM [Evaluacion360].[tblEstatusProyectos] b
			CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
			WHERE b.IDProyecto = @IDProyecto;

			EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Evaluacion360].[tblEstatusProyectos]', '[Evaluacion360].[spIEstatusProyecto]', 'INSERT', @NewJSON, '';
			
			exec [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]
		END		

	END TRY
		BEGIN CATCH
			ROLLBACK TRAN	
			SELECT ERROR_MESSAGE() AS ErrorMessage;
		END CATCH
GO

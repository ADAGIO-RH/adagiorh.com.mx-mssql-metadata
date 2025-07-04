USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUFiltroProyecto](
	 @IDFiltroProyecto	INT
	, @IDProyecto		INT
	, @TipoFiltro		VARCHAR(255)
	, @ID				VARCHAR(255)
	, @Descripcion		VARCHAR(255)
	, @IDUsuario		INT
) AS

	BEGIN TRY
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario;
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		RETURN 0;
	END CATCH

	IF(@IDFiltroProyecto = 0)
		BEGIN
		
			BEGIN TRY				
				
				INSERT INTO [Evaluacion360].[tblFiltrosProyectos](IDProyecto, TipoFiltro, ID, Descripcion)
				SELECT @IDProyecto, @TipoFiltro, @ID, @Descripcion;		
				SET @IDFiltroProyecto = @@IDENTITY

			END TRY
			BEGIN CATCH
				
				DECLARE @ErrorNumber INT = ERROR_NUMBER();
				DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
				
				IF(@ErrorNumber = 2627)
					BEGIN
						SET @ErrorMessage = 'El colaborador ya se encuentra registrado en la lista. No es posible duplicarlo'
					END

				RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;

			END CATCH

		END
	ELSE
		BEGIN
			UPDATE [Evaluacion360].[tblFiltrosProyectos]
			SET TipoFiltro = @TipoFiltro
				, ID = @ID
				, Descripcion = @Descripcion
			WHERE IDFiltroProyecto = @IDFiltroProyecto
		END;

	EXEC [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario;
	EXEC [Evaluacion360].[spBuscarFiltrosProyecto] @IDFiltroProyecto = @IDFiltroProyecto;
GO

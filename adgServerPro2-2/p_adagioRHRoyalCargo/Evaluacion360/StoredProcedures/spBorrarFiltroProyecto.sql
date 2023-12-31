USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spBorrarFiltroProyecto](
	@IDFiltroProyecto INT,
	@IDUsuario INT,
	@IDProyecto INT,
	@TipoFiltro VARCHAR(250)
)
AS

	IF OBJECT_ID('tempdb..#tempFiltrosProyectos') IS NOT NULL
		DROP TABLE #tempFiltrosProyectos;


	CREATE TABLE #tempFiltrosProyectos(
		IDFiltroProyecto INT
	)
	
	
	DECLARE @OldJSON VARCHAR(MAX) = '',
			@NewJSON VARCHAR(MAX),
			@NombreSP VARCHAR(MAX) = '[Evaluacion360].[spBorrarFiltroProyecto]',
			@Tabla VARCHAR(MAX) = '[Evaluacion360].[tblFiltrosProyectos]',
			@Accion VARCHAR(20) = 'DELETE',
			@Mensaje VARCHAR(MAX),
			@InformacionExtra VARCHAR(MAX),
			@IDFiltroProyectoAux INT = 0;
	

	BEGIN TRY
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		RETURN 0;
	END CATCH


	IF(@IDFiltroProyecto = 0)
		BEGIN
			
			INSERT INTO #tempFiltrosProyectos
			SELECT IDFiltroProyecto 
			FROM [Evaluacion360].[tblFiltrosProyectos] 
			WHERE IDProyecto = @IDProyecto AND
				  TipoFiltro = @TipoFiltro

		END
	ELSE
		BEGIN
			INSERT INTO #tempFiltrosProyectos VALUES(@IDFiltroProyecto)
		END


	SELECT @IDFiltroProyectoAux = MIN(IDFiltroProyecto) FROM #tempFiltrosProyectos;
	WHILE EXISTS(SELECT TOP 1 1 FROM #tempFiltrosProyectos WHERE IDFiltroProyecto >= @IDFiltroProyectoAux)
		BEGIN
						
			SELECT @OldJSON = a.JSON 
			FROM [Evaluacion360].[tblFiltrosProyectos] b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
			WHERE IDFiltroProyecto = @IDFiltroProyectoAux AND IDProyecto = @IDProyecto

			DELETE FROM [Evaluacion360].[tblFiltrosProyectos]
			WHERE IDFiltroProyecto = @IDFiltroProyectoAux AND IDProyecto = @IDProyecto

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		   = @IDUsuario
				,@Tabla			   = @Tabla
				,@Procedimiento	   = @NombreSP
				,@Accion		   = @Accion
				,@NewData		   = @NewJSON
				,@OldData		   = @OldJSON
				,@Mensaje		   = @Mensaje
				,@InformacionExtra = @InformacionExtra


			SELECT @IDFiltroProyectoAux = MIN(IDFiltroProyecto) from #tempFiltrosProyectos where IDFiltroProyecto > @IDFiltroProyectoAux

		END

	   	 
	EXEC [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
GO

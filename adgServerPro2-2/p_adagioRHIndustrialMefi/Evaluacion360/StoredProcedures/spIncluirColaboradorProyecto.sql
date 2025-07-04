USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Incluir colaborador excluido a proyecto
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-12-12
** Paremetros		: @IDProyecto	Identificador del proyecto
**					: @IDEmpleado	Identificador del empleado a evaluar
**					: @IDUsuario	Identificador del usuario
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spIncluirColaboradorProyecto](
	@IDProyecto INT,
	@IDEmpleado INT,
	@IDUsuario	INT
) AS
	
	BEGIN
		
		DECLARE @IDFiltroProyecto INT = 0
				, @EXCLUIR_EMPLEADO VARCHAR(25) = 'Excluir Empleado'
				, @OldJSON VARCHAR(MAX) = ''
				, @NewJSON VARCHAR(MAX)
				, @NombreSP VARCHAR(MAX) = '[Evaluacion360].[spIncluirColaboradorProyecto]'
				, @Tabla VARCHAR(MAX) = '[Evaluacion360].[tblFiltrosProyectos]'
				, @Accion VARCHAR(20) = 'DELETE'
				, @Mensaje VARCHAR(MAX)
				, @InformacionExtra VARCHAR(MAX)
				;

		BEGIN TRY
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
		END TRY
		BEGIN CATCH
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			RETURN 0;
		END CATCH
		

		-- BUSCAMOS FILTRO
		SELECT @IDFiltroProyecto = IDFiltroProyecto
		FROM [Evaluacion360].[tblFiltrosProyectos] 
		WHERE IDProyecto = @IDProyecto
			  AND ID = @IDEmpleado
			  AND TipoFiltro = @EXCLUIR_EMPLEADO		

	
		-- ELIMINAMOS FILTRO
		IF(@IDFiltroProyecto > 0)
			BEGIN

				SELECT @OldJSON = a.JSON 
				FROM [Evaluacion360].[tblFiltrosProyectos] b
					CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
				WHERE IDFiltroProyecto = @IDFiltroProyecto AND IDProyecto = @IDProyecto	AND TipoFiltro = @EXCLUIR_EMPLEADO

				DELETE FROM [Evaluacion360].[tblFiltrosProyectos]
				WHERE IDFiltroProyecto = @IDFiltroProyecto AND IDProyecto = @IDProyecto	AND TipoFiltro = @EXCLUIR_EMPLEADO

				EXEC [Auditoria].[spIAuditoria]
					@IDUsuario		   = @IDUsuario
					,@Tabla			   = @Tabla
					,@Procedimiento	   = @NombreSP
					,@Accion		   = @Accion
					,@NewData		   = @NewJSON
					,@OldData		   = @OldJSON
					,@Mensaje		   = @Mensaje
					,@InformacionExtra = @InformacionExtra
				
				-- REASIGNA EMPLEADOS AL PROYECTO
				EXEC [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario

			END	

	END
GO

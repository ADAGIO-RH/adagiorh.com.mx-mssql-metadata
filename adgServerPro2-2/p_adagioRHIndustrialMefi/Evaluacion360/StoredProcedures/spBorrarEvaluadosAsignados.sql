USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Elimina los colaboradores asignados del @IDEmpleado para evaluar
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-09-28
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spBorrarEvaluadosAsignados](
	@IDEvaluacionEmpleado INT,
	@IDUsuario INT,
	@IDProyecto INT,
	@IDEvaluador INT,
	@IDTipoRelacion INT
)
AS

	--IF OBJECT_ID('tempdb..#tempEvaluadosAsignados') IS NOT NULL
	--	DROP TABLE #tempEvaluadosAsignados;


	--CREATE TABLE #tempEvaluadosAsignados(
	DECLARE @tempEvaluadosAsignados TABLE(
		IDEvaluacionEmpleado INT		
	)
	
	
	DECLARE @OldJSON VARCHAR(MAX) = '',
			@NewJSON VARCHAR(MAX),
			@NombreSP VARCHAR(MAX) = '[Evaluacion360].[spBorrarEvaluadosAsignados]',
			@Tabla VARCHAR(MAX) = '[Evaluacion360].[tblEvaluacionesEmpleados]',
			@Accion VARCHAR(20) = 'DELETE',
			@Mensaje VARCHAR(MAX),
			@InformacionExtra VARCHAR(MAX),
			@IDEvaluacionEmpleadoAux INT = 0;
	

	BEGIN TRY
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		RETURN 0;
	END CATCH


	IF(@IDEvaluacionEmpleado = 0)
		BEGIN			
			INSERT INTO @tempEvaluadosAsignados
			SELECT EE.IDEvaluacionEmpleado
			FROM [Evaluacion360].[tblEmpleadosProyectos] EP
				JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
				JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON EE.IDTipoRelacion = TP.IDTipoRelacion
			WHERE EP.IDProyecto = @IDProyecto AND
				  EE.IDEvaluador = @IDEvaluador AND
				  EE.IDTipoRelacion = @IDTipoRelacion
		END
	ELSE
		BEGIN
			INSERT INTO @tempEvaluadosAsignados VALUES(@IDEvaluacionEmpleado)
		END	

	
	SELECT @IDEvaluacionEmpleadoAux = MIN(IDEvaluacionEmpleado) FROM @tempEvaluadosAsignados;
	WHILE EXISTS(SELECT TOP 1 1 FROM @tempEvaluadosAsignados WHERE IDEvaluacionEmpleado >= @IDEvaluacionEmpleadoAux)
		BEGIN

			SELECT @OldJSON = a.JSON 
			FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE	
				JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
				JOIN [RH].[tblEmpleadosMaster] E ON EE.IDEvaluador = E.IDEmpleado
				JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON EE.IDTipoRelacion = TP.IDTipoRelacion
				JOIN [RH].[tblEmpleadosMaster] EMP ON EP.IDEmpleado = EMP.IDEmpleado
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT EE.*, TP.Relacion, E.NOMBRECOMPLETO AS Evaluador, EMP.NOMBRECOMPLETO AS Colaborador FOR XML RAW))) a
			WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleadoAux
			

			DELETE FROM [Evaluacion360].[tblEvaluacionesEmpleados]
			WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleadoAux

			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario		   = @IDUsuario
				,@Tabla			   = @Tabla
				,@Procedimiento	   = @NombreSP
				,@Accion		   = @Accion
				,@NewData		   = @NewJSON
				,@OldData		   = @OldJSON
				,@Mensaje		   = @Mensaje
				,@InformacionExtra = @InformacionExtra
			

			SELECT @IDEvaluacionEmpleadoAux = MIN(IDEvaluacionEmpleado) from @tempEvaluadosAsignados where IDEvaluacionEmpleado > @IDEvaluacionEmpleadoAux

		END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Asigna el estatus ESPERANDO APROBACION
** Autor			: Alejandro Paredes
** FechaCreacion	: 2024-08-20
** Paremetros		: @IDProyecto	Identificador del proyecto.
					  @IDUsuario	Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?

***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spEstatusEsperandoAprobacion] (
	@IDProyecto		INT,
	@IDUsuario		INT
) AS

	DECLARE 
		@RelacionesProyecto Evaluacion360.dtRelacionesProyectoFilter
		, @AsignacionesPendientes INT = 0
		, @ESPERANDO_APROBACION INT = 2
		, @SIN_ESTATUS INT = -1
		, @PENDIENTE_DE_ASIGNACIONES INT = 10
		;

	-- EVALUADOR SIN ESTATUS
	INSERT @RelacionesProyecto
	EXEC [Evaluacion360].[spBuscarRelacionesProyectoFilter] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario, @IDEstatusEvaluacion = @SIN_ESTATUS;

	-- EVALUADOR PENDIENTES DE ASIGAR
	INSERT @RelacionesProyecto
	EXEC [Evaluacion360].[spBuscarRelacionesProyectoFilter] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario, @IDEstatusEvaluacion = @PENDIENTE_DE_ASIGNACIONES;

	-- OBTENEMOS EL NUMERO DE EVALUACIONES REQUERIDAS
	SELECT @AsignacionesPendientes = COUNT(IDEmpleadoProyecto) FROM @RelacionesProyecto WHERE Requerido = 1;

	IF(@AsignacionesPendientes = 0)
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM [Evaluacion360].[tblEstatusProyectos] WHERE IDProyecto = @IDProyecto AND IDEstatus = @ESPERANDO_APROBACION)
			BEGIN
				INSERT [Evaluacion360].[tblEstatusProyectos] ([IDProyecto],[IDEstatus],[IDUsuario])
				VALUES(@IDProyecto,@ESPERANDO_APROBACION,@IDUsuario)

				EXEC [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]
			END	
		END
GO

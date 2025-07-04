USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Manejador de invitaciones para las direfentes tipos de evaluaciones.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-10-21
** Parametros		: @IDProyecto	Identificador del proyecto
**					: @IDUsuario	Identificador del usuario
** IDAzure			: #1209

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spGenerarInvitaciones](
	 @IDProyecto	INT
	 , @IDUsuario	INT
) AS
	BEGIN
		
		DECLARE @IDTipoProyecto				INT = 0
				, @EVALUACION_360			INT = 1
				, @EVALUACION_DESEMPENO		INT = 2
				, @EVALUACION_CLIMA_LABORAL INT = 3
				, @EVALUACION_ENCUESTA		INT = 4
				;


		-- OBTENEMOS EL TIPO DEL PROYECTO
		SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;

		-- ***** CREAR INVITACIONES EN LOS DIFERENTES TIPOS DE EVALUACIONES *****
		IF(@IDTipoProyecto = @EVALUACION_360)
			BEGIN
				EXEC [Evaluacion360].[spIInvitacionesEvaluacion360] @IDProyecto, @IDUsuario
			END

		IF(@IDTipoProyecto = @EVALUACION_DESEMPENO)
			BEGIN
				EXEC [Evaluacion360].[spIInvitacionesEvaluacionDesempeno] @IDProyecto, @IDUsuario
			END

		IF(@IDTipoProyecto = @EVALUACION_CLIMA_LABORAL)
			BEGIN
				EXEC [Evaluacion360].[spIInvitacionesEvaluacionClimaLaboral] @IDProyecto, @IDUsuario
			END

		IF(@IDTipoProyecto = @EVALUACION_ENCUESTA)
			BEGIN
				EXEC [Evaluacion360].[spIInvitacionesEvaluacionEncuesta] @IDProyecto, @IDUsuario
			END

 END
GO

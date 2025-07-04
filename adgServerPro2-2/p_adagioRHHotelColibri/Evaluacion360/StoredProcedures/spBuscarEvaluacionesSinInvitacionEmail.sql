USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca evaluaciones sin invitación enviada por email.
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

CREATE   PROC [Evaluacion360].[spBuscarEvaluacionesSinInvitacionEmail](
	@IDProyecto		INT = 0	
	, @IDUsuario	INT = 0
)
AS
	BEGIN

		/*
			TIPOS PROYECTOS CON SU IDTipoNotificacion
			1.- EVALUACIÓN 360				/ (InvitacionRealizar360)
			2.- EVALUACIÓN DESEMPEÑO		/ (InvitacionRealizarDesempeno)
			3.- EVALUACIÓN CLIMA LABORAL	/ (InvitacionRealizarClimaLaboral)
			4.- EVALUACIÓN ENCUESTA			/ (InvitacionRealizarEncuesta)
		*/ 
		
		-- VARIABLES
		DECLARE @IDTipoProyecto		INT = 0
				, @IDTipoNotificacion	VARCHAR(50) = NULL
				, @Tabla				VARCHAR(100) = NULL	
				, @SQL					NVARCHAR(MAX);
				;

		-- OBTENEMOS EL @IDTipoProyecto 
		SELECT @IDTipoProyecto = IDTipoProyecto FROM [Evaluacion360].[tblCatProyectos] WHERE IDProyecto = @IDProyecto;

		-- OBTENEMOS DE LA FUNCION EL IDTipoNotificacion y Tabla A PARTIR DEL @IDTipoProyecto
		SELECT @IDTipoNotificacion = IDTipoNotificacion
				, @Tabla = Tabla				
		FROM [Evaluacion360].[fnObtenerNotificacionInvitacion](@IDTipoProyecto);


		-- FILTRAMOS LAS EVALUACIONES SIN INVITACION ENVIADA POR EMAIL
		-- VALIDAMOS CON EL "NOT EXISTS" QUE NO EXISTAN LAS INVITACIONES EN "[App].[tblEnviarNotificacionA]"
		SET @SQL = N'
					SELECT I.IDInvitacion
							, U.IDUsuario AS IDUsuarioEvaluador
							, I.IDEvaluador AS IDEmpleadoEvaluador
					FROM ' + @Tabla + ' I
						JOIN [Seguridad].[tblUsuarios] U ON I.IDEvaluador = U.IDEmpleado
					WHERE I.IDProyecto = ' + CAST(@IDProyecto AS VARCHAR(25)) + '
					  AND NOT EXISTS (
										SELECT TOP 1 NA.IDEnviarNotificacionA
										FROM [App].[tblEnviarNotificacionA] NA
											JOIN [App].[tblNotificaciones] N ON NA.IDNotifiacion = N.IDNotifiacion
										WHERE NA.IDMedioNotificacion = ''Email''
											AND NA.TipoReferencia = ''' + @Tabla + '''
											AND NA.IDReferencia = I.IDInvitacion
											AND N.IDTipoNotificacion = ''' + @IDTipoNotificacion + '''
									);';
		--PRINT @SQL;


		-- EJECUTAMOS EL SQL DINÁMICO
		EXEC sp_executesql @SQL;		

	END
GO

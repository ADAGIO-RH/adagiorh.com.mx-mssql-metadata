USE [p_adagioRHFabricasSelectas]
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
		DECLARE @IDIdioma			VARCHAR(20)
				, @IDTipoProyecto	INT = 0
				, @TipoNotificacion	VARCHAR(50) = NULL
				, @Tabla			VARCHAR(100) = NULL	
				, @SQL				NVARCHAR(MAX);
				;
		
		-- IDENTIFICAMOS EL IDIOMA
		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		-- OBTENEMOS EL @IDTipoProyecto 
		SELECT @IDTipoProyecto = IDTipoProyecto FROM Evaluacion360.tblCatProyectos WHERE IDProyecto = @IDProyecto;

		-- OBTENEMOS DE LA FUNCION EL IDTipoProyecto y DataSource A PARTIR DEL @IDTipoProyecto
		SELECT @TipoNotificacion = TipoNotificacion
				, @Tabla = Tabla				
		FROM [Evaluacion360].[fnObtenerTipoNotificacionPorTipoProyecto](@IDTipoProyecto);


		-- FILTRAMOS LAS EVALUACIONES SIN INVITACION ENVIADA POR EMAIL
		-- VALIDAMOS CON EL "NOT EXISTS" QUE NO EXISTAN LAS INVITACIONES EN "[App].[tblEnviarNotificacionA]"
		SET @SQL = N'
					SELECT I.IDInvitacion
					FROM ' + @Tabla + ' I
					WHERE I.IDProyecto = ' + CAST(@IDProyecto AS VARCHAR(25)) + '
					  AND NOT EXISTS (
										SELECT TOP 1 NA.IDEnviarNotificacionA
										FROM [App].[tblEnviarNotificacionA] NA
											JOIN [App].[tblNotificaciones] N ON NA.IDNotifiacion = N.IDNotifiacion
										WHERE NA.IDMedioNotificacion = ''Email''
											AND NA.TipoReferencia = ''' + @Tabla + '''
											AND NA.IDReferencia = I.IDInvitacion
											AND N.IDTipoNotificacion = ''' + @TipoNotificacion + '''
											AND N.IDIdioma = ''' + @IDIdioma + '''
									);';
		--PRINT @SQL;


		-- EJECUTAMOS EL SQL DINÁMICO
		EXEC sp_executesql @SQL;		

	END
GO

USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea notificaciones para invitar a los colaboradores a completar sus evaluaciones.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-10-07
** Parametros		: @IDTipoProyecto		Idenfificador del tipo de proyecto
**					: @dtInvitaciones		Lista de invitaciones.
**					: @IDUsuario			Identificador del usuario.
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spINotificacionesInvitacionDeEvaluaciones] (
    @IDTipoProyecto			INT
	, @dtInvitaciones		[App].[dtNotificacionesEmails] READONLY
	, @IDUsuario			INT
)
AS
BEGIN

	/*
		TIPOS PROYECTOS
		1.- EVALUACIÓN 360
		2.- EVALUACIÓN DESEMPEÑO
		3.- EVALUACIÓN CLIMA LABORAL
		4.- EVALUACIÓN ENCUESTA
	*/ 	

    SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#tblInvitacionesAux') IS NOT NULL DROP TABLE #tblInvitacionesAux;
	IF OBJECT_ID('tempdb..#tblInvitaciones') IS NOT NULL DROP TABLE #tblInvitaciones;
    
	-- VARIABLES
    DECLARE @IDTipoNotificacion	VARCHAR(50) = NULL
			, @Tabla				VARCHAR(100) = NULL	
			, @SQL					NVARCHAR(MAX)
			, @ContTotal			INT = 0
			, @IDNotificacion		INT = 0
			, @FechaHoraCreacion	DATETIME = GETDATE()
			, @NO_ENVIADO           INT = 0
			, @ErrorMessage			NVARCHAR(4000)
			;

	
	-- TABLAS TESMPORALES

	CREATE TABLE #tblInvitacionesAux(        
		IDTipoNotificacion		VARCHAR(50)
		, [Subject]				VARCHAR(MAX)
		, Body					TEXT
		, Footer				TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			INT
    );

    CREATE TABLE #tblInvitaciones(
        ID						INT IDENTITY(1,1)
		, IDTipoNotificacion	VARCHAR(50)
		, [Subject]				VARCHAR(MAX)
		, Body					TEXT
		, Footer				TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			INT
		, IDEvaluador			INT
		, Email					NVARCHAR(255)
    );

    DECLARE @tblDestinatarios TABLE (
        ID						INT
		, IDTipoNotificacion    VARCHAR(50)
		, [Subject]             VARCHAR(MAX)
		, Body                  TEXT
		, Footer                TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			VARCHAR(255)
		, IDEvaluador           INT
		, Email                 NVARCHAR(MAX)
    );


	-- TRASPASAMOS LOS DATOS DE LA TABLA VARIABLE A LA TABLA TEMPORAL FISICA
	INSERT INTO #tblInvitacionesAux
	SELECT * FROM @dtInvitaciones

		
	-- OBTENEMOS DE LA FUNCION EL IDTipoNotificacion y Tabla A PARTIR DEL @IDTipoProyecto
	SELECT @IDTipoNotificacion = IDTipoNotificacion
			, @Tabla = Tabla				
	FROM [Evaluacion360].[fnObtenerNotificacionInvitacion](@IDTipoProyecto);
	

	-- OBTENEMOS LAS INVITACIONES NUEVAS
	-- VALIDAMOS CON EL "NOT EXISTS" QUE NO EXISTAN LAS INVITACIONES EN "[App].[tblEnviarNotificacionA]"
	SET @SQL = N'
				INSERT INTO #tblInvitaciones (IDTipoNotificacion, [Subject], Body, Footer, TipoReferencia, IDReferencia, IDEvaluador, Email)
				SELECT I.IDTipoNotificacion
						, I.[Subject]
						, I.Body
						, I.Footer
						, I.TipoReferencia
						, I.IDReferencia
						, TBL_DINAMICA.IDEvaluador
						, [Utilerias].[fnGetCorreoEmpleado] (TBL_DINAMICA.IDEvaluador, 0, I.IDTipoNotificacion) AS Email
				FROM #tblInvitacionesAux I
					JOIN ' + @Tabla + ' TBL_DINAMICA ON I.IDReferencia = TBL_DINAMICA.IDInvitacion
				WHERE NOT EXISTS (
									SELECT TOP 1 NA.IDEnviarNotificacionA
									FROM [App].[tblEnviarNotificacionA] NA
										JOIN [App].[tblNotificaciones] N ON NA.IDNotifiacion = N.IDNotifiacion
									WHERE NA.IDMedioNotificacion = ''Email''
										AND NA.TipoReferencia = ''' + @Tabla + '''
										AND NA.IDReferencia = I.IDReferencia
										AND N.IDTipoNotificacion = ''' + @IDTipoNotificacion + '''
									);';
	--PRINT @SQL;
	
	-- EJECUTAMOS EL SQL DINÁMICO
	EXEC sp_executesql @SQL;	
	--SELECT * FROM #tblInvitaciones

	-- CONTAMOS INVITACIONES
	SELECT @ContTotal = COUNT(ID) FROM #tblInvitaciones;
			
	-- INICIAR TRANSACCIÓN
    BEGIN TRANSACTION;
		BEGIN TRY

			-- CONTAR EL TOTAL DE INVITACIONES			
			IF (@ContTotal > 0)
				BEGIN			

					-- INSERTAR LA NOTIFICACIÓN
					INSERT INTO [App].[tblNotificaciones] (IDTipoNotificacion, FechaHoraCreacion, Parametros, IDIdioma)
					SELECT TOP 1 IDTipoNotificacion
							, @FechaHoraCreacion
							, NULL AS Parametros
							, NULL AS IDIdioma
					FROM #tblInvitaciones;

					-- OBTENEMOS EL ID GENERADO DE LA NOTIFICACIÓN
					SET @IDNotificacion = SCOPE_IDENTITY();


					-- INSERTAR DESTINATARIOS EN LA TABLA TEMPORAL
					INSERT INTO @tblDestinatarios
					SELECT I.ID
							, I.IDTipoNotificacion
							, I.[Subject]
							, I.Body
							, I.Footer
							, I.TipoReferencia
							, I.IDReferencia							
							, I.IDEvaluador
							, I.Email
							--, 'aparedes@adagio.com.mx' AS Email
					FROM #tblInvitaciones I
					--SELECT * FROM @tblDestinatarios
					

					-- INSERTAR LAS NOTIFICACIONES A ENVIAR (SOLO COLABORADORES QUE TENGAS EMAIL BIEN CONFIGURADO)
					INSERT INTO [App].[tblEnviarNotificacionA](IDNotifiacion, IDMedioNotificacion, Destinatario, Enviado, FechaHoraEnvio, FechaHoraCreacion, Adjuntos, IDTipoAdjunto, Parametros, TipoReferencia, IDReferencia,IDUsuario)
					SELECT @IDNotificacion AS IDNotificacion
							, 'Email' AS IDMedioNotificacion
							, TD.Email AS Destinatario
							, @NO_ENVIADO AS Enviado
							, NULL AS FechaHoraEnvio
							, @FechaHoraCreacion AS FechaHoraCreacion
							, NULL AS Adjuntos
							, NULL AS IDTipoAdjunto
							, '{ "subject": "' + [Subject] + '", "body":"' + REPLACE(CAST(Body AS VARCHAR(MAX)), '"', '\"') + '", "footer":"' + REPLACE(CAST(Footer AS VARCHAR(MAX)), '"', '\"') + '" }' AS Parametros
							, TD.TipoReferencia
							, TD.IDReferencia
                            ,u.IDUsuario
					FROM @tblDestinatarios TD
                    left join  Seguridad.tblUsuarios u on u.IDEmpleado=td.IDEvaluador
					WHERE TD.Email IS NOT NULL
					

					-- REVISAR
					--SELECT * FROM [App].[tblNotificaciones] WHERE IDNotifiacion = @IDNotificacion
					--SELECT * FROM [App].[tblEnviarNotificacionA] WHERE IDNotifiacion = @IDNotificacion

				END;
				

			-- CONFIRMAR TRANSACCION
			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH

			-- REVERTIR TRANSACCIÓN EN CASO DE ERROR
			IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRANSACTION;
			END			
			
			SELECT @ErrorMessage = ERROR_MESSAGE();
			RAISERROR (@ErrorMessage, 16, 1);

		END CATCH;
END;
GO

USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Genera notificaciones para la entrega de resultados a los colaboradores evaluados.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-23
** Parametros		: @IDTipoProyecto		Idenfificador del tipo de proyecto
**					: @dtEntregaResultados	Lista de la entrega de resultados.
**					: @IDUsuario			Identificador del usuario.
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spINotificacionesEntregaDeResultadosEvaluado] (
    @IDTipoProyecto			INT
	, @dtEntregaResultado	[App].[dtNotificacionesEmails] READONLY
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
	
    
	-- VARIABLES
    DECLARE @Tabla				VARCHAR(100) = NULL	
			, @SQL					NVARCHAR(MAX)
			, @ContTotal			INT = 0
			, @IDNotificacion		INT = 0
			, @FechaHoraCreacion	DATETIME = GETDATE()
			, @NO_ENVIADO           INT = 0
			, @ErrorMessage			NVARCHAR(4000)
			;


	-- TABLAS TESMPORALES

	CREATE TABLE #tblEntregaResultadoAux(        
		IDTipoNotificacion		VARCHAR(50)
		, [Subject]				VARCHAR(MAX)
		, Body					TEXT
		, Footer				TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			INT
    );

	CREATE TABLE #tblEntregaResultado(
        ID						INT IDENTITY(1,1)
		, IDTipoNotificacion	VARCHAR(50)
		, [Subject]				VARCHAR(MAX)
		, Body					TEXT
		, Footer				TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			INT
		, IDEvaluado			INT
		, Email					NVARCHAR(255)
		, PathFile				VARCHAR(MAX)
    );

    DECLARE @tblDestinatarios TABLE (
        ID						INT
		, IDTipoNotificacion    VARCHAR(50)
		, [Subject]             VARCHAR(MAX)
		, Body                  TEXT
		, Footer                TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			VARCHAR(255)
		, IDEvaluado			INT
		, Email                 NVARCHAR(MAX)
		, PathFile				VARCHAR(MAX)
    );


	-- TRASPASAMOS LOS DATOS DE LA TABLA VARIABLE A LA TABLA TEMPORAL FISICA
	INSERT INTO #tblEntregaResultadoAux
	SELECT * FROM @dtEntregaResultado


	-- OBTENEMOS DE LA FUNCION LA Tabla A PARTIR DEL @IDTipoProyecto
	SELECT @Tabla = TablaEvaluado FROM [Evaluacion360].[fnObtenerNotificacionEntregaDeResultadosEvaluado](@IDTipoProyecto);
	
	
	-- OBTENEMOS LOS RECORDATORIOS NUEVOS DE LA TABLA SOLICITADA	
	SET @SQL = N'
				INSERT INTO #tblEntregaResultado (IDTipoNotificacion, [Subject], Body, Footer, TipoReferencia, IDReferencia, IDEvaluado, Email, PathFile)
				SELECT R.IDTipoNotificacion
						, R.[Subject]
						, R.Body
						, R.Footer
						, R.TipoReferencia
						, R.IDReferencia
						, TBL_DINAMICA.IDEvaluado
						, TBL_DINAMICA.Email
						, ARCHIVO.pathFile
				FROM #tblEntregaResultadoAux R
					JOIN ' + @Tabla + ' TBL_DINAMICA ON R.IDReferencia = TBL_DINAMICA.IDEntregaDeResultado
					JOIN [App].[tblAdgFiles] ARCHIVO ON ARCHIVO.IDAdgFile = TBL_DINAMICA.IDAdgFile
				WHERE TBL_DINAMICA.EmailValid = 1;';
	PRINT @SQL;

	-- EJECUTAMOS EL SQL DINÁMICO
	EXEC sp_executesql @SQL;	
	--SELECT * FROM #tblEntregaResultado
	
	-- CONTAMOS LOS RECORDATORIOS
	SELECT @ContTotal = COUNT(ID) FROM #tblEntregaResultado;
			
	-- INICIAR TRANSACCIÓN
    BEGIN TRANSACTION;
		BEGIN TRY
								
			IF (@ContTotal > 0)
				BEGIN
				
					-- INSERTAR LA NOTIFICACIÓN
					INSERT INTO [App].[tblNotificaciones] (IDTipoNotificacion, FechaHoraCreacion, Parametros, IDIdioma)
					SELECT TOP 1 IDTipoNotificacion
							, @FechaHoraCreacion
							, NULL AS Parametros
							, NULL AS IDIdioma
					FROM #tblEntregaResultado;

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
							, I.IDEvaluado
							, I.Email
							--, 'aparedes@adagio.com.mx' AS Email
							, PathFile
					FROM #tblEntregaResultado I
					--SELECT * FROM @tblDestinatarios
					

					-- INSERTAR LAS NOTIFICACIONES A ENVIAR (SOLO COLABORADORES QUE TENGAS EMAIL BIEN CONFIGURADO)
					INSERT INTO [App].[tblEnviarNotificacionA](IDNotifiacion, IDMedioNotificacion, Destinatario, Enviado, FechaHoraEnvio, FechaHoraCreacion, Adjuntos, IDTipoAdjunto, Parametros, TipoReferencia, IDReferencia,IDUsuario)
					SELECT @IDNotificacion AS IDNotificacion
							, 'Email' AS IDMedioNotificacion
							, TD.Email AS Destinatario
							, @NO_ENVIADO AS Enviado
							, NULL AS FechaHoraEnvio
							, @FechaHoraCreacion AS FechaHoraCreacion
							, TD.PathFile AS Adjuntos
							, NULL AS IDTipoAdjunto
							, '{ "subject": "' + TD.[Subject] + '", "body":"' + REPLACE(CAST(TD.Body AS VARCHAR(MAX)), '"', '\"') + '", "footer":"' + REPLACE(CAST(TD.Footer AS VARCHAR(MAX)), '"', '\"') + '" }' AS Parametros
							, TD.TipoReferencia
							, TD.IDReferencia
                            , u.IDUsuario
					FROM @tblDestinatarios TD
                    left join Seguridad.tblUsuarios u on u.IDEmpleado=TD.IDEvaluado
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

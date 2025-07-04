USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Genera notificaciones al clonar un proyecto.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-01-27
** Parametros		: @dtProyectoClonado		Lista de notificaciones para los editores.
**					: @IDUsuario				Identificador del usuario.
** IDAzure			: #1346

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spINotificacionesProyectoClonado] (    
	@dtProyectoClonado		[App].[dtNotificacionesEmails] READONLY
	, @IDUsuario			INT
)
AS
BEGIN
 	
    SET NOCOUNT ON;	


	-- VARIABLES
    DECLARE @ContTotal			INT = 0
			, @IDNotificacion		INT = 0
			, @FechaHoraCreacion	DATETIME = GETDATE()
			, @SI					BIT = 1
			, @NO_ENVIADO           INT = 0			
			, @ErrorMessage			NVARCHAR(4000)			
			;


	-- TABLAS TEMPORALES

	DECLARE @tblProyectoClonado TABLE(
        ID						INT IDENTITY(1,1)
		, IDTipoNotificacion	VARCHAR(50)
		, [Subject]				VARCHAR(MAX)
		, Body					TEXT
		, Footer				TEXT
		, TipoReferencia		VARCHAR(255)
		, IDReferencia			INT
		, IDEditor				INT
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
		, IDEditor				INT
		, Email                 NVARCHAR(MAX)
		, PathFile				VARCHAR(MAX)
    );


	-- TRASPASAMOS LOS DATOS DEL DATATYPE "@dtProyectoClonado" A LA TABLA "@tblProyectoClonado"
	INSERT INTO @tblProyectoClonado
	SELECT D_PC.IDTipoNotificacion
			, D_PC.[Subject]
			, D_PC.Body
			, D_PC.Footer
			, D_PC.TipoReferencia
			, D_PC.IDReferencia
			, T_PC.IDEditor
			, T_PC.Email
			, NULL AS PathFile
	FROM @dtProyectoClonado D_PC
		JOIN [Evaluacion360].[tblProyectosClonados] T_PC ON D_PC.IDReferencia = T_PC.IDClon		
	WHERE T_PC.EmailValid = @SI
	-- SELECT * FROM @tblProyectoClonado

	
	-- CONTAMOS LAS NOTIFICACIONES
	SELECT @ContTotal = COUNT(ID) FROM @tblProyectoClonado;
			
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
					FROM @tblProyectoClonado;

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
							, I.IDEditor
							, I.Email
							--, 'aparedes@adagio.com.mx' AS Email
							, PathFile
					FROM @tblProyectoClonado I
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
                    left join Seguridad.tblUsuarios u on u.IDEmpleado=td.IDEditor
					

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

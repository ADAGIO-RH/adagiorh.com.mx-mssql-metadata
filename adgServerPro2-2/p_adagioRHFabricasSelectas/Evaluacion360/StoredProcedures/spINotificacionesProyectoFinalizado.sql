USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Genera notificaciones para la entrega de resultados a los editores al finalizar el proyecto.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-01-13
** Parametros		: @dtProyectoFinalizado		Lista de notificaciones para los editores.
**					: @IDUsuario				Identificador del usuario.
** IDAzure			: #1323

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spINotificacionesProyectoFinalizado] (    
	@dtProyectoFinalizado	[App].[dtNotificacionesEmails] READONLY
	, @IDUsuario			INT
)
AS
BEGIN
 	
    SET NOCOUNT ON;	


	-- VARIABLES
    DECLARE @RutaFisica			NVARCHAR(MAX)
			, @ContTotal			INT = 0
			, @IDNotificacion		INT = 0
			, @FechaHoraCreacion	DATETIME = GETDATE()
			, @SI					BIT = 1
			, @NO_ENVIADO           INT = 0
			, @POR_RUTA_DE_ARCHIVO	INT = 2
			, @ErrorMessage			NVARCHAR(4000)
			, @EVALUACION_360		INT = 1
			;


	-- TABLAS TEMPORALES

	DECLARE @tblProyectoFinalizado TABLE(
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

	
	-- OBTENEMOS LA RETU FISICA PARA OBTENER EL ADJUNTO
	SELECT @RutaFisica = Valor 
	FROM [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
	WHERE IDConfiguracion = 'RutaFisica';


	-- TRASPASAMOS LOS DATOS DEL DATATYPE "@dtProyectoFinalizado" A LA TABLA "@tblProyectoFinalizado"
	INSERT INTO @tblProyectoFinalizado
	SELECT D_PF.IDTipoNotificacion
			, D_PF.[Subject]
			, D_PF.Body
			, D_PF.Footer
			, D_PF.TipoReferencia
			, D_PF.IDReferencia
			, T_PF.IDEditor
			, T_PF.Email
			, CASE 
				WHEN P.IDTipoProyecto = @EVALUACION_360
					THEN @RutaFisica + 'Evaluacion360\Reportes\Proyecto__' + CAST(T_PF.IDProyecto AS VARCHAR(25)) + '.zip'
					ELSE NULL
				END AS PathFile
	FROM @dtProyectoFinalizado D_PF
		JOIN [Evaluacion360].[tblProyectosFinalizados] T_PF ON D_PF.IDReferencia = T_PF.ID
		JOIN [Evaluacion360].[tblCatProyectos] P ON T_PF.IDProyecto = P.IDProyecto
	WHERE T_PF.EmailValid = @SI
	-- SELECT * FROM @tblProyectoFinalizado

	
	-- CONTAMOS LAS NOTIFICACIONES
	SELECT @ContTotal = COUNT(ID) FROM @tblProyectoFinalizado;
			
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
					FROM @tblProyectoFinalizado;

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
					FROM @tblProyectoFinalizado I
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
							, @POR_RUTA_DE_ARCHIVO AS IDTipoAdjunto
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

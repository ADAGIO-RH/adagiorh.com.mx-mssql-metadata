USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx  
** FechaCreacion	: 2022-02-02  
** Paremetros		:                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor				Comentario  
------------------- ------------------- ------------------------------------------------------------
2025-03-24			Alejandro Paredes	Se agregaron los adjuntos .zip
***************************************************************************************************/

CREATE   PROCEDURE [Comunicacion].[spINotificacionesAvisos]
(
	@dtDestinatarios [Comunicacion].[dtEnviarNotificacionA] READONLY
	, @IDUsuario INT = 0
)
AS
	BEGIN

		DECLARE @IDNotificacion			INT
				, @IDTipoNotificacion	VARCHAR(255)
				, @Subject				VARCHAR(MAX)
				, @TotalEmailValidos	INT
				, @NO_ENVIADO			INT = 0
				, @ADJUNTO_TIPO			INT = 1
				;

		SELECT @TotalEmailValidos = COUNT(*)
		FROM @dtDestinatarios S
		WHERE [Utilerias].[fsValidarEmail](S.Destinatario) = 1

		IF(@TotalEmailValidos > 0)
			BEGIN
				
				SET @IDTipoNotificacion = 'NuevoAviso';
				SET @Subject = 'Avisos';

				INSERT INTO [App].[tblNotificaciones](IDTipoNotificacion, Parametros)
				VALUES(@IDTipoNotificacion, NULL)
        
				SET @IDNotificacion = SCOPE_IDENTITY();

				INSERT INTO [App].[tblEnviarNotificacionA](IDNotifiacion, IDMedioNotificacion, Destinatario, Enviado, Adjuntos, IDTipoAdjunto, Parametros, TipoReferencia, IDReferencia, IDUsuario)
				SELECT @IDNotificacion
						, S.IDMedioNotificacion
						, S.Destinatario
						, @NO_ENVIADO
						, S.Adjuntos
						, @ADJUNTO_TIPO
						, '{"subject":"' + S.[Subject] + '", "body":"' + REPLACE(S.Body, '"', '\"') + '"}'
						, S.TipoReferencia
						, S.IDReferencia
						, U.IDUsuario
				FROM @dtDestinatarios S
					LEFT JOIN [Seguridad].[tblUsuarios] U ON U.IDEmpleado = S.IDEmpleado
				WHERE [Utilerias].[fsValidarEmail](S.Destinatario) = 1

			END
	END
GO

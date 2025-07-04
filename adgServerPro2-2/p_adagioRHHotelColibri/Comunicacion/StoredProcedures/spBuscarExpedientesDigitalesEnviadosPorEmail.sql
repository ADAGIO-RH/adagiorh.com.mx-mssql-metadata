USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca path del zip que contiene los archivos de expediente digital enviados por email
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-03-26
** Parametros		: 
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Comunicacion].[spBuscarExpedientesDigitalesEnviadosPorEmail]
AS
	BEGIN
		
		DECLARE @TipoReferencia VARCHAR(30) = '[App].[tblEnviarNotificacionA]'
				, @SI BIT = 1
				;


		SELECT @TipoReferencia AS TipoReferencia
				, ADJ.IDEnviarNotificacionA AS IDReferencia
				, ADJ.PathZipExpedienteDigital AS PathFile
		FROM
			(
				SELECT EN.IDEnviarNotificacionA								
						, CASE 
							WHEN RIGHT(EN.Adjuntos, LEN(EN.Adjuntos) - CHARINDEX('|', EN.Adjuntos)) LIKE '%AdjuntosExpedienteDigital%' 
								THEN RIGHT(EN.Adjuntos, LEN(EN.Adjuntos) - CHARINDEX('|', EN.Adjuntos))
								ELSE NULL
						  END AS PathZipExpedienteDigital
				FROM [App].[tblEnviarNotificacionA] EN
				WHERE EN.IDMedioNotificacion = 'Email'
						AND EN.Enviado = @SI
						AND EN.TipoReferencia = '[Comunicacion].[tblAvisos]'
						AND EN.Adjuntos IS NOT NULL
			) ADJ
		WHERE ADJ.PathZipExpedienteDigital IS NOT NULL
			AND NOT EXISTS (
							SELECT 1
							FROM [App].[tblHistorialDeCarpetasConUnArchivo] HIS 
							WHERE HIS.TipoReferencia = @TipoReferencia
									AND HIS.IDReferencia = ADJ.IDEnviarNotificacionA
						   )

	END
GO

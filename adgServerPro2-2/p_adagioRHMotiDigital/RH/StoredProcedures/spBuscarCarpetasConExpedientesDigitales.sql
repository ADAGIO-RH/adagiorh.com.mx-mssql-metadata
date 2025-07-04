USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las carpetas de Expediente Digital con sus Expedientes Digitales.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-02-25
** Parametros		: @IDUsuario	Identificador del usuario
** IDAzure			: #1386

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [RH].[spBuscarCarpetasConExpedientesDigitales](	
	@IDUsuario	INT
)
AS
	BEGIN
		
		SELECT 
		(
			SELECT 
				CARPETAS.Descripcion AS [label],
				ISNULL(
					(
						SELECT 
							options.IDExpedienteDigital AS [value],
							options.Descripcion AS [text]
						FROM [RH].[tblCatExpedientesDigitales] options
						WHERE options.IDCarpetaExpedienteDigital = CARPETAS.IDCarpetaExpedienteDigital
						ORDER BY options.IDExpedienteDigital
						FOR JSON AUTO
					),
					'[]'
				) AS options
			FROM [RH].[tblCatCarpetasExpedienteDigital] CARPETAS
			FOR JSON AUTO
		) AS ResultJson;

	END
GO

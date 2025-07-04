USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre los beneficiarios de contratación
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-07-15
** Paremetros		: @dtBeneficiariosContratacion		Lista de beneficiarios de contratación.
					: @IDUsuario						Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spValidarImportacionBeneficiariosContratacion]
( 
	@dtBeneficiariosContratacion [RH].[dtImportacionBeneficiariosContratacion] READONLY
	, @IDUsuario INT
)
AS
	BEGIN		
		
		-- VARIABLES
		DECLARE @IDIdioma VARCHAR(225);

		DECLARE @tempMessages AS TABLE( 
			ID INT
			, [Message] VARCHAR(500)
			, Valid BIT
		)
		
		-- DETECCION DE IDIOMA
		SELECT @IDIdioma = LOWER(REPLACE([APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx'), '-', ''))
		
		
		-- OBTENEMOS MSJ QUE PERTENECEN A LOS BENEFICIARIOS DE CONTRATACION
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionBeneficiariosContratacionMap'
        ORDER BY [IDMensajeTipo];
		

		-- OBTENEMOS EL IDDepartamento DE LA LISTA DE DEPARTAMENTOS		
		SELECT TD.RFC
				, TD.RazonSocial				
				, ISNULL(
					(SELECT B.IDCatBeneficiarioContratacion
						FROM [RH].[tblCatBeneficiariosContratacion] B
						WHERE B.RFC = TD.RFC
					), 0) AS IDCatBeneficiarioContratacion	
		INTO #dtBeneficiariosIDs FROM @dtBeneficiariosContratacion TD

		
		-- REULTADO FINAL
		SELECT INFO.*,
				-- SUB-CONSULTA QUE OBTIENE MENSAJE
				(SELECT '<b>*</b> ' + M.[Message] AS [Message],
						CAST(M.Valid AS BIT) AS Valid
				FROM @tempMessages M
				WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
				-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
				CAST(CASE
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
		FROM (SELECT D.RFC
					, D.RazonSocial									
					, IDMensaje = IIF(ISNULL(D.RFC, '') <> '', '', '1,') +
								  IIF(ISNULL(D.RazonSocial, '') <> '', '', '2,') +
								  IIF(D.IDCatBeneficiarioContratacion = 0, '', '3,') +
								  IIF((SELECT COUNT(*) 
									   FROM #dtBeneficiariosIDs AS SUB 
									   WHERE SUB.RFC = D.RFC) > 1, '4,', '')
			  FROM #dtBeneficiariosIDs D) INFO

	END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre los Puestos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-07-19
** Paremetros		: @dtPuestos		Lista de Puestos
					: @IDUsuario		Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spValidarImportacionPuestos]
( 
	@dtPuestos [RH].[dtImportacionPuestos] READONLY
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
        WHERE [MensajeTipo] = 'ImportacionPuestosMap'
        ORDER BY [IDMensajeTipo];
		

		-- OBTENEMOS EL IDDepartamento DE LA LISTA DE DEPARTAMENTOS		
		SELECT TD.Codigo
				, TD.SueldoBase
				, TD.TopeSalarial
				, TD.CodigoOcupacion
				, TD.Traduccion
				, ISNULL(JSON_VALUE(TD.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS ValorTraduccion
				, ISNULL(
					(SELECT P.IDPuesto
						FROM [RH].[tblCatPuestos] P
						WHERE P.Codigo = TD.Codigo
					), 0) AS IDPuesto	
				, CASE
					WHEN TD.CodigoOcupacion IS NULL OR REPLACE(TD.CodigoOcupacion, ' ', '') = ''
						THEN -1
					ELSE
						ISNULL(
							(SELECT O.IDOcupaciones 
								FROM [STPS].[tblCatOcupaciones] O
								WHERE O.Codigo = TD.CodigoOcupacion
							), 0) 
					END AS IDOcupaciones
		INTO #dtPuestosIDs FROM @dtPuestos TD

						
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
		FROM (SELECT D.Codigo		
					, D.SueldoBase
					, D.TopeSalarial
					, CASE
						WHEN D.IDOcupaciones > 0
							THEN D.IDOcupaciones
							ELSE NULL
						END AS IDOcupaciones
					, D.CodigoOcupacion
					, D.Traduccion					
					, IDMensaje = IIF(ISNULL(D.Codigo, '') <> '', '', '1,') +
								  IIF(ISNULL(D.ValorTraduccion, '') <> '', '', '2,') +
								  IIF(D.IDPuesto = 0, '', '3,') +
								  IIF(D.IDOcupaciones <> 0, '', '4,') + 
								  IIF(D.IDOcupaciones < 0, '5,', '') +
								  IIF((SELECT COUNT(*) 
									   FROM #dtPuestosIDs AS SUB 
									   WHERE SUB.Codigo = D.Codigo) > 1, '6,', '')
			  FROM #dtPuestosIDs D) INFO

	END
GO

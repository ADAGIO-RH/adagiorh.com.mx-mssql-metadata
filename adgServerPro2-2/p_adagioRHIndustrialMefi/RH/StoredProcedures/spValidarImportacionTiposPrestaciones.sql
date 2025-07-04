USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre los Tipos de Prestaciones
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-07-23
** Paremetros		: @dtTiposPrestaciones		Lista de Tipos de Prestaciones
					: @IDUsuario				Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spValidarImportacionTiposPrestaciones]
( 
	@dtTiposPrestaciones [RH].[dtImportacionTiposPrestaciones] READONLY
	, @IDUsuario INT
)
AS
	BEGIN		
		
		-- VARIABLES
		DECLARE @IDIdioma VARCHAR(225)
				, @dtTiposPrestacionesNormalizada [RH].[dtImportacionTiposPrestaciones]				
				;

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
        WHERE [MensajeTipo] = 'ImportacionTiposPrestacionesMap'
        ORDER BY [IDMensajeTipo];


		/*
			NORMALIZAMOS INFORMACION
			Validaciones:
				1.- Se quitan espacios al string "CodigoConceptosFondoAhorro".
				2.- Si viene un codigo repetido en "CodigoConceptosFondoAhorro" se unifican
		*/
		INSERT INTO @dtTiposPrestacionesNormalizada
		SELECT IDTipoPrestacion
				, Codigo
				, Sindical
				, PorcentajeFondoAhorro
				, (
					SELECT CAST(STRING_AGG(item, ',') AS VARCHAR(MAX)) 
					FROM (SELECT DISTINCT item FROM App.Split(REPLACE(CodigoConceptosFondoAhorro, ' ', ''), ',')) AS DistinctItems
				  ) AS CodigoConceptosFondoAhorro				
				, ToparFondoAhorro
				, Traduccion
		FROM @dtTiposPrestaciones
				
		
		/*
			OBTENEMOS PRE-RESULTADO
			Validaciones:
				1.- Obtenemos el IDTipoPrestacion si no existe regresamos '0'.
				2.- Si CodigoConceptosFondoAhorro viene vacio o null regresamos '-1'.
				3.- Obtenemos los IDConcepto por cada CodigoConceptosFondoAhorro y si no existe regresamos '0'.
				4.- Obtenemos los codigos de conceptos de fondo de ahorro inexistentes.
		*/
		SELECT TD.Codigo
				, TD.Sindical
				, TD.PorcentajeFondoAhorro
				, TD.CodigoConceptosFondoAhorro
				, TD.ToparFondoAhorro
				, TD.Traduccion
				, ISNULL(JSON_VALUE(TD.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS ValorTraduccion
				-- VALIDACION 1
				, ISNULL(
					(SELECT TP.IDTipoPrestacion
						FROM [RH].[tblCatTiposPrestaciones] TP
						WHERE TP.Codigo = TD.Codigo
					), 0) AS IDTipoPrestacion	
				, CASE
					-- VALIDACION 2
					WHEN TD.CodigoConceptosFondoAhorro IS NULL OR TD.CodigoConceptosFondoAhorro = ''
						THEN '-1'
					-- VALIDACION 3
					ELSE
						ISNULL(
							(
							SELECT CAST(STRING_AGG(ISNULL(C.IDConcepto,'0'), ',') AS VARCHAR(MAX)) AS CodigoNoExistente
							FROM App.Split(TD.CodigoConceptosFondoAhorro, ',') AS Codes
								LEFT JOIN [Nomina].[tblCatConceptos] C ON Codes.item = C.Codigo
							), 0) 
					END AS IDsConceptosFondoAhorro
				, 
				-- VALIDACION 4
				ISNULL(
					(
					SELECT CAST(STRING_AGG(ISNULL(Codes.item,''), ',') AS VARCHAR(MAX)) AS CodigoNoExistente
					FROM App.Split(TD.CodigoConceptosFondoAhorro, ',') AS Codes
						LEFT JOIN [Nomina].[tblCatConceptos] C ON Codes.item = C.Codigo
					WHERE C.Codigo IS NULL
					), '')  AS CodigoConceptosFondoAhorroInexistentes
		INTO #dtTiposPrestacionesIDs FROM @dtTiposPrestacionesNormalizada TD

		
		-- REULTADO FINAL
		SELECT INFO.*,
				-- SUB-CONSULTA QUE OBTIENE MENSAJE
				(SELECT '<b>*</b> ' + M.[Message] + CASE WHEN M.ID = 4 THEN + ' (' + INFO.CodigoConceptosFondoAhorroInexistentes + ')' ELSE '' END AS [Message],
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
					, D.Sindical
					, D.PorcentajeFondoAhorro					
					, D.CodigoConceptosFondoAhorro
					, D.CodigoConceptosFondoAhorroInexistentes
					, D.ToparFondoAhorro
					, CASE 
						WHEN D.IDsConceptosFondoAhorro = '-1'
							THEN NULL
							ELSE D.IDsConceptosFondoAhorro
						END AS IDsConceptosFondoAhorro
					, D.Traduccion					
					, IDMensaje = IIF(ISNULL(D.Codigo, '') <> '', '', '1,') +
								  IIF(ISNULL(D.ValorTraduccion, '') <> '', '', '2,') +
								  IIF(D.IDTipoPrestacion = 0, '', '3,') +
								  IIF((SELECT TOP 1 CAST(item AS INT) FROM App.Split(D.IDsConceptosFondoAhorro, ',') ORDER BY item ASC) = 0, '4,', '') +
								  IIF(D.PorcentajeFondoAhorro = 0, '5,', '') +
								  IIF(D.PorcentajeFondoAhorro > 0 AND (SELECT TOP 1 CAST(item AS INT) FROM App.Split(D.IDsConceptosFondoAhorro, ',') WHERE item = '-1') < 0, '6,', '') +
								  IIF((SELECT COUNT(*) 
									   FROM #dtTiposPrestacionesIDs AS SUB 
									   WHERE SUB.Codigo = D.Codigo) > 1, '7,', '')
			  FROM #dtTiposPrestacionesIDs D) INFO

	END
GO

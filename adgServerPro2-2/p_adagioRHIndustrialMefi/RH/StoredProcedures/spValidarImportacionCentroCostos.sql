USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre los centros de costo
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-07-08
** Paremetros		: @dtCentrosCosto		Lista de centros de costo.
					: @IDUsuario			Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spValidarImportacionCentroCostos]
( 
	@dtCentroCostos [RH].[dtImportacionCentroCostos] READONLY
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
		
		
		-- OBTENEMOS MSJ QUE PERTENECEN A LOS CENTROS DE COSTO
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionCentrosCostoMap'
        ORDER BY [IDMensajeTipo];
		
		-- OBTENEMOS EL IDCentroCosto DE LA LISTA CENTROS DE COSTO
		SELECT DT.Codigo
				, DT.CuentaContable
				, DT.ConfiguracionEventoCalendario
				, DT.Traduccion
				, ISNULL(JSON_VALUE(DT.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS ValorTraduccion
				, ISNULL(
					(SELECT C.IDCentroCosto
						FROM [RH].[tblCatCentroCosto] C
						WHERE C.Codigo = DT.Codigo
					), 0) AS IDCentroCosto
		INTO #dtCentrosCostoIDs FROM @dtCentroCostos DT	
		
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
		FROM (SELECT C.Codigo
					, C.CuentaContable
					, C.ConfiguracionEventoCalendario
					, C.Traduccion					
					, IDMensaje = IIF(ISNULL(C.Codigo, '') <> '', '', '1,') +
								  IIF(ISNULL(C.ValorTraduccion, '') <> '', '', '2,') +
								  IIF(C.IDCentroCosto = 0, '', '3,') +
								  IIF((SELECT COUNT(*) 
									   FROM #dtCentrosCostoIDs AS SUB 
									   WHERE SUB.Codigo = C.Codigo) > 1, '4,', '')
			  FROM #dtCentrosCostoIDs C) INFO
	END
GO

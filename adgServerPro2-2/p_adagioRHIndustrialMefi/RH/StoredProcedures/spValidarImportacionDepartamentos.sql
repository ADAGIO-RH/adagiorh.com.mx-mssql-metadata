USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre los departamentos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-07-04
** Paremetros		: @dtDepartamentos		Lista de departamentos.
					: @IDUsuario			Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [RH].[spValidarImportacionDepartamentos]
( 
	@dtDepartamentos [RH].[dtImportacionDepartamentos] READONLY
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
		
		
		-- OBTENEMOS MSJ QUE PERTENECEN A LOS DEPARTAMENTOS
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionDepartamentosMap'
        ORDER BY [IDMensajeTipo];
		

		-- OBTENEMOS EL IDDepartamento DE LA LISTA DE DEPARTAMENTOS		
		SELECT TD.Codigo
				, TD.CuentaContable
				, TD.JefeDepartamento				
				, TD.Traduccion
				, ISNULL(JSON_VALUE(TD.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS ValorTraduccion
				, ISNULL(
					(SELECT D.IDDepartamento
						FROM [RH].[tblCatDepartamentos] D
						WHERE D.Codigo = TD.Codigo
					), 0) AS IDDepartamento	
		INTO #dtDepartamentosIDs FROM @dtDepartamentos TD	

		

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
					, D.CuentaContable
					, D.JefeDepartamento
					, D.Traduccion					
					, IDMensaje = IIF(ISNULL(D.Codigo, '') <> '', '', '1,') +
								  IIF(ISNULL(D.ValorTraduccion, '') <> '', '', '2,') +
								  IIF(D.IDDepartamento = 0, '', '3,') +
								  IIF((SELECT COUNT(*) 
									   FROM #dtDepartamentosIDs AS SUB 
									   WHERE SUB.Codigo = D.Codigo) > 1, '4,', '')
			  FROM #dtDepartamentosIDs D) INFO

	END
GO

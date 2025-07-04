USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Importacion masiva sobre las Direcciones Organizacionales
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-31
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spIUImportacionDireccionesOrgMap]
( 
	@dtDirecciones [RH].[dtDireccionesOrganizacionalesImportacion] READONLY,
	@IDUsuario INT 
)
AS
	BEGIN
		
		-- VARIABLES
		DECLARE @IDIdioma VARCHAR(225);

		DECLARE @tempMessages AS TABLE( 
			ID INT,
			[Message] VARCHAR(500),
			Valid BIT
		)
		
		-- DETECCION DE IDIOMA
		SELECT @IDIdioma = LOWER(REPLACE([APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx'), '-', ''))
        
		-- OBTENEMOS MSJ QUE PERTENECEN A LA DIRECCION ORGANIZACIONAL
		INSERT @tempMessages(ID, [Message], Valid)
        SELECT [IDMensajeTipo] ,
               [Mensaje]       ,
               [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionDireccionesOrgMap'
        ORDER BY [IDMensajeTipo];

		SELECT INFO.*,
               -- SUB-CONSULTA QUE OBTIENE MENSAJE
			   (SELECT M.[Message] AS [Message],
                       CAST(M.Valid AS BIT) AS Valid
                FROM @tempMessages M
                WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
               -- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
			   CAST(CASE 
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
		FROM (SELECT D.Codigo,
					 D.Descripcion,
					 D.CuentaContable,
                     IDMensaje = IIF(ISNULL(D.Codigo, '') <> '', '', '1,') +
								 IIF(NOT EXISTS(SELECT TOP 1 1 FROM [RH].[tblCatDireccionesOrganizacionales] WHERE Codigo = D.Codigo ), '', '2,') +
								 IIF(ISNULL(D.Descripcion, '') <> '', '', '3,')
              FROM @dtDirecciones D) INFO
        ORDER BY INFO.Codigo		
	
	END
GO

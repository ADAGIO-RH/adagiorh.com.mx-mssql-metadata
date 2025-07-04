USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre las preguntas de un puesto
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-31
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Evaluacion360].[spValidarImportacionPreguntasPuesto]
( 
	@dtPreguntas [Evaluacion360].[dtImportacionPreguntasPuesto] READONLY
	, @IDUsuario INT 
)
AS
	BEGIN
		
		-- VARIABLES
		DECLARE @IDIdioma VARCHAR(225)
				, @TIPO_EVALUACION_TECNICA INT = 1
				, @ACTIVAR_GRUPO BIT = 1
				;

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
        WHERE [MensajeTipo] = 'ImportacionPreguntaPuestoMap'
        ORDER BY [IDMensajeTipo];

		

		DECLARE @TIPO_REFERENCIA_PUESTO INT = 3
				, @FUNCION_CLAVE INT = 11
				, @IS_REQUERIDA INT = 0
				, @CALIFICAR INT = 1
				, @BOX_9_FALSE INT = 0
				, @CATEGORIA_ESTRATEGICA INT = 2
				, @BOX_9_ES_REQUERIDO_FALSE INT = 0
				, @COMENTARIO_FALSE INT = 0
				, @COMENTARIO_IS_REQUERIDO_FALSE INT = 0
				, @MAXIMA_CALIFICACION_POSIBLE INT = 0	
				, @VITA_NULL INT = NULL
				, @ID_INDICADOR_NULL INT = NULL
				, @VALOR INT = 0
				, @JSON_DATA_NULL VARCHAR = NULL
				, @FECHA DATETIME = GETDATE()
				, @COPIADO_DEL_GRUPO_NULL INT = NULL
				, @ACTIVO INT = 1
				, @PuestoSinEspacios VARCHAR(250)
				, @IDGrupo INT = 0
				, @IDPregunta INT = 0
				;	


		-- OBTENEMOS EL IDPuesto DE LA LISTA DE PREGUNTAS
		;WITH tblPreguntas
		AS 
		(
			SELECT *
				, ISNULL((SELECT PU.IDPuesto
						FROM [RH].[tblCatPuestos] PU 
						WHERE REPLACE(JSON_VALUE(PU.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), ' ', '') = REPLACE(P.Puesto, ' ', '')
				), 0) AS IDPuesto	
			FROM @dtPreguntas P		
		)
		SELECT * 
			   , (SELECT G.IDGrupo
				FROM [Evaluacion360].[tblCatGrupos] G
				WHERE G.TipoReferencia = @TIPO_REFERENCIA_PUESTO
						AND G.IDReferencia = TP.IDPuesto
						AND REPLACE(G.Nombre, ' ', '') = REPLACE(TP.Grupo, ' ', '')
						AND G.IDTipoEvaluacion = TP.IDTipoEvaluacion
						AND G.IDTipoGrupo = TP.IDTipoGrupo
						AND ISNULL(G.CopiadoDeIDGrupo, '') = ''
						) IDGrupo
		INTO #dtPreguntasIDs FROM tblPreguntas TP
		
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
		FROM (SELECT P.Puesto
					, P.Grupo
					, P.Pregunta
					, P.OpcionRespuesta
					, P.Activo
					, P.IDTipoEvaluacion
					, P.IDTipoGrupo
					, P.IDTipoPreguntaGrupo
					, P.IDTipoPregunta 
					, P.IDPuesto
					, ISNULL(P.IDGrupo, 0) AS IDGrupo
					, IDMensaje = IIF(ISNULL(P.IDPuesto, '') <> 0, '', '1,') +
								  IIF(ISNULL(P.Puesto, '') <> '', '', '2,') +
								  IIF(ISNULL(P.Grupo, '') <> '', '', CASE WHEN P.IDTipoGrupo = @TIPO_EVALUACION_TECNICA THEN '4,' ELSE '3,' END) +
								  IIF(ISNULL(P.Pregunta, '') <> '', '', '5,') + 
								  IIF(NOT EXISTS(
										SELECT TOP 1 1 FROM [Evaluacion360].[tblCatPreguntas] CP
										WHERE CP.IDGrupo = ISNULL(P.IDGrupo, 0)
											  AND REPLACE(CP.Descripcion, ' ', '') = REPLACE(P.Pregunta, ' ', '')
											  AND CP.IDTipoPregunta = P.IDTipoPregunta 
									  ),
									  '',  -- LA PREGUNTA NO EXISTE
									  '6,' -- LA PREGUNTA EXISTE
									) +
								  IIF(ISNULL(P.IDGrupo, 0) = 0, '', CASE 
																			WHEN (SELECT ISNULL(G.Activo, 0) FROM [Evaluacion360].[tblCatGrupos] G WHERE G.IDGrupo = ISNULL(P.IDGrupo, 0)) <> P.Activo 
																				THEN CASE WHEN P.Activo = @ACTIVAR_GRUPO THEN '7,' ELSE '8,' END 
																				ELSE '' 
																			END)
			  FROM #dtPreguntasIDs P) INFO

	END
GO

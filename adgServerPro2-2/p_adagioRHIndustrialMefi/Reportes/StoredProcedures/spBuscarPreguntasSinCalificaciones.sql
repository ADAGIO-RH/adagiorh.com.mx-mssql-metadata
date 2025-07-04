USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar preguntas y respuestas sin calificacion numerica
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 
** Paremetros		: @IDEmpleadoProyecto			- Identificador del empleado proyecto	  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-04-06			Alejandro Paredes	Se agrego la columna contestada por
***************************************************************************************************/

CREATE proc [Reportes].[spBuscarPreguntasSinCalificaciones] (
	@IDEmpleadoProyecto INT
) AS
	
	DECLARE 
		@dtUsuarios [Seguridad].[dtUsuarios]
		, @Resultado VARCHAR(250)
		, @Privacidad BIT = 0
		, @PrivacidadDescripcion VARCHAR(25)
		, @ACTIVO BIT = 1
		, @IDIdioma VARCHAR(max)
	;

    select @IDIdioma=App.fnGetPreferencia('Idioma',1,'esmx')

	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDEmpleadoProyecto = @IDEmpleadoProyecto
		, @EsRptBasico = 1
		, @Resultado = @Resultado OUTPUT
		, @Descripcion = @PrivacidadDescripcion OUTPUT
		;

	IF(@Resultado <> '0' AND @Resultado <> '1')
	BEGIN					
		RAISERROR(@Resultado, 16, 1); 
		RETURN
	END
	ELSE
	BEGIN
		SET @Privacidad = @Resultado;
	END
	-- TERMINA VALIDACION

	INSERT @dtUsuarios
	EXEC [Seguridad].[spBuscarUsuarios]

	SELECT CG.Nombre,
		   EE.IDTipoRelacion,
		   JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion,
		   P.Descripcion AS Pregunta,
		   Respuesta = CASE 
						WHEN P.IDTipoPregunta = 2 THEN (SELECT STUFF((SELECT ',' + OpcionRespuesta
																		   FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] 
																		   WHERE IDPregunta = P.IDPregunta AND IDPosibleRespuesta IN (SELECT value FROM STRING_SPLIT(RP.Respuesta, ','))
																		   FOR XML PATH('')), 1, 1, ''))
						WHEN P.IDTipoPregunta = 5 THEN PRP.OpcionRespuesta
						WHEN P.IDTipoPregunta = 3 THEN COALESCE(RP.Respuesta, '0') + ' de '+ COALESCE(PRP3.OpcionRespuesta, '0') + ' estrellas'
						WHEN P.IDTipoPregunta = 6 THEN COALESCE(RP.Respuesta, '0') + ' de 100'

						WHEN P.IDTipoPregunta = 10 THEN (SELECT STUFF((SELECT ',' + OpcionRespuesta
																		FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] PO
																		WHERE PO.IDPregunta = P.IDPregunta AND PO.IDPosibleRespuesta 
																			IN (
																				SELECT value 
																				FROM STRING_SPLIT((SELECT STUFF((SELECT ',' + CONVERT(VARCHAR(50), IDPosibleRespuesta)
																												 FROM OPENJSON(RP.Respuesta)
																												 WITH (
																													IDPosibleRespuesta int '$.IDPosibleRespuesta',
																													Orden int '$.Orden'
																												 )
																												 FOR XML PATH('')), 1, 1, '')), ',')
																			)
																			ORDER BY
																			(
																				SELECT Orden FROM OPENJSON(RP.Respuesta)
																				WITH (
																					  IDPosibleRespuesta int '$.IDPosibleRespuesta',
																					  Orden int '$.Orden'
																					 )
																				WHERE IDPosibleRespuesta = PO.IDPosibleRespuesta
																			) DESC
																		FOR XML PATH('')), 1, 1, ''))
						ELSE RP.Respuesta 
					   END,
		   --ContestadaPor = COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, '')
		   ContestadaPor = CASE 
							WHEN @Privacidad = @ACTIVO
								THEN @PrivacidadDescripcion
								ELSE COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, '')
							END	
	FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE
		JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON TP.IDTipoRelacion = EE.IDTipoRelacion
		JOIN [Evaluacion360].[tblCatGrupos] CG ON CG.IDReferencia = EE.IDEvaluacionEmpleado AND CG.TipoReferencia = 4
		JOIN [Evaluacion360].[tblCatPreguntas] P ON P.IDGrupo = CG.IDGrupo
		JOIN [Evaluacion360].[tblRespuestasPreguntas] RP ON RP.IDPregunta = P.IDPregunta
		LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP ON PRP.IDPregunta = P.IDPregunta AND PRP.IDPosibleRespuesta = CASE WHEN P.IDTipoPregunta IN (/*2,*/3,5) THEN RP.Respuesta ELSE 0 END
		LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP3 ON PRP3.IDPregunta = P.IDPregunta AND P.IDTipoPregunta = 3
		JOIN @dtUsuarios U ON EE.IDEvaluador = U.IDEmpleado
	WHERE EE.IDEmpleadoProyecto = @IDEmpleadoProyecto AND
		  ISNULL(P.Calificar, 0) = 0 AND
		  P.IDTipoPregunta NOT IN (1,8,9)
	ORDER BY P.Descripcion
GO

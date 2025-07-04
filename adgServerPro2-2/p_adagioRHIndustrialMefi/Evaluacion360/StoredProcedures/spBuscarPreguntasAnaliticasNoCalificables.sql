USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las preguntas no calificables del proyecto.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-06-19
** Paremetros		: @IDProyecto		Identificador del proyecto

	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2023-08-19			ANEUDY ABREU	Agrega validación para los proyectos de Clima laboral para mantener
									anónimo el evaluador.
***************************************************************************************************/
CREATE PROC [Evaluacion360].[spBuscarPreguntasAnaliticasNoCalificables](
	@IDProyecto INT
	,@IDUsuario INT
) AS

	DECLARE  
		@TipoPrueba INT = 1
		,@Calificar INT = 0			
		,@PreguntaVerificacion INT = 2
		,@PreguntaEstrella INT = 3
		,@PreguntaDesplegable INT = 5
		,@PreguntaDeslizante INT = 6
		,@PreguntaRancking INT = 10					
		,@Privacidad BIT = 0
		,@IDTipoProyecto INT = 0		
		,@PrivacidadDescripcion VARCHAR(25)			
		,@ACTIVO BIT = 1
		,@Resultado VARCHAR(250)
			
		,@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3
        ,@IDIdioma VARCHAR (max)
	;	
    
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	DECLARE @TblGrupo TABLE(
		IDProyecto INT,
		IDGrupo INT,
		Evaluador VARCHAR(150),
		Relacion VARCHAR(150)
	)


	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDProyecto = @IDProyecto
		, @Descripcion = @PrivacidadDescripcion OUTPUT
		, @Resultado = @Resultado OUTPUT;

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
	


	INSERT INTO @TblGrupo(IDProyecto, IDGrupo, Evaluador, Relacion)
	SELECT P.IDProyecto,
		   G.IDGrupo,
		   case when p.IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL then 'ANÓMINO' else EV.NOMBRECOMPLETO end AS Evaluador,
		  JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	FROM [Evaluacion360].[tblCatProyectos] P
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto		
		LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto	
		LEFT JOIN RH.tblEmpleadosMaster EV ON EE.IDEvaluador = EV.IDEmpleado
		LEFT JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia	
		JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON TP.IDTipoRelacion = EE.IDTipoRelacion
	WHERE P.IDProyecto = @IDProyecto
	ORDER BY G.IDGrupo


	SELECT 
		--G.*,
		--P.IDPregunta,
		--P.IDTipoPregunta,
		G.Relacion,
		P.Descripcion,
		--R.Respuesta,		   	   
		CASE 
		WHEN (P.IDTipoPregunta = @PreguntaVerificacion)
			THEN
				(
					(SELECT STUFF((SELECT ',' + OpcionRespuesta
									FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] 
									WHERE IDPregunta = P.IDPregunta AND IDPosibleRespuesta IN (SELECT value FROM STRING_SPLIT(R.Respuesta, ','))
						FOR XML PATH('')), 1, 1, ''))
				)
		WHEN (P.IDTipoPregunta = @PreguntaDesplegable)	THEN PRP.OpcionRespuesta
		WHEN (P.IDTipoPregunta = @PreguntaEstrella)		THEN COALESCE(R.Respuesta, '0') + ' de '+ COALESCE(PRP3.OpcionRespuesta, '0') + ' estrellas'
		WHEN (P.IDTipoPregunta = @PreguntaDeslizante)	THEN COALESCE(R.Respuesta, '0') + ' de 100'
		WHEN (P.IDTipoPregunta = @PreguntaRancking)
			THEN 
				(
					(SELECT STUFF((SELECT ',' + OpcionRespuesta
									FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] PO
									WHERE PO.IDPregunta = P.IDPregunta AND PO.IDPosibleRespuesta 
									IN (
										SELECT value 
										FROM STRING_SPLIT((SELECT STUFF((SELECT ',' + CONVERT(VARCHAR(50), IDPosibleRespuesta)
																			FROM OPENJSON(R.Respuesta)
																			WITH (
																			IDPosibleRespuesta int '$.IDPosibleRespuesta'																				
																			)
																	FOR XML PATH('')), 1, 1, '')), ',')
										)
									ORDER BY
									(
										SELECT Orden FROM OPENJSON(R.Respuesta)
										WITH (
												IDPosibleRespuesta int '$.IDPosibleRespuesta',
												Orden int '$.Orden'
												)
										WHERE IDPosibleRespuesta = PO.IDPosibleRespuesta
									) DESC
									FOR XML PATH('')), 1, 1, ''))
				)
		ELSE R.Respuesta 
		END AS Respuesta,
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE G.Evaluador
			END AS ContestadaPor
	FROM @TblGrupo G
		LEFT JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
		LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] R ON P.IDPregunta = R.IDPregunta
		LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP ON PRP.IDPregunta = P.IDPregunta AND PRP.IDPosibleRespuesta = CASE WHEN P.IDTipoPregunta IN (@PreguntaEstrella,@PreguntaDesplegable) THEN R.Respuesta ELSE 0 END
		LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP3 ON PRP3.IDPregunta = P.IDPregunta AND P.IDTipoPregunta = @PreguntaEstrella
	WHERE ISNULL(R.Respuesta, 'SinContestar') <> 'SinContestar'
			AND P.Calificar = @Calificar
	ORDER BY R.IDPregunta
GO

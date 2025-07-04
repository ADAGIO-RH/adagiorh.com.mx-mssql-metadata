USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca todas las respuestas sin calificacion numerica de una pregunta especifica
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-11-17
** Paremetros		: @IDProyecto	- Identificador del proyecto  
					  @Descripcion	- Descripcion de la pregunta
					  @JsonFiltros	- Filtros solicitados
					  @IDUsuario	- Identificador del usuario
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spRespuestasSinCalificacion] (
	@IDProyecto			INT = 0	
	, @Descripcion		VARCHAR(MAX) = ''	
	, @JsonFiltros		NVARCHAR(MAX) = ''
	, @IDUsuario		INT = 0
	, @PageNumber		INT = 1
	, @PageSize			INT = 2147483647
	, @query			VARCHAR(100) = '""'
	, @orderByColumn	VARCHAR(50) = 'ContestadaPor'
	, @orderDirection	VARCHAR(4) = 'ASC'
) AS
	
	SET FMTONLY OFF; 

	/*--------- PAGINACIÓN ---------*/
	DECLARE @TotalPaginas	INT = 0,
			@TotalRegistros INT;

	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SET @query = CASE
					WHEN @query IS NULL THEN '""'
					WHEN @query = '' THEN '""'
					WHEN @query = '""' THEN @query
				 ELSE '"' + @query + '*"' END

	SELECT	@orderByColumn = CASE WHEN @orderByColumn IS NULL THEN 'ContestadaPor' ELSE @orderByColumn END,
			@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END
	/*--------- PAGINACIÓN ---------*/
	


	DECLARE @dtUsuarios					[Seguridad].[dtUsuarios]
			, @dtFiltros				[Nomina].[dtFiltrosRH]
			, @dtEmpleados				[RH].[dtEmpleados]
			, @Resultado				VARCHAR(250)
			, @Privacidad				BIT = 0
			, @PrivacidadDescripcion	VARCHAR(25)
			, @ACTIVO					BIT = 1			
			, @OPCION_MULTIPLE			INT = 1
			, @CASILLAS_DE_VERIFICACION INT = 2
			, @VALORACION_CON_ESTRELLAS INT = 3
			, @CUADRO_DE_TEXTO_SIMPLE	INT = 4
			, @MENU_DESPLEGABLE			INT = 5
			, @CONTROL_DESLIZANTE		INT = 6
			, @FECHA_HORA				INT = 7
			, @ESCALA_PROYECTO			INT = 8
			, @ESCALA_INDIVIDUAL		INT = 9 
			, @RANKING					INT = 10
			, @FUNCION_CLAVE			INT = 11
			, @SI						INT = 1
			, @NO						INT = 0			
			, @TieneFiltro				BIT = 0			
			, @FechaEvaluacion			DATETIME = 0			
			;

	DECLARE @RespuestasAll TABLE
	(
		Grupo			VARCHAR(250),
		Pregunta		VARCHAR(MAX),
		Respuesta		VARCHAR(MAX),
		IDEvaluador		INT,
		ContestadaPor	VARCHAR(250)
	)

	DECLARE @Respuestas TABLE
	(
		Grupo			VARCHAR(250),
		Pregunta		VARCHAR(MAX),
		Respuesta		VARCHAR(MAX),
		IDEvaluador		INT,
		ContestadaPor	VARCHAR(250)		
	)


	-- CONVERTIMOS FILTROS A TABLA
	INSERT @dtFiltros(Catalogo, [Value])
	SELECT catalogo
			, REPLACE(valor, ' ', '') AS valor
	FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$'))
		WITH (
		catalogo NVARCHAR(MAX) '$.Catalogo',
		valor NVARCHAR(MAX) '$.Value'
		);
	--SELECT * FROM @dtFiltros

	
	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDProyecto = @IDProyecto
		, @EsRptBasico = @SI
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

	-- OBTENEMOS RESPUESTAS DE PREGUNTA
	INSERT INTO @RespuestasAll(Grupo, Pregunta, Respuesta, IDEvaluador, ContestadaPor)
	SELECT CG.Nombre AS Grupo,
		   --EE.IDTipoRelacion,
		   --TP.Relacion,
		   P.Descripcion AS Pregunta,
		   Respuesta = CASE 
						WHEN P.IDTipoPregunta = @CASILLAS_DE_VERIFICACION THEN (SELECT STUFF((SELECT ',' + OpcionRespuesta
																							  FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] 
																							  WHERE IDPregunta = P.IDPregunta AND IDPosibleRespuesta IN (SELECT value FROM STRING_SPLIT(RP.Respuesta, ','))
																							  FOR XML PATH('')), 1, 1, ''))
						WHEN P.IDTipoPregunta = @MENU_DESPLEGABLE THEN PRP.OpcionRespuesta
						WHEN P.IDTipoPregunta = @VALORACION_CON_ESTRELLAS THEN COALESCE(RP.Respuesta, '0') + ' de '+ COALESCE(PRP3.OpcionRespuesta, '0') + ' estrellas'
						WHEN P.IDTipoPregunta = @CONTROL_DESLIZANTE THEN COALESCE(RP.Respuesta, '0') + ' de 100'

						WHEN P.IDTipoPregunta = @RANKING THEN (SELECT STUFF((SELECT ',' + OpcionRespuesta
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
		   EE.IDEvaluador,
		   ContestadaPor = CASE 
							WHEN @Privacidad = @ACTIVO
								THEN @PrivacidadDescripcion
								ELSE COALESCE(U.Nombre, '') + ' ' + COALESCE(U.Apellido, '')
							END		
	FROM [Evaluacion360].[tblCatProyectos] PR
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON PR.IDProyecto = EP.IDProyecto
		LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatTiposRelaciones] TP ON TP.IDTipoRelacion = EE.IDTipoRelacion
		JOIN [Evaluacion360].[tblCatGrupos] CG ON CG.IDReferencia = EE.IDEvaluacionEmpleado AND CG.TipoReferencia = 4
		JOIN [Evaluacion360].[tblCatPreguntas] P ON P.IDGrupo = CG.IDGrupo
		JOIN [Evaluacion360].[tblRespuestasPreguntas] RP ON RP.IDPregunta = P.IDPregunta
		LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP ON PRP.IDPregunta = P.IDPregunta AND PRP.IDPosibleRespuesta = CASE WHEN P.IDTipoPregunta IN (@VALORACION_CON_ESTRELLAS, @MENU_DESPLEGABLE) THEN RP.Respuesta ELSE 0 END
		LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP3 ON PRP3.IDPregunta = P.IDPregunta AND P.IDTipoPregunta = @VALORACION_CON_ESTRELLAS
		JOIN @dtUsuarios U ON EE.IDEvaluador = U.IDEmpleado
	WHERE PR.IDProyecto = @IDProyecto 
			AND P.Descripcion = @Descripcion
			AND ISNULL(P.Calificar, 0) = @NO
			AND P.IDTipoPregunta NOT IN (@OPCION_MULTIPLE, @ESCALA_PROYECTO, @ESCALA_INDIVIDUAL)
	ORDER BY P.Descripcion


	
	-- FILTRAMOS SI ES NECESARIO
	SELECT @TieneFiltro = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END FROM @dtFiltros WHERE Catalogo <> 'Conjuncion';
	IF(@TieneFiltro = @SI)
		BEGIN
			-- EMPLEADOS FILTRO
			SELECT @FechaEvaluacion = FechaCreacion FROM Evaluacion360.tblCatProyectos WHERE IDProyecto = @IDProyecto;
			INSERT @dtEmpleados
			EXEC [RH].[spBuscarEmpleados]
				@FechaIni	 = @FechaEvaluacion
				, @Fechafin  = @FechaEvaluacion
				, @IDUsuario = @IDUsuario
				, @dtFiltros = @dtFiltros

			-- EMPLEADOS FILTRO PRUEBAS
			--INSERT @dtEmpleados
			--SELECT * FROM [RH].[tblEmpleadosMaster]

			-- PREGUNTAS FILTRADAS
			INSERT INTO @Respuestas(Grupo, Pregunta, Respuesta, IDEvaluador, ContestadaPor)
			SELECT R.*
			FROM @RespuestasAll R
				INNER JOIN @dtEmpleados E ON E.IDEmpleado = R.IDEvaluador
		END
	ELSE
		BEGIN
			INSERT INTO @Respuestas(Grupo, Pregunta, Respuesta, IDEvaluador, ContestadaPor)
			SELECT * FROM @RespuestasAll
		END
	--SELECT * FROM @Respuestas

					
	-- RESULTADO PAGINADO
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @Respuestas

	SELECT @TotalRegistros = CAST(COUNT([Pregunta]) AS DECIMAL(18,2)) FROM @Respuestas

	SELECT Pregunta
			, Respuesta
			, ContestadaPor
			, TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
			, CAST(@TotalRegistros AS INT) AS TotalRows
	FROM @Respuestas
	ORDER BY
		CASE WHEN @orderByColumn = 'Pregunta'	and @orderDirection = 'asc'	THEN Pregunta END,
		CASE WHEN @orderByColumn = 'Pregunta'	and @orderDirection = 'desc' THEN Pregunta END DESC,
		CASE WHEN @orderByColumn = 'ContestadaPor'	and @orderDirection = 'asc'	THEN ContestadaPor END,
		CASE WHEN @orderByColumn = 'ContestadaPor'	and @orderDirection = 'desc' THEN ContestadaPor END DESC,
		ContestadaPor DESC
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

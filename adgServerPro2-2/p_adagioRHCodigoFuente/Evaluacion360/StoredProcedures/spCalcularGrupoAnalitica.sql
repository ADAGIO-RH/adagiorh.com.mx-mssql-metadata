USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el calculo de las preguntas de un grupo
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-11-03
** Paremetros		: @IDProyecto		Identificador del proyecto
**					: @Descripcion		Nombre del grupo
**					: @TipoCalculo		Manera de calcular el resultado (false: Promedio / true: Porcentaje)
**					: @JsonFiltros		Filtros solicitados
**					: @IDUsuario		Identificador del usuario
** IDIssue			: 558

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spCalcularGrupoAnalitica](
	@IDProyecto		INT = 0
	, @Descripcion	VARCHAR(MAX) = ''
	, @TipoCalculo	BIT = 0	
	, @JsonFiltros	NVARCHAR(MAX) = ''
	, @IDUsuario	INT = 0
)
AS
	BEGIN
		
		DECLARE 
			@MIXTA INT = 1
			, @ESCALA_DE_LA_PRUEBA INT = 2
			, @ESCALA_INDIVIDUAL INT = 3
			, @FUNCION_CLAVE INT = 5			
			, @PRUEBA_FINAL INT = 4
			, @IDTipoPreguntaGrupo INT = 0
			, @IDGrupo INT = 0
			, @MaximoValor DECIMAL(18, 2)
			, @dtFiltros		[Nomina].[dtFiltrosRH]
			;

		DECLARE @tblPreguntas TABLE
		(
			IDGrupo INT,
			Grupo VARCHAR(MAX), 
			IDTipoPreguntaGrupo INT,
			IDPregunta INT,
			IDTipoPregunta INT,			
			Pregunta VARCHAR(MAX),
			Calificar INT,
			Respuesta NVARCHAR(MAX),
			ValorFinal DECIMAL(18,2),
			Payload VARCHAR(MAX)
		)

		DECLARE @tblResultado TABLE
		(	
			Escala VARCHAR(MAX),
			Porcentaje DECIMAL(18,2),
			Promedio DECIMAL(18,2)
		)

		
		-- CONVERTIMOS FILTROS A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT catalogo
				, REPLACE(valor, ' ', '') AS valor
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(MAX) '$.catalogo',
			valor NVARCHAR(MAX) '$.valor'
		  );
		--SELECT * FROM @dtFiltros

		
		-- OBTENEMOS LOS GRUPOS SOLICITADOS (SON LOS GRUPOS DE LA EVALUACION CON EL MISMO NOMBRE)
		;WITH tblGrupos(IDGrupo, Nombre, IDTipoPreguntaGrupo)
		AS
			(
				SELECT G.IDGrupo
						, G.Nombre
						, G.IDTipoPreguntaGrupo
				FROM [Evaluacion360].[tblCatProyectos] P
					LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
					LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
					JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
				WHERE P.IDProyecto = @IDProyecto 
						AND G.Nombre = @Descripcion
						AND G.TipoReferencia = @PRUEBA_FINAL 
			)	
		-- OBTENEMOS LAS PREGUNTAS DE LOS GRUPOS
		INSERT INTO @tblPreguntas(IDGrupo, Grupo, IDTipoPreguntaGrupo, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta, ValorFinal, Payload)
		SELECT G.IDGrupo
				, G.Nombre
				, G.IDTipoPreguntaGrupo
				, P.IDPregunta
				, P.IDTipoPregunta				
				, P.Descripcion
				, P.Calificar
				, PR.Respuesta
				, PR.ValorFinal
				, PR.Payload
		FROM tblGrupos G	
			JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
			JOIN [Evaluacion360].[tblRespuestasPreguntas] PR ON P.IDPregunta = PR.IDPregunta
		WHERE G.IDGrupo = P.IDGrupo	


		--INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3, '3.00', NULL)

		
		SELECT TOP 1 @IDTipoPreguntaGrupo = IDTipoPreguntaGrupo FROM @tblPreguntas;
		
		IF(@IDTipoPreguntaGrupo = @ESCALA_DE_LA_PRUEBA OR @IDTipoPreguntaGrupo = @FUNCION_CLAVE)
			BEGIN
				
				--SELECT * FROM [Evaluacion360].[tblEscalasValoracionesProyectos] WHERE IDProyecto = @IDProyecto;

				SELECT @MaximoValor = MAX(Valor) FROM [Evaluacion360].[tblEscalasValoracionesProyectos] WHERE IDProyecto = @IDProyecto;

				--SELECT @MaximoValor AS MaximoValor

				;WITH tblPreguntas(Pregunta, Escala, Respuesta, NoPreguntas, MaximoValor)
				AS
					(
						SELECT P.Pregunta, ES.Escala, ES.Respuesta, COUNT(P.Pregunta), COUNT(P.Pregunta) * @MaximoValor
						FROM @tblPreguntas P						
						CROSS APPLY (
							SELECT E.Nombre AS Escala
									, E.Valor AS Respuesta
							FROM [Evaluacion360].[tblEscalasValoracionesProyectos] E
							WHERE E.IDProyecto = @IDProyecto
						) ES
						WHERE P.Calificar = 1
						GROUP BY P.Pregunta, ES.Escala, ES.Respuesta
						--ORDER BY P.Pregunta, V.Valor
					)
				INSERT INTO @tblResultado(Escala, Porcentaje, Promedio)
				SELECT --WP.*
						--, ISNULL(SUM(P.ValorFinal), 0) AS SumaValorFinal
						WP.Escala
						, CAST((ISNULL(SUM(P.ValorFinal), 0) / WP.MaximoValor) AS DECIMAL(18,2)) * 100 AS Porcentaje
						, CAST((ISNULL(SUM(P.ValorFinal), 0) / WP.NoPreguntas) AS DECIMAL(18,2)) AS Promedio
				FROM tblPreguntas WP
					LEFT JOIN @tblPreguntas P ON P.Pregunta = WP.Pregunta AND P.Respuesta = WP.Respuesta
				GROUP BY WP.Pregunta, WP.Escala, WP.Respuesta, WP.NoPreguntas, WP.MaximoValor
				ORDER BY WP.Pregunta, WP.Respuesta

				SELECT Escala
						, (SELECT SUM(Porcentaje) FROM @tblResultado) AS SumaTotal
						, CAST(SUM(Porcentaje) / (SELECT SUM(Porcentaje) FROM @tblResultado) * 100 AS DECIMAL(18,2)) AS Porcentaje
						, CAST(AVG(Porcentaje) AS DECIMAL(18,2)) AS Promedio
				FROM @tblResultado
				GROUP BY Escala


				--SELECT --P.Pregunta
				--		 E.Nombre
				--	   --, SUM(CAST(P.Respuesta AS DECIMAL(18, 2))) AS Respuesta
				--	   --, COUNT(P.Pregunta) AS NoPreguntas
				--	   --, COUNT(P.Pregunta) *  @MaximoValor AS MaximoValor
				--FROM [Evaluacion360].[tblEscalasValoracionesProyectos] E
				--	LEFT JOIN @tblPreguntas P ON P.Respuesta = E.Valor
				--WHERE E.IDProyecto =  @IDProyecto
				----		AND P.Calificar = 1
				----GROUP BY P.Pregunta, E.Nombre
				----ORDER BY P.Pregunta

			END

		IF(@IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL)
			BEGIN
				SELECT TOP 1 @IDGrupo = IDGrupo FROM @tblPreguntas;
				SELECT Nombre, Valor FROM [Evaluacion360].[tblEscalasValoracionesGrupos] WHERE IDGrupo = @IDGrupo;				
			END
		
		IF(@IDTipoPreguntaGrupo = @MIXTA)
			BEGIN				
				SELECT * FROM Evaluacion360.tblPosiblesRespuestasPreguntas WHERE IDPregunta IN (10190, 10207)
				SELECT * FROM Evaluacion360.tblRespuestasPreguntas WHERE IDPregunta IN (10190, 10207)
			END

			
			--SELECT *
			--	FROM @tblPreguntas
			--	WHERE Calificar = 1
			--order by Pregunta, Respuesta
		
	END
GO

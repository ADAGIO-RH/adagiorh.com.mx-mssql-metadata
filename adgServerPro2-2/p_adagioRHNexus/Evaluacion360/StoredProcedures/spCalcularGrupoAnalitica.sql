USE [p_adagioRHNexus]
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
			, @Calificable INT = 1
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

		DECLARE @tblRespuestasEnEscala TABLE
		(				
			Escala VARCHAR(MAX),
			Valor INT,
			NoRespuestas INT,
			ValorFinal DECIMAL(18,2)
		)
		
		DECLARE @tblResultado TABLE
		(				
			RespuestaEscala INT,
			Escala VARCHAR(MAX),
			ValorFinal DECIMAL(18,2),
			TotalRespuestas INT,
			NoRespuestas INT,
			Promedio DECIMAL(18,2),
			Porcentaje DECIMAL(18,2)
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
		WHERE G.IDGrupo = P.IDGrupo	AND
			  P.Calificar = @Calificable


		-- DATOS PARA PRUEBAS
		/*

			DELETE @tblPreguntas
			
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 4, '4.00', NULL)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3, '3.00', NULL)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3, '3.00', NULL)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3, '3.00', NULL)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 2, '2.00', NULL)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 1, '1.00', NULL)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 0, '0.00', NULL)

			SELECT * FROM @tblPreguntas ORDER BY Respuesta DESC
		*/
		SELECT * FROM @tblPreguntas ORDER BY Respuesta DESC
		
		
		SELECT TOP 1 @IDTipoPreguntaGrupo = IDTipoPreguntaGrupo FROM @tblPreguntas;
		
		IF(@IDTipoPreguntaGrupo = @ESCALA_DE_LA_PRUEBA OR @IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL OR @IDTipoPreguntaGrupo = @FUNCION_CLAVE)
			BEGIN		
				
				-- OBTENEMOS ESCALA DEL GRUPO
				IF(@IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL)
					BEGIN
						SELECT TOP 1 @IDGrupo = IDGrupo FROM @tblPreguntas;
						INSERT INTO @tblRespuestasEnEscala(Escala, Valor, NoRespuestas, ValorFinal)
						SELECT E.Nombre
								, E.Valor
								, COUNT(P.Respuesta) AS NoRespuestas
								, CASE
									WHEN P.ValorFinal > 0
										THEN P.ValorFinal
										ELSE 1
									END AS ValorFinal
						FROM [Evaluacion360].[tblEscalasValoracionesGrupos] E
							LEFT JOIN @tblPreguntas P ON E.Valor = P.Respuesta
						WHERE E.IDGrupo = @IDGrupo
						GROUP BY E.Nombre, E.Valor, P.ValorFinal
						ORDER BY E.Valor DESC
					END
				ELSE
					BEGIN
						INSERT INTO @tblRespuestasEnEscala(Escala, Valor, NoRespuestas, ValorFinal)
						SELECT E.Nombre
								, E.Valor
								, COUNT(P.Respuesta) AS NoRespuestas
								, CASE
									WHEN P.ValorFinal > 0
										THEN P.ValorFinal
										ELSE 1
									END AS ValorFinal
						FROM [Evaluacion360].[tblEscalasValoracionesProyectos] E
							LEFT JOIN @tblPreguntas P ON E.Valor = P.Respuesta
						WHERE E.IDProyecto = @IDProyecto
						GROUP BY E.Nombre, E.Valor, P.ValorFinal
						ORDER BY E.Valor DESC
					END


				-- RESULTADO FINAL
				;WITH tblPreResultado(RespuestaEscala, Escala, ValorFinal, TotalRespuestas, NoRespuestas)
				AS
					(
						SELECT RE.Valor
								, RE.Escala
								, RE.ValorFinal
								, SUM(NoRespuestas) OVER () AS TotalRespuestas
								, NoRespuestas
						FROM @tblRespuestasEnEscala RE
						--ORDER BY RE.Valor DESC
					)
				INSERT INTO @tblResultado(RespuestaEscala, Escala, ValorFinal, TotalRespuestas, NoRespuestas, Promedio, Porcentaje)
				SELECT RespuestaEscala
						, Escala
						, ValorFinal
						, TotalRespuestas
						, NoRespuestas
						, CASE
							WHEN NoRespuestas > 0
								THEN CAST(ValorFinal / CAST(SUM(NoRespuestas) AS DECIMAL(18,2)) AS DECIMAL(18,2)) 
								ELSE 0
							END AS Promedio

						, CASE
							WHEN NoRespuestas > 0
								THEN CAST(NoRespuestas / CAST(TotalRespuestas AS DECIMAL(18,2)) AS DECIMAL(18,2)) * 100
								ELSE 0
							END AS Porcentaje
				FROM tblPreResultado				
				GROUP BY RespuestaEscala, Escala, ValorFinal, TotalRespuestas, NoRespuestas
				ORDER BY RespuestaEscala DESC			

			END
		
		
		IF(@IDTipoPreguntaGrupo = @MIXTA)
			BEGIN				
				SELECT * FROM Evaluacion360.tblPosiblesRespuestasPreguntas WHERE IDPregunta IN (10190, 10207)
				SELECT * FROM Evaluacion360.tblRespuestasPreguntas WHERE IDPregunta IN (10190, 10207)
			END

		


		SELECT * 
		FROM @tblResultado
		ORDER BY RespuestaEscala DESC

		
	END
GO

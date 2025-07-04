USE [p_adagioRHIndustrialMefi]
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
**					: @JsonFiltros		Filtros solicitados
**					: @EsGrupo			Bandera que indica si estamos calculando un grupo o una pregunta
**					: @IDUsuario		Identificador del usuario
** IDIssue			: 558

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-01-24			Alejandro Paredes	Se cambio el porcentaje en base al numero de respuestas (Nota: estaba en base al valor de la escala por el numero de respuestas)
***************************************************************************************************/

CREATE       PROC [Evaluacion360].[spCalcularGrupoPreguntaAnalitica](
	@IDProyecto			INT = 0	
	, @Descripcion		VARCHAR(MAX) = ''	
	, @JsonFiltros		NVARCHAR(MAX) = ''
	, @EsGrupo			BIT = 0
	, @PorPorcentaje	BIT
	, @IDUsuario		INT = 0
)
AS
	BEGIN
		
		DECLARE 
			@MIXTA					INT = 1
			, @ESCALA_DE_LA_PRUEBA	INT = 2
			, @ESCALA_INDIVIDUAL	INT = 3
			, @FUNCION_CLAVE		INT = 5
			, @VERIFICACION			INT = 2
			, @IDTipoPreguntaGrupo	INT = 0
			, @IDGrupo				INT = 0
			, @IDEscalaEstatico		INT = 1
			, @FechaEvaluacion		DATETIME = 0
			, @TieneFiltro			BIT = 0
			, @SI					INT = 1
			, @CopiadoDeIDGrupo		INT = 0
			, @CopiadoDeIDPregunta	INT = 0
			, @IDGrafica			INT = 0
			, @GRAFICA_LINEA		INT = 1
			, @dtFiltros			[Nomina].[dtFiltrosRH]
			, @dtEmpleados			[RH].[dtEmpleados]			
			, @Error				VARCHAR(MAX) = 'No es posible calcular un grupo de preguntas mixto'
			;
		
		DECLARE @tblPreguntasAll TABLE
		(
			IDGrupo				INT,
			Grupo				VARCHAR(MAX), 
			IDTipoPreguntaGrupo INT,
			IDEvaluador			INT,
			CopiadoDeIDGrupo	INT,
			IDPregunta			INT,
			IDTipoPregunta		INT,			
			Pregunta			VARCHAR(MAX),
			Calificar			INT,
			Respuesta			NVARCHAR(MAX)
		)

		DECLARE @tblPreguntas TABLE
		(
			IDGrupo				INT,
			Grupo				VARCHAR(MAX), 
			IDTipoPreguntaGrupo INT,
			IDEvaluador			INT,			
			IDPregunta			INT,
			IDTipoPregunta		INT,			
			Pregunta			VARCHAR(MAX),
			Calificar			INT,
			Respuesta			NVARCHAR(MAX)
		)

		DECLARE @tblRespuestasEnEscala TABLE
		(				
			Escala						VARCHAR(MAX),
			Valor						INT,
			NoRespuestas				INT			
		)

		DECLARE @tblInfoRecolectada TABLE
		(	
			IDGrupo						INT, 
			Grupo						VARCHAR(MAX), 
			IDTipoPreguntaGrupo			INT, 
			IDEvaluador					INT,			
			IDPregunta					INT, 
			IDTipoPregunta				INT, 
			Pregunta					VARCHAR(MAX), 
			Calificar					INT, 
			Respuesta					VARCHAR(MAX),			
			IDPosibleRespuesta			INT, 
			OpcionRespuesta				VARCHAR(MAX), 
			Valor						INT,
			ExisteEnRespuesta			INT
		)
		
		DECLARE @tblPreResultadoMixto TABLE
		(				
			IDEscala					INT,
			IDTipoPregunta				INT,
			Escala						VARCHAR(MAX),
			Valor						INT,
			TotalRespuestas				INT,
			NoRespuestas				INT
		)

		DECLARE @tblResultado TABLE
		(
			ID							INT IDENTITY(1,1),
			IDEscala					INT,
			Escala						VARCHAR(MAX),
			Valor						INT,
			NoRespuestas				INT,
			CalificacionAcumulada		INT,
			CalificacionMaxima			INT,
			TotalRespuestas				INT,
			PorcentajeValor				DECIMAL(18,2),
			PorcentajePregunta			DECIMAL(18,2)
		)
		
		DECLARE @tblPromedio TABLE
		(				
			IDEscala					INT,
			SumaRespuestas				INT,
			TotalRespuestas				INT,
			Promedio					DECIMAL(18,2)
		)

		
		-- CONVERTIMOS FILTROS A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT catalogo
				, REPLACE(valor, ' ', '') AS valor
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$'))
		  WITH (
			catalogo NVARCHAR(MAX) '$.Catalogo',
			valor NVARCHAR(MAX) '$.Value'
		  );
		--SELECT * FROM @dtFiltros
		
		
				
		-- OBTENEMOS LAS PREGUNTAS
		INSERT INTO @tblPreguntasAll(IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluador, CopiadoDeIDGrupo, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta)
		EXEC [Evaluacion360].[spObtenerGrupoPreguntaAnalitica] 
			@IDProyecto = @IDProyecto
			, @Descripcion = @Descripcion
			, @EsGrupo = @EsGrupo
			, @IDUsuario = @IDUsuario

		
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
				INSERT INTO @tblPreguntas(IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluador, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta)
				SELECT P.IDGrupo, P.Grupo, P.IDTipoPreguntaGrupo, P.IDEvaluador, P.IDPregunta, P.IDTipoPregunta, P.Pregunta, P.Calificar, P.Respuesta
				FROM @tblPreguntasAll P
					INNER JOIN @dtEmpleados E ON E.IDEmpleado = P.IDEvaluador
				GROUP BY P.IDGrupo, P.Grupo, P.IDTipoPreguntaGrupo, P.IDEvaluador, P.IDPregunta, P.IDTipoPregunta, P.Pregunta, P.Calificar, P.Respuesta
			END
		ELSE
			BEGIN
				INSERT INTO @tblPreguntas(IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluador, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta)
				SELECT IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluador, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta
				FROM @tblPreguntasAll
			END
		--SELECT * FROM @tblPreguntas
		
		

		-- DATOS PARA PRUEBAS
		/*

			DELETE @tblPreguntas
			
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 4)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 3)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 2)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 1)
			INSERT INTO @tblPreguntas VALUES(4439,'ESCALA DE LA PRUEBA', 2,	10196, 8, 'PREGUNTA ESCALA DE LA PRUEBA 1?', 1, 0)

			SELECT * FROM @tblPreguntas ORDER BY Respuesta DESC
		*/
		
		
		
		SELECT TOP 1 @IDTipoPreguntaGrupo = IDTipoPreguntaGrupo FROM @tblPreguntas;
		
		IF(@IDTipoPreguntaGrupo = @ESCALA_DE_LA_PRUEBA OR @IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL OR @IDTipoPreguntaGrupo = @FUNCION_CLAVE)
			BEGIN		
				
				-- OBTENEMOS ESCALA DEL GRUPO
				IF(@IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL)
					BEGIN
						SELECT TOP 1 @IDGrupo = IDGrupo FROM @tblPreguntas;
						INSERT INTO @tblRespuestasEnEscala(Escala, Valor, NoRespuestas)
						SELECT E.Nombre
								, E.Valor
								, COUNT(P.Respuesta) AS NoRespuestas								
						FROM [Evaluacion360].[tblEscalasValoracionesGrupos] E
							LEFT JOIN @tblPreguntas P ON E.Valor = P.Respuesta
						WHERE E.IDGrupo = @IDGrupo
						GROUP BY E.Nombre, E.Valor
						ORDER BY E.Valor DESC

						-- ESCALA INDIVIDUAL (USAR PARA PRUEBAS)
						--SELECT * FROM [Evaluacion360].[tblEscalasValoracionesGrupos] WHERE IDGrupo = @IDGrupo ORDER BY Valor DESC
						--SELECT * FROM @tblPreguntas ORDER BY CAST(Respuesta AS INT) DESC
						--SELECT * FROM @tblRespuestasEnEscala ORDER BY Valor DESC
					END
				ELSE
					BEGIN
						INSERT INTO @tblRespuestasEnEscala(Escala, Valor, NoRespuestas)
						SELECT E.Nombre
								, E.Valor
								, COUNT(P.Respuesta) AS NoRespuestas
						FROM [Evaluacion360].[tblEscalasValoracionesProyectos] E
							LEFT JOIN @tblPreguntas P ON E.Valor = P.Respuesta
						WHERE E.IDProyecto = @IDProyecto
						GROUP BY E.Nombre, E.Valor
						ORDER BY E.Valor DESC

						-- ESCALA PROYECTO (USAR PARA PRUEBAS)
						--SELECT * FROM [Evaluacion360].[tblEscalasValoracionesProyectos] WHERE IDProyecto = @IDProyecto ORDER BY Valor DESC
						--SELECT * FROM @tblPreguntas ORDER BY CAST(Respuesta AS INT) DESC
						--SELECT * FROM @tblRespuestasEnEscala ORDER BY Valor DESC
					END
					
				
				-- RESULTADO FINAL
				;WITH tblPreResultado(Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas)
				AS
					(
						SELECT RE.Escala	
								, CASE WHEN RE.Valor = 0 THEN 1  ELSE RE.Valor END AS Valor
								, RE.NoRespuestas
								, (CASE WHEN RE.Valor = 0 THEN 1  ELSE ABS(RE.Valor) END) * RE.NoRespuestas AS CalificacionAcumulada								
								, SUM((CASE WHEN RE.Valor = 0 THEN 1  ELSE ABS(RE.Valor) END) * RE.NoRespuestas) OVER () AS CalificacionMaxima								
								, SUM(RE.NoRespuestas) OVER () AS TotalRespuestas								
						FROM @tblRespuestasEnEscala RE
						--ORDER BY RE.Valor DESC
					)
				INSERT INTO @tblResultado(IDEscala, Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas, PorcentajeValor, PorcentajePregunta)
				SELECT @IDEscalaEstatico
						, Escala
						, Valor
						, NoRespuestas
						, CalificacionAcumulada
						, CalificacionMaxima
						, TotalRespuestas
						, CASE
							WHEN NoRespuestas > 0								
								THEN CAST(CalificacionAcumulada / CAST(CalificacionMaxima AS DECIMAL(18,2)) AS DECIMAL(18, 4)) * 100
								ELSE 0
							END AS PorcentajeValor						
						, CASE
							WHEN NoRespuestas > 0
								THEN CAST(NoRespuestas / CAST(TotalRespuestas AS DECIMAL(18,2)) AS DECIMAL(18, 4)) * 100								
								ELSE 0
							END AS PorcentajePregunta						
				FROM tblPreResultado				
				GROUP BY Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas
				ORDER BY Valor DESC
			END
						
		IF(@IDTipoPreguntaGrupo = @MIXTA)
			BEGIN			
				
				IF(@EsGrupo = @SI)
					BEGIN
						RAISERROR(@Error, 16, 1); 
						RETURN
					END

				-- RECOLECTAR INFORMACION DE LAS PREGUNTAS MIXTAS
				INSERT INTO @tblInfoRecolectada (IDGrupo, Grupo, IDTipoPreguntaGrupo, IDEvaluador, IDPregunta, IDTipoPregunta, Pregunta, Calificar, Respuesta, IDPosibleRespuesta, OpcionRespuesta, Valor, ExisteEnRespuesta)
				SELECT PT.*																	
						, PR.IDPosibleRespuesta
						, PR.OpcionRespuesta
						, PR.Valor
						, (SELECT CASE 
									WHEN CHARINDEX(CONVERT(VARCHAR(10), PR.IDPosibleRespuesta), PT.Respuesta) > 0 
									THEN 1
									ELSE 0
								END AS ExisteEnRespuesta	
						FROM [Evaluacion360].[tblRespuestasPreguntas] RP WHERE RP.IDPregunta = PT.IDPregunta) AS A
				FROM @tblPreguntas PT
					JOIN [Evaluacion360].[tblCatPreguntas] P ON PT.IDPregunta = P.IDPregunta
					LEFT JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PR ON P.IDPregunta = PR.IDPregunta
				ORDER BY PT.IDGrupo, PT.Pregunta, IDPosibleRespuesta
				
				-- INFO RESTRUCTURADA (USAR PARA PRUEBAS)
				--SELECT * FROM @tblInfoRecolectada ORDER BY Pregunta, IDGrupo				
				
				-- SE CREAN ESCALAS Y SE OBTIENEN LOS PRE-RESULTADOS
				;WITH tblPreguntaEscala(IDEscala, IDTipoPregunta, Pregunta, OpcionRespuesta, Valor)
				AS
					(
						SELECT DENSE_RANK() OVER (ORDER BY Pregunta) AS IDEscala
								, IDTipoPregunta
								, Pregunta						
								, OpcionRespuesta
								, Valor								
						FROM @tblInfoRecolectada
						GROUP BY IDTipoPregunta, Pregunta, OpcionRespuesta, Valor
					)
				INSERT INTO @tblPreResultadoMixto(IDEscala, Escala, IDTipoPregunta, Valor, TotalRespuestas, NoRespuestas)
				SELECT PE.IDEscala
						, PE.OpcionRespuesta AS Escala
						, PE.IDTipoPregunta
						, PE.Valor						
						, (SELECT COUNT(*) FROM @tblInfoRecolectada IR WHERE IR.Pregunta = PE.Pregunta AND IR.OpcionRespuesta = PE.OpcionRespuesta) AS TotalRespuestas
						, (SELECT COUNT(*) FROM @tblInfoRecolectada IR WHERE IR.Pregunta = PE.Pregunta AND IR.OpcionRespuesta = PE.OpcionRespuesta AND IR.ExisteEnRespuesta = 1) AS NoRespuestas
				FROM tblPreguntaEscala PE
				GROUP BY PE.IDEscala, PE.OpcionRespuesta, PE.IDTipoPregunta, PE.Pregunta, PE.Valor

								
				-- RESULTADO FINAL
				;WITH tblPreResultadoMixto(IDEscala, Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas)
				AS
					(
						SELECT M1.IDEscala
								, M1.Escala
								, M1.Valor								
								, M1.NoRespuestas
								, M1.Valor * M1.NoRespuestas AS CalificacionAcumulada
								, SUM(M1.Valor * M1.NoRespuestas) OVER () AS CalificacionMaxima
								, M1.TotalRespuestas
						FROM @tblPreResultadoMixto M1
					)
				INSERT INTO @tblResultado(IDEscala, Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas, PorcentajeValor, PorcentajePregunta)
				SELECT IDEscala
						, Escala										
						, Valor
						, NoRespuestas
						, CalificacionAcumulada
						, CalificacionMaxima
						, TotalRespuestas
						, CASE
							WHEN NoRespuestas > 0								
								THEN CAST(CalificacionAcumulada / CAST(CalificacionMaxima AS DECIMAL(18,2)) AS DECIMAL(18, 4)) * 100
								ELSE 0
							END AS PorcentajeValor
						, CASE
							WHEN NoRespuestas > 0
								THEN CAST(NoRespuestas / CAST(TotalRespuestas AS DECIMAL(18,2)) AS DECIMAL(18, 4)) * 100
								ELSE 0
							END AS PorcentajePregunta
				FROM tblPreResultadoMixto
				GROUP BY IDEscala, Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas
				ORDER BY IDEscala, Valor

			END



		-- OBTENEMOS PROMEDIO
		INSERT INTO @tblPromedio(IDEscala, SumaRespuestas, TotalRespuestas, Promedio)
		SELECT SubQuery.IDEscala
				, SubQuery.SumaRespuestas
				, SubQuery.TotalRespuestas
				, CAST(CAST(SumaRespuestas AS DECIMAL(18,2)) / TotalRespuestas AS DECIMAL(18,2)) AS Promedio
		FROM (
			SELECT IDEscala
				   , SUM(CalificacionAcumulada) AS SumaRespuestas
				   , SUM(NoRespuestas) AS TotalRespuestas
			FROM @tblResultado
			WHERE Valor > 0
			GROUP BY IDEscala
		) AS SubQuery
		GROUP BY SubQuery.IDEscala, SubQuery.SumaRespuestas, SubQuery.TotalRespuestas



		/*
			RESULTADOS FINALES (PROMEDIOS Y DATOS CALCULADOS) --------------------------------------------------------------------------
		*/		
		--SELECT * FROM @tblResultado
		--SELECT * FROM @tblPromedio

		IF((SELECT COUNT(*) FROM @tblResultado) = 0)
			BEGIN
				INSERT INTO @tblResultado VALUES (1, 'Sin Contestar', 0, 0, 0, 0, 0, 0, 0)
			END

		
		-- PROMEDIOS ***************************************************
		;WITH tblPromedio(IDEscala, SumaRespuestas, TotalRespuestas, Promedio, PromedioRedondeado)
		AS
			(
				SELECT P.*
						, CASE 
							WHEN ROUND(P.Promedio - FLOOR(P.Promedio), 1) > 0.4 
								THEN CEILING(P.Promedio)
								ELSE FLOOR(P.Promedio)
							END AS PromedioRedondeado		
				FROM @tblPromedio P				
			)
		SELECT TOP 1
				  P.* 
				, R.Escala
				, ABS(P.PromedioRedondeado - R.Valor) ValorMasCercano
		FROM tblPromedio P
			LEFT JOIN @tblResultado R ON P.IDEscala = R.IDEscala
		WHERE R.Valor > 0		
		ORDER BY ABS(PromedioRedondeado - R.Valor), R.Valor DESC
		--WHERE R.Valor = P.PromedioRedondeado


		-- GRAFICA Y DATOS CALCULADOS JSON ***************************************************
		SELECT TOP 1 @CopiadoDeIDGrupo = CopiadoDeIDGrupo FROM @tblPreguntasAll;
		SELECT TOP 1 @CopiadoDeIDPregunta = IDPregunta FROM [Evaluacion360].[tblCatPreguntas] WHERE IDGrupo = @CopiadoDeIDGrupo AND Descripcion = @Descripcion;

		SELECT @IDGrafica = IDGrafica 
		FROM [Evaluacion360].[tblConfGraficasAnalitica] 
		WHERE IDProyecto = IDProyecto
			AND CopiadoDeIDGrupo = @CopiadoDeIDGrupo
			AND EsGrupo = @EsGrupo
			AND IDUsuario = @IDUsuario
			AND (
					(@EsGrupo = @SI AND CopiadoDeIDPregunta = 0) OR (@EsGrupo <> @SI AND CopiadoDeIDPregunta = @CopiadoDeIDPregunta)
				);
		
		;WITH TblLabel(Descripcion)
		AS
			(
				SELECT @Descripcion
			)
		SELECT 
			CASE 
				WHEN @IDGrafica = 0 
					THEN @GRAFICA_LINEA 
					ELSE @IDGrafica 
				END AS IDGrafica,
			(
				SELECT L.Descripcion
						, (
							SELECT R.Escala
									, CASE
										WHEN @PorPorcentaje = @SI
											THEN R.PorcentajeValor
											ELSE R.NoRespuestas
										END AS Resultado
							FROM @tblResultado R
							FOR JSON PATH
						  ) AS Grupo
				FROM TblLabel L
				FOR JSON AUTO
			) AS ResultJson;
			

		-- DATOS CALCULADOS JSON ***************************************************
		SELECT Escala 
				, CASE
					WHEN @PorPorcentaje = @SI
						THEN PorcentajeValor
						ELSE NoRespuestas
					END AS Resultado
				, CASE
					WHEN @PorPorcentaje = @SI
						THEN 100
						ELSE TotalRespuestas
					END AS ResultadoMaximo
		FROM @tblResultado
		
		-- SELECT * FROM @tblResultado

	END
GO

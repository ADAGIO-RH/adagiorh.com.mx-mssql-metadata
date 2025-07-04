USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las preguntas calificables del proyecto y regresa la escala en la que se califico
**					  con su porcentaje en formato Json.
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
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spBuscarPreguntasAnaliticasCalificables]
(
	@IDProyecto INT
	,@IDUsuario INT
) AS

	DECLARE  @TipoPrueba INT = 1
			,@Calificar INT = 1
			,@PreguntaOpcionMultiple INT = 1
			,@PreguntaVerificacion INT = 2			
			,@PreguntaDesplegable INT = 5			
			,@PreguntaEscala INT = 8
			,@PreguntaIndividual INT = 9			
			,@PreguntaClave INT = 11

	DECLARE @TblGrupo TABLE(
		IDProyecto INT
		,IDGrupo INT
	)

	DECLARE @TblPreguntas TABLE(
		IDPregunta INT
		,Descripcion VARCHAR(MAX)
		,Respuesta INT
		,ValoresRespuestas VARCHAR(MAX)
	)

	DECLARE @TblPorcentaje TABLE(
		Descripcion VARCHAR(MAX)
		,Porcentaje VARCHAR(MAX)
		,ValoresRespuestas VARCHAR(MAX)
	)

	DECLARE @TblPorcentajeJson TABLE(
		Descripcion VARCHAR(MAX)
		,Porcentaje VARCHAR(MAX)
		,ValoresRespuestas VARCHAR(MAX)
	)



	-- OBTENEMOS GRUPOS
	INSERT INTO @TblGrupo(IDProyecto, IDGrupo)
	SELECT P.IDProyecto
	       ,G.IDGrupo
	FROM [Evaluacion360].[tblCatProyectos] P
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto		
		LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto		
		LEFT JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
	WHERE P.IDProyecto = @IDProyecto
	ORDER BY G.IDGrupo



	-- PROCESA TODAS LAS PREGUNTAS EXCEPTO "PREGUNTA VERIFICACION"
	INSERT INTO @TblPreguntas(IDPregunta, Descripcion, Respuesta, ValoresRespuestas)
	SELECT P.IDPregunta
		   ,P.Descripcion
		   ,CASE
				WHEN P.IDTipoPregunta = @PreguntaDesplegable
					THEN (SELECT PR.Valor FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] PR WHERE PR.IDPosibleRespuesta = R.Respuesta)
					ELSE ISNULL(R.Respuesta, 0)
				END AS Respuesta,
		    CASE 
				WHEN (P.IDTipoPregunta = @PreguntaEscala OR P.IDTipoPregunta = @PreguntaClave)
					THEN 
					(
						SELECT EP.Nombre AS [Key],
							   EP.Valor AS [Value]
						FROM [Evaluacion360].[tblEscalasValoracionesProyectos] EP
						WHERE EP.IDProyecto = @IDProyecto 
						FOR JSON PATH
					)
				WHEN P.IDTipoPregunta = @PreguntaIndividual
					THEN 
					(
						SELECT EI.Nombre AS [Key],
							   EI.Valor AS [Value]
						FROM [Evaluacion360].[tblEscalasValoracionesGrupos] EI
						WHERE EI.IDGrupo = G.IDGrupo
						FOR JSON PATH
					)
				WHEN P.IDTipoPregunta = @PreguntaOpcionMultiple OR P.IDTipoPregunta = @PreguntaDesplegable
					THEN 
					(
						SELECT OpcionRespuesta AS [Key],
							   Valor AS [Value]
						FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas]
						WHERE IDPregunta = P.IDPregunta
						FOR JSON PATH
					)
			END AS ValoresRespuestas
	FROM @TblGrupo G
		LEFT JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
		LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] R ON P.IDPregunta = R.IDPregunta		
	WHERE ISNULL(R.Respuesta, 'SinContestar') <> 'SinContestar'
		  AND P.Calificar = @Calificar	
		  AND P.IDTipoPregunta NOT IN (@PreguntaVerificacion)
		  --AND Descripcion = 'OPCION MULTIPLE 131?'
	ORDER BY R.IDPregunta
	
	

	-- PROCESO LA PREGUNTA VERIFICACION
	INSERT INTO @TblPreguntas(IDPregunta, Descripcion, Respuesta, ValoresRespuestas)
	SELECT P.IDPregunta,
		   P.Descripcion
		   ,ISNULL((SELECT PR.Valor FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] PR WHERE PR.IDPosibleRespuesta = CAST(SS.Value AS INT)), CAST(SS.Value AS INT)) AS Respuesta
		   ,(
			 SELECT OpcionRespuesta AS [Key],
				    Valor AS [Value]
			 FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas]
			 WHERE IDPregunta = P.IDPregunta
			 FOR JSON PATH
		    ) AS ValoresRespuestas
		FROM @TblGrupo G
			LEFT JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
			LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] R ON P.IDPregunta = R.IDPregunta
			CROSS APPLY STRING_SPLIT(R.Respuesta, ',') AS SS
		WHERE ISNULL(R.Respuesta, 'SinContestar') <> 'SinContestar'
			  AND P.Calificar = @Calificar
			  AND P.IDTipoPregunta = @PreguntaVerificacion
		ORDER BY R.IDPregunta
	
	
	
	-- PROCESO PORCENTAJES		
	INSERT INTO @TblPorcentaje(Descripcion, Porcentaje, ValoresRespuestas)
    SELECT P.Descripcion
		   ,(
             SELECT [Key]
			 	    , CAST((CAST
						   (COUNT(P.Respuesta) AS DECIMAL(18, 2)) / (SELECT COUNT(P2.Respuesta) FROM @TblPreguntas P2 WHERE P2.Descripcion = P.Descripcion)) * 100 
					  AS DECIMAL(18, 2)) AS [Value]
			 FROM OPENJSON(P.ValoresRespuestas)
             WITH (
                 [Key] VARCHAR(MAX) '$.Key'
				 ,[Value] INT '$.Value'
             )
             WHERE [Value] = P.Respuesta            
             FOR JSON PATH
           ) AS Porcentaje, -- FORMULA ((NoRespuestas / TotalRespuestas) * 100)
		P.ValoresRespuestas
    FROM @TblPreguntas P	
    GROUP BY P.Descripcion, P.Respuesta, P.ValoresRespuestas



	-- PORCENTAJES EN FORMTATO JSON
	INSERT INTO @TblPorcentajeJson(Descripcion, Porcentaje, ValoresRespuestas)
	SELECT P1.Descripcion
		   ,(
			 SELECT JSON_VALUE(P2.Porcentaje, '$[0].Key') AS [Key]
					,CAST(JSON_VALUE(P2.Porcentaje, '$[0].Value') AS DECIMAL(10, 2)) AS [Value]
			 FROM @TblPorcentaje P2
			 WHERE P2.Descripcion = P1.Descripcion             
			 FOR JSON PATH
			) AS Porcentajes,
		   P1.ValoresRespuestas
    FROM @TblPorcentaje P1
	WHERE P1.Porcentaje IS NOT NULL
    GROUP BY P1.Descripcion, P1.ValoresRespuestas



	-- RESULTADO FINAL
	SELECT Descripcion,
		   (
				SELECT A.[Key], ISNULL(B.[Value], 0) AS [Value]
				FROM (
					SELECT *
					FROM OPENJSON(PJ.ValoresRespuestas)
					WITH (
						[Key] VARCHAR(MAX) '$.Key'
						,[Value] INT '$.Value'
					)
				) AS A
				LEFT JOIN (
					SELECT *
					FROM OPENJSON(PJ.Porcentaje)
					WITH (
						[Key] VARCHAR(MAX) '$.Key'
						,[Value] DECIMAL(18,2) '$.Value'
					)
				) AS B ON A.[Key] = B.[Key]
				FOR JSON PATH			
			) AS Escala
	FROM @TblPorcentajeJson PJ
GO

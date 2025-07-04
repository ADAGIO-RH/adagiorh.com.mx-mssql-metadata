USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Busca los resultados de la encuesta de servicios (De: Evaluaciones)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-01-25
** Paremetros		: @IDProyecto			- Identificador del proyecto "evaluacion".
					  @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Reportes].[spReporteBasicoEncuestaResultado](
	@IDProyecto			INT = 0	
	, @RazonesSociales	VARCHAR(MAX) = ''
	, @RegPatronales	VARCHAR(MAX) = ''
	, @Divisiones		VARCHAR(MAX) = ''
	, @Departamentos	VARCHAR(MAX) = ''
	, @Sucursales		VARCHAR(MAX) = ''
	, @Puestos			VARCHAR(MAX) = ''
	, @IDUsuario		INT = 0
)
AS
BEGIN
	
	-- VALIABLES ****************************************************
	DECLARE
		@PRUEBA_FINAL	INT = 4
		, @empleados	[RH].[dtEmpleados]
		, @dtFiltros	[Nomina].[dtFiltrosRH]
		, @fechaInicio  DATE        
		, @fechaFin		DATE 
		;	      
		

	-- TABLAS TEMPORALES ********************************************
	DECLARE @tempEscala TABLE
	(
		IDEscala	INT
		, Nombre	VARCHAR(100) COLLATE database_default
		, Valor		INT
	)

	DECLARE @tempGrupos TABLE
	(
		IDGrupo			INT
		, Grupo			VARCHAR(100) COLLATE database_default		
	)

	DECLARE @tempPreguntas TABLE
	(
		IDGrupo			INT
		, IDPregunta	INT
		, IDRespuesta	INT
		, Grupo			VARCHAR(100) COLLATE database_default
		, Pregunta		VARCHAR(MAX) COLLATE database_default
		, Respuesta		VARCHAR(MAX) COLLATE database_default
		, Orden			INT
	)

	DECLARE @tempCrossPreguntas TABLE
	(
		Grupo			VARCHAR(100) COLLATE database_default
		, Pregunta		VARCHAR(MAX) COLLATE database_default
		, Escala		VARCHAR(100) COLLATE database_default
		, Valor			INT
		, Orden			INT
	)

	DECLARE @tempEstadisticaGrupoPregunta TABLE
	(
		Grupo					VARCHAR(100) COLLATE database_default
		, Pregunta				VARCHAR(MAX) COLLATE database_default
		, Escala				VARCHAR(100) COLLATE database_default
		, Valor					INT
		, NoRespuestas			INT
		, CalificacionAcumulada	INT
		, CalificacionMaxima	INT
		, TotalRespuestas		INT
		, Orden					INT
	)


	-- FILTROS ****************************************************

	SELECT @fechaInicio = FechaInicio, @fechaFin = FechaFin FROM [Evaluacion360].[tblcatproyectos] WHERE IDProyecto = @IDProyecto;

	INSERT INTO @dtFiltros(Catalogo, [Value])
	VALUES
		('RazonesSociales', @RazonesSociales)
		, ('RegPatronales', @RegPatronales)
		, ('Divisiones', @Divisiones)
		, ('Departamentos', @Departamentos)
		, ('Sucursales', @Sucursales)
		, ('Puestos', @Puestos)
	INSERT INTO @empleados
    EXEC [RH].[spBuscarEmpleados]
		@FechaIni		= @fechaInicio
		, @Fechafin		= @fechaFin
		, @dtFiltros	= @dtFiltros
		, @IDUsuario	= @IDUsuario
	--SELECT * FROM @empleados
		
		
	-- OBTENEMOS LA ESCALA DEL PROYECTO *****************************
	INSERT INTO @tempEscala(IDEscala, Nombre, Valor)
	SELECT IDEscalaValoracionProyecto
			, Nombre
			, Valor
	FROM Evaluacion360.tblEscalasValoracionesProyectos
	WHERE IDProyecto = @IDProyecto
	INSERT INTO @tempEscala VALUES(0, 'TOTAL', NULL)
	--SELECT * FROM @tempEscala



	-- OBTENEMOS LOS GRUPOS DEL PROYECTO ****************************
	INSERT INTO @tempGrupos(IDGrupo, Grupo)
	SELECT G.IDGrupo
			, G.Nombre
			--, E.IDEmpleado
			--, P.IDProyecto
			--, EP.TipoFiltro
			--, G.TipoReferencia
	FROM Evaluacion360.tblCatProyectos P
		LEFT JOIN Evaluacion360.tblEmpleadosProyectos EP ON P.IDProyecto = EP.IDProyecto		
		LEFT JOIN Evaluacion360.tblEvaluacionesEmpleados EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
		LEFT JOIN Evaluacion360.tblCatGrupos G ON EE.IDEvaluacionEmpleado = G.IDReferencia
		JOIN @empleados E ON EP.IDEmpleado = E.IDEmpleado  
	WHERE P.IDProyecto = @IDProyecto
		AND G.TipoReferencia = @PRUEBA_FINAL
	ORDER BY G.IDGrupo
	-- SELECT * FROM @tempGrupos	 


	-- OBTENEMOS LAS PREGUNTAS EN SU GRUPO **************************
	INSERT INTO @tempPreguntas(IDGrupo, IDPregunta, IDRespuesta, Grupo, Pregunta, Respuesta, Orden)
	SELECT G.IDGrupo
			, P.IDPregunta
			, R.IDRespuestaPregunta
			, G.Grupo
			, P.Descripcion AS Pregunta
			, R.Respuesta
			, ROW_NUMBER() OVER (PARTITION BY G.IDGrupo ORDER BY P.IDPregunta) AS Orden
	FROM @tempGrupos G
		JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
		LEFT JOIN Evaluacion360.tblRespuestasPreguntas R ON P.IDPregunta = R.IDPregunta
	-- SELECT * FROM @tempPreguntas


	-- NORMALIZAMOS LA INFORMACIÓN
	INSERT INTO @tempCrossPreguntas(Grupo, Pregunta, Escala, Valor, Orden)
	SELECT P.Grupo, P.Pregunta, ESC.Nombre AS Escala, ESC.Valor AS ValorEscala, P.Orden
	FROM @tempPreguntas P
		CROSS APPLY (
			SELECT E.Nombre
				   , E.Valor
			FROM @tempEscala E
		) ESC
	--WHERE P.Grupo = 'UNIFORMES'
	GROUP BY P.Grupo, P.Pregunta, P.Orden, ESC.Nombre, ESC.Valor
	ORDER BY P.Grupo, P.Orden, ESC.Valor DESC
	--SELECT * FROM @tempCrossPreguntas



	-- UTILIZAMOS PARA REVISION ***********************************************************
	/*
		DECLARE @PreguntaAux VARCHAR(250) = '¿LA CANTIDAD SERVIDA ES SUFICIENTE?'

		SELECT * FROM @tempPreguntas
		WHERE Pregunta = @PreguntaAux ORDER BY Grupo, Orden, Respuesta DESC

		SELECT * FROM @tempCrossPreguntas
		WHERE Pregunta = @PreguntaAux ORDER BY Valor DESC

		-- NOTA: DESCOMENTAMOS EL WHERE DE LAS CONSULTAS "UNION ALL"
	*/

	

	INSERT INTO @tempEstadisticaGrupoPregunta(Grupo, Pregunta, Escala, Valor, NoRespuestas, CalificacionAcumulada, CalificacionMaxima, TotalRespuestas, Orden)
	SELECT CP.Grupo
			, CP.Pregunta
			, CP.Escala
			, CP.Valor
			, COUNT(P.Respuesta) AS NoRespuestas
			, (CASE WHEN CP.Valor = 0 THEN 1  ELSE ABS(CP.Valor) END) * COUNT(P.Respuesta) AS CalificacionAcumulada
			, SUM((CASE WHEN CP.Valor = 0 THEN 1  ELSE ABS(CP.Valor) END) * COUNT(P.Respuesta)) OVER (PARTITION BY CP.Grupo, CP.Pregunta) AS CalificacionMaxima
			, SUM(COUNT(P.Respuesta)) OVER (PARTITION BY CP.Grupo, CP.Pregunta) AS TotalRespuestas
			, CP.Orden
	FROM @tempCrossPreguntas CP
		LEFT JOIN @tempPreguntas P ON CP.Pregunta = P.Pregunta AND CP.Valor = P.Respuesta
	--WHERE CP.Pregunta = @PreguntaAux
	GROUP BY CP.Grupo, CP.Pregunta, CP.Escala, CP.Valor, CP.Orden
	ORDER BY CP.Grupo, CP.Orden, CP.Valor DESC

	
	-- RESULTADO FINAL
	SELECT Grupo, Pregunta, Escala, Resultado, Tipo--, Orden, Valor
	FROM (

		SELECT Grupo
				, Pregunta
				, Escala
				, CAST(
					CAST(CASE
						WHEN Escala <> 'TOTAL'
							THEN ISNULL((CalificacionAcumulada / CAST(NULLIF(CalificacionMaxima, 0) AS DECIMAL(18,2))) * 100, 0)
							ELSE ISNULL(SUM(CalificacionAcumulada / CAST(NULLIF(CalificacionMaxima, 0) AS DECIMAL(18,2)) * 100) OVER (PARTITION BY Grupo, Pregunta), 0)
						END AS DECIMAL(18, 2))
					AS VARCHAR(50)) AS Resultado
				, 'Porcentaje' AS Tipo
				, Orden
				, Valor
		FROM @tempEstadisticaGrupoPregunta
		--WHERE Pregunta = '¿EL ÁREA DE  DESCAMOCHE SE ENCUENTRA LIMPIA?'		
		--ORDER BY Grupo, Orden, Valor DESC

		UNION ALL

		SELECT Grupo
				, Pregunta
				, Escala
				, CAST(
					CASE
						WHEN Escala <> 'TOTAL'
							THEN NoRespuestas
							ELSE SUM(NoRespuestas) OVER (PARTITION BY Grupo, Pregunta)
						END 
					AS VARCHAR(50)) AS Resultado
				, 'Cantidad' AS Tipo
				, Orden
				, Valor
		FROM @tempEstadisticaGrupoPregunta
		--WHERE Pregunta = '¿EL ÁREA DE  DESCAMOCHE SE ENCUENTRA LIMPIA?'		
		--ORDER BY Grupo, Orden, Valor DESC

	) AS ResultadoFinal
	ORDER BY Tipo DESC, Grupo, Orden, Valor DESC


END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Busca los comentarios de la encuesta de servicios (De: Evaluaciones)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		: @IDProyecto			- Identificador del proyecto "evaluacion".
					  @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE PROCEDURE [Reportes].[spReporteBasicoEncuestaComentario](
	@IDProyecto		INT = 0
	, @RazonesSociales	VARCHAR(MAX) = ''
	, @RegPatronales	VARCHAR(MAX) = ''
	, @Divisiones		VARCHAR(MAX) = ''
	, @Departamentos	VARCHAR(MAX) = ''
	, @Sucursales		VARCHAR(MAX) = ''
	, @Puestos			VARCHAR(MAX) = ''
	, @IDUsuario	INT = 0
)
AS
BEGIN
	
	-- VALIABLES ****************************************************
	DECLARE
		@PRUEBA_FINAL INT = 4
		, @empleados	[RH].[dtEmpleados]
		, @dtFiltros	[Nomina].[dtFiltrosRH]
		, @fechaInicio  DATE        
		, @fechaFin		DATE 
		;



	-- TABLAS TEMPORALES ********************************************
	DECLARE @tempGrupos TABLE
	(
		IDGrupo			INT
		, Grupo			VARCHAR(255) COLLATE database_default
		, Comentario	VARCHAR(MAX) COLLATE database_default
	)

	DECLARE @tempComentarios TABLE
	(
		Grupo					VARCHAR(255) COLLATE database_default
		, ComentarioGrupo		VARCHAR(MAX) COLLATE database_default
		, Pregunta				VARCHAR(MAX) COLLATE database_default
		, ComentarioPregunta	VARCHAR(MAX) COLLATE database_default
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
	


	-- OBTENEMOS LOS GRUPOS DEL PROYECTO ****************************
	INSERT INTO @tempGrupos(IDGrupo, Grupo, Comentario)
	SELECT G.IDGrupo
			, G.Nombre
			, G.Comentario
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
	--SELECT * FROM @tempGrupos



	-- OBTENEMOS LOS COMENTARIOS DEL GRUPO Y SUS PREGUNTAS ****************************
	INSERT INTO @tempComentarios(Grupo, ComentarioGrupo, Pregunta, ComentarioPregunta)
	SELECT G.Grupo
			, G.Comentario AS ComentarioGrupo
			, P.Descripcion AS Pregunta
			, CP.Comentario AS ComentarioPregunta
			--, G.IDGrupo
			--, P.IDPregunta						
			--, P.Descripcion AS Pregunta
	FROM @tempGrupos G
		JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
		LEFT JOIN Evaluacion360.tblComentariosPregunta CP ON P.IDPregunta = CP.IDPregunta
	ORDER BY G.IDGrupo, P.IDPregunta
	--SELECT * FROM @tempComentarios



	-- RESULTADO FINAL
	SELECT Grupo, Pregunta, Comentario, Tipo
	FROM (

		SELECT Grupo
				, '' AS Pregunta
				, UPPER(ComentarioGrupo) AS Comentario
				, 'Grupo' AS Tipo
		FROM @tempComentarios
		WHERE ComentarioGrupo IS NOT NULL
		GROUP BY Grupo, ComentarioGrupo

		UNION ALL

		SELECT Grupo
				, Pregunta
				, UPPER(ComentarioPregunta) AS Comentario
				, 'Pregunta' AS Tipo
		FROM @tempComentarios
		WHERE ComentarioPregunta IS NOT NULL
		GROUP BY Grupo, ComentarioPregunta, Pregunta
	
	) AS ResultadoFinal
	ORDER BY Tipo, Grupo, Pregunta	

END
GO

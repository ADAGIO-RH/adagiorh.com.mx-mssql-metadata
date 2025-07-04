USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene las preguntas de los grupos solicitados
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-11-01
** Paremetros		: @IDProyecto		Identificador del proyecto
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

CREATE   PROC [Evaluacion360].[spBuscarPreguntasDeGrupoAnalitica](
	@IDProyecto		INT = 0
	,@JsonFiltros	NVARCHAR(MAX) = ''
	,@IDUsuario		INT = 0
)
AS
	BEGIN
		
		DECLARE 
			@dtFiltros		[Nomina].[dtFiltrosRH]
			, @PRUEBA_FINAL INT = 4;

		DECLARE @tblPreguntas TABLE
		(
			Grupo VARCHAR(MAX), 
			Pregunta VARCHAR(MAX)
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

		
		-- OBTENEMOS LAS PREGUNTAS DE LOS GRUPOS SOLICITADOS
		;WITH tblGrupos(IDGrupo, Nombre)
		AS
			(
				SELECT G.IDGrupo
						, G.Nombre
				FROM [Evaluacion360].[tblCatProyectos] P
					LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
					LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
					JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
				WHERE P.IDProyecto = @IDProyecto 
						AND G.TipoReferencia = @PRUEBA_FINAL 
						AND	(
								REPLACE(G.Nombre, ' ', '') IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'GrupoNombre'),',')) 
								OR (
									NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'GrupoNombre' AND ISNULL(Value, '') <> '')
								)
							) 
			)		
		INSERT INTO @tblPreguntas(Grupo, Pregunta)
		SELECT G.Nombre
				, P.Descripcion  
		FROM tblGrupos G	
			JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
		WHERE G.IDGrupo = P.IDGrupo
		GROUP BY G.Nombre, P.Descripcion

		
		SELECT * FROM @tblPreguntas		

	END
GO

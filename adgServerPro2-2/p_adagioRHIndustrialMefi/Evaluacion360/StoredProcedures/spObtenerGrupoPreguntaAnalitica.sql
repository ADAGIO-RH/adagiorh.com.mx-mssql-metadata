USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene las preguntas de un grupo o la pregunta deseada que se encuentre entre todos los grupos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-11-07
** Paremetros		: @IDProyecto		Identificador del proyecto
**					: @Descripcion		Nombre de grupo o de la pregunta
**					: @EsGrupo			Bandera que indica si estamos calculando un grupo o una pregunta
**					: @IDUsuario		Identificador del usuario
** IDIssue			: 558

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spObtenerGrupoPreguntaAnalitica](
	@IDProyecto		INT = 0
	, @Descripcion	VARCHAR(MAX) = ''
	, @EsGrupo		BIT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN
		
		DECLARE 
			@sql NVARCHAR(MAX)
			, @PRUEBA_FINAL		INT = 4
			, @OPCION_MULTIPLE	INT = 1
			, @Calificable		INT = 1
			, @NO				INT = 0
			, @SI				INT = 1
			;


		SET @sql = N'
					;WITH tblGrupos(IDGrupo, Nombre, IDTipoPreguntaGrupo, IDEvaluador, CopiadoDeIDGrupo)
					AS
						(
							SELECT G.IDGrupo
									, G.Nombre
									, G.IDTipoPreguntaGrupo
									, EE.IDEvaluador
									, G.CopiadoDeIDGrupo
							FROM [Evaluacion360].[tblCatProyectos] P
								LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
								LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
								JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
							WHERE P.IDProyecto = ''' + CAST(@IDProyecto AS VARCHAR(25)) + '''
									AND G.TipoReferencia = ''' + CAST(@PRUEBA_FINAL AS VARCHAR(1)) + '''
									' + CASE
										WHEN @EsGrupo = @SI
											THEN 'AND G.Nombre = ''' + CAST(@Descripcion AS VARCHAR(MAX)) + ''''
											ELSE ''
										END
									+ '
						)
					SELECT G.IDGrupo
							, G.Nombre
							, G.IDTipoPreguntaGrupo
							, G.IDEvaluador
							, G.CopiadoDeIDGrupo
							, P.IDPregunta
							, P.IDTipoPregunta
							, P.Descripcion
							, P.Calificar
							--, PR.Respuesta
							, CASE
								WHEN P.IDTipoPregunta = ''' + CAST(@OPCION_MULTIPLE AS VARCHAR(1)) + '''
									THEN (SELECT TOP 1 CAST(ISNULL(PRP.IDPosibleRespuesta, 0) AS VARCHAR(25)) AS Respuesta 
										  FROM [Evaluacion360].[tblPosiblesRespuestasPreguntas] PRP 
										  WHERE PRP.IDPregunta = P.IDPregunta AND PRP.Valor = PR.Respuesta)
									ELSE PR.Respuesta
								END AS Respuesta
					FROM tblGrupos G
						JOIN [Evaluacion360].[tblCatPreguntas] P ON G.IDGrupo = P.IDGrupo
						JOIN [Evaluacion360].[tblRespuestasPreguntas] PR ON P.IDPregunta = PR.IDPregunta
					WHERE G.IDGrupo = P.IDGrupo	AND
						  P.Calificar = ''' + CAST(@Calificable AS VARCHAR(1)) + '''
						  ' + CASE
								WHEN @EsGrupo = @NO
									THEN 'AND P.Descripcion = ''' + CAST(@Descripcion AS VARCHAR(MAX)) + ''''
									ELSE ''
								END 
							+ '
					';	
		--PRINT @sql
		EXEC sp_executesql @sql;

	END
GO

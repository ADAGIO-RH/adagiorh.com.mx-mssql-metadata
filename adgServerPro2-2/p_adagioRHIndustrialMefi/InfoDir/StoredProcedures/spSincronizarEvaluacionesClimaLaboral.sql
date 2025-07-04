USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Sincronizacion de datos sobre las respuestas de proyectos de clima laboral (Indicadores)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-07-10
** Paremetros		: @IDEvaluacionEmpleado			- Identificador de la evaluacion por empleado.					  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [InfoDir].[spSincronizarEvaluacionesClimaLaboral](
	@IDProyecto			  INT = NULL,
	@IDEvaluacionEmpleado INT = NULL
)
AS
BEGIN	

	--DECLARE  @IDProyecto INT = 127
	--		,@IDEvaluacionEmpleado INT = 8763

	DECLARE	@PRUEBA_FINAL INT = 4

					   			 	
	SELECT CONVERT(DATE, GETDATE()) AS FechaNormalizacion
		  ,P.IDProyecto
		  ,GRUPO.IDGrupo
		  ,GRUPO.IDTipoGrupo
		  ,GRUPO.IDTipoPreguntaGrupo
		  ,GRUPO.IDReferencia AS IDEvaluacionEmpleado
		  ,EMPLEADO.IDEmpleado		  
		  ,EMPLEADO.FechaNacimiento
		  ,ISNULL(GRUPO.TotalPreguntas, 0) AS TotalPreguntas
		  ,ISNULL(GRUPO.MaximaCalificacionPosible, 0) AS MaximaCalificacionPosible
		  ,ISNULL(GRUPO.CalificacionObtenida, 0) AS CalificacionObtenida
		  ,ISNULL(GRUPO.CalificacionMinimaObtenida, 0) AS CalificacionMinimaObtenida
		  ,ISNULL(GRUPO.CalificacionMaxinaObtenida, 0) AS CalificacionMaxinaObtenida
		  ,ISNULL(GRUPO.Promedio, 0) AS Promedio
		  ,ISNULL(GRUPO.Porcentaje, 0) AS Porcentaje
		  -- PREGUNTA
		  ,PREGUNTA.IDPregunta		  
		  -- RESPUESTA
		  ,RESPUESTA.Respuesta
		  ,RESPUESTA.ValorFinal
		  -- INDICADOR PREGUNTA
		  ,INDICADOR.IDIndicador
		  -- FILTROS
		  ,ISNULL(LEFT(EMPLEADO.Sexo, 1), '') AS IDGenero
		  ,(CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)) - CONVERT(CHAR(8), EMPLEADO.FechaAntiguedad, 112)) / 10000 AS Antiguedad
		  ,ISNULL((SELECT IDRango						 FROM [RH].[tblRangosAntiguedad]					 WITH(NOLOCK) WHERE ((CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)) - CONVERT(CHAR(8), EMPLEADO.FechaAntiguedad, 112)) / 10000) BETWEEN [Min] AND [Max]), 0) AS IDRango
		  ,ISNULL((SELECT IDGeneracion				     FROM [RH].[tblCatGeneraciones]					     WITH(NOLOCK) WHERE (DATEPART(YEAR, EMPLEADO.FechaNacimiento)) BETWEEN [Min] AND [Max]), 0) AS IDGeneracion
		  ,ISNULL((SELECT CE.IDCliente		             FROM [RH].[tblClienteEmpleado] CE                   WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = CE.IDEmpleado  AND CE.FechaIni <= P.FechaFin  AND CE.FechaFin >= P.FechaFin),  0) AS IDCliente
		  ,ISNULL((SELECT RS.IDRazonSocial	             FROM [RH].[tblRazonSocialEmpleado] RS               WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = RS.IDEmpleado  AND RS.FechaIni <= P.FechaFin  AND RS.FechaFin >= P.FechaFin),  0) AS IDRazonSocial
		  ,ISNULL((SELECT RPE.IDRegPatronal              FROM [RH].[tblRegPatronalEmpleado] RPE              WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = RPE.IDEmpleado AND RPE.FechaIni <= P.FechaFin AND RPE.FechaFin >= P.FechaFin), 0) AS IDRegPatronal
		  ,ISNULL((SELECT CCE.IDCentroCosto              FROM [RH].[tblCentroCostoEmpleado] CCE              WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = CCE.IDEmpleado AND CCE.FechaIni <= P.FechaFin AND CCE.FechaFin >= P.FechaFin), 0) AS IDCentroCosto
		  ,ISNULL((SELECT DE.IDDepartamento              FROM [RH].[tblDepartamentoEmpleado] DE              WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = DE.IDEmpleado  AND DE.FechaIni <= P.FechaFin  AND DE.FechaFin >= P.FechaFin),  0) AS IDDepartamento
		  ,ISNULL((SELECT AE.IDArea			             FROM [RH].[tblAreaEmpleado] AE                      WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = AE.IDEmpleado  AND AE.FechaIni <= P.FechaFin  AND AE.FechaFin >= P.FechaFin),  0) AS IDArea
		  ,ISNULL((SELECT PE.IDPuesto		             FROM [RH].[tblPuestoEmpleado] PE                    WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = PE.IDEmpleado  AND PE.FechaIni <= P.FechaFin  AND PE.FechaFin >= P.FechaFin),  0) AS IDPuesto
		  ,ISNULL((SELECT PRE.IDTipoPrestacion           FROM [RH].[TblPrestacionesEmpleado] PRE             WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = PRE.IDEmpleado AND PRE.FechaIni <= P.FechaFin AND PRE.FechaFin >= P.FechaFin), 0) AS IDTipoPrestacion
		  ,ISNULL((SELECT SE.IDSucursal		             FROM [RH].[tblSucursalEmpleado] SE                  WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = SE.IDEmpleado  AND SE.FechaIni <= P.FechaFin  AND SE.FechaFin >= P.FechaFin),  0) AS IDSucursal
		  ,ISNULL((SELECT DVE.IDDivision	             FROM [RH].[tblDivisionEmpleado] DVE                 WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = DVE.IDEmpleado AND DVE.FechaIni <= P.FechaFin AND DVE.FechaFin >= P.FechaFin), 0) AS IDDivision
		  ,ISNULL((SELECT RE.IDRegion		             FROM [RH].[tblRegionEmpleado] RE                    WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = RE.IDEmpleado  AND RE.FechaIni <= P.FechaFin  AND RE.FechaFin >= P.FechaFin),  0) AS IDRegion
		  ,ISNULL((SELECT CPE.IDClasificacionCorporativa FROM [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = CPE.IDEmpleado AND CPE.FechaIni <= P.FechaFin AND CPE.FechaFin >= P.FechaFin), 0) AS IDClasificacionCorporativa
		  ,ISNULL((SELECT NEE.IDNivelEmpresarial         FROM [RH].[tblNivelesEmpresarialesEmpleado] NEE     WITH(NOLOCK) WHERE EMPLEADO.IDEmpleado = NEE.IDEmpleado AND NEE.FechaIni <= P.FechaFin AND NEE.FechaFin >= P.FechaFin), 0) AS IDNivelEmpresarial
	INTO #TblDataEvaluacion
	FROM [Evaluacion360].[tblCatProyectos] P
		-- JOINS GENERALES		
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
		LEFT JOIN [RH].[tblEmpleadosMaster] EMPLEADO ON EP.IDEmpleado = EMPLEADO.IDEmpleado
		LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto	
		LEFT JOIN [Evaluacion360].[tblCatGrupos] GRUPO ON EE.IDEvaluacionEmpleado = GRUPO.IDReferencia		
		-- JOINS PREGUNTA
		LEFT JOIN [Evaluacion360].[tblCatPreguntas] PREGUNTA ON GRUPO.IDGrupo = PREGUNTA.IDGrupo
		-- JOINS RESPUESTA
		LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] RESPUESTA ON PREGUNTA.IDPregunta = RESPUESTA.IDPregunta
		-- JOINS INDICADOR
		LEFT JOIN [Evaluacion360].[tblCatIndicadores] INDICADOR ON PREGUNTA.IDIndicador = INDICADOR.IDIndicador
	WHERE P.IDProyecto = @IDProyecto
		  AND GRUPO.IDReferencia = @IDEvaluacionEmpleado
		  AND GRUPO.TipoReferencia = @PRUEBA_FINAL
		  AND RESPUESTA.Respuesta IS NOT NULL		  
	ORDER BY PREGUNTA.IDPregunta

	
	
	-- ELIMINA DATOS QUE NO TIENEN RESPUESTA (POSTERIORMENTE LOS INSERTA)
	DELETE DatosEliminados
	FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] DatosEliminados
	WHERE DatosEliminados.IDProyecto = @IDProyecto
		  AND DatosEliminados.IDEvaluacionEmpleado = @IDEvaluacionEmpleado
		  AND NOT EXISTS (
							SELECT RP.IDPregunta 
							FROM [Evaluacion360].[tblRespuestasPreguntas] RP
							WHERE RP.IDPregunta = DatosEliminados.IDPregunta
						 )


	-- ELIMINA DATOS QUE FUERON ACTUALIZADOS EN SU RESPUESTA (POSTERIORMENTE LOS INSERTA)
	DELETE DatosActualizados
	FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] AS DatosActualizados
	WHERE DatosActualizados.IDProyecto = @IDProyecto
		  AND DatosActualizados.IDEvaluacionEmpleado = @IDEvaluacionEmpleado
		  AND DatosActualizados.IDPregunta IN (
											SELECT DE.IDPregunta 
											FROM #TblDataEvaluacion DE 
											WHERE DE.IDPregunta = DatosActualizados.IDPregunta
												  AND DE.Respuesta <> DatosActualizados.Respuesta
										   )		
	

	-- INSERTAR DATOS NUEVOS U ACTUALIZADOS
	INSERT INTO [InfoDir].[tblRespuestasNormalizadasClimaLaboral]
	SELECT DE.* 
	FROM #TblDataEvaluacion DE
	WHERE NOT EXISTS (
						SELECT RNCL.IDPregunta 
						FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] RNCL 
						WHERE RNCL.IDProyecto = DE.IDProyecto
							  AND RNCL.IDEvaluacionEmpleado = DE.IDEvaluacionEmpleado
							  AND RNCL.IDPregunta = DE.IDPregunta
					 )
	
END
GO

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
--select * from Evaluacion360.tblCatProyectos
CREATE PROCEDURE [InfoDir].[spSincronizarEvaluacionesClimaLaboral_V1](
	@IDProyecto			  INT,
	@IDEvaluacionEmpleado INT = NULL
)
AS
BEGIN	
	if OBJECT_ID('tempdb..#TblDataEvaluacion') is not null drop table #TblDataEvaluacion;

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
		  --,ISNULL(EMPLEADO.Sexo, '') AS Genero
		  ,g.IDGenero
		  ,(CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)) - CONVERT(CHAR(8), EMPLEADO.FechaAntiguedad, 112)) / 10000 AS Antiguedad
		  ,ISNULL((SELECT IDRango						 FROM [RH].[tblRangosAntiguedad]					 WITH(NOLOCK) WHERE ((CONVERT(INT, CONVERT(CHAR(8), GETDATE(), 112)) - CONVERT(CHAR(8), EMPLEADO.FechaAntiguedad, 112)) / 10000) BETWEEN [Min] AND [Max]), 0) AS IDRango
		  ,ISNULL((SELECT IDGeneracion				     FROM [RH].[tblCatGeneraciones]					     WITH(NOLOCK) WHERE (DATEPART(YEAR, EMPLEADO.FechaNacimiento)) BETWEEN [Min] AND [Max]), 0) AS IDGeneracion
		  ,ISNULL((SELECT CE.IDCliente		             FROM [RH].[tblClienteEmpleado] CE                   WITH(NOLOCK) WHERE EE.IDEvaluador = CE.IDEmpleado  AND CE.FechaIni <= P.FechaFin  AND CE.FechaFin >= P.FechaFin),  0) AS IDCliente
		  ,ISNULL((SELECT RS.IDEmpresa					 FROM [RH].[tblEmpresaEmpleado] RS					 WITH(NOLOCK) WHERE EE.IDEvaluador = RS.IDEmpleado  AND RS.FechaIni <= P.FechaFin  AND RS.FechaFin >= P.FechaFin),  0) AS IDRazonSocial
		  ,ISNULL((SELECT RPE.IDRegPatronal              FROM [RH].[tblRegPatronalEmpleado] RPE              WITH(NOLOCK) WHERE EE.IDEvaluador = RPE.IDEmpleado AND RPE.FechaIni <= P.FechaFin AND RPE.FechaFin >= P.FechaFin), 0) AS IDRegPatronal
		  ,ISNULL((SELECT CCE.IDCentroCosto              FROM [RH].[tblCentroCostoEmpleado] CCE              WITH(NOLOCK) WHERE EE.IDEvaluador = CCE.IDEmpleado AND CCE.FechaIni <= P.FechaFin AND CCE.FechaFin >= P.FechaFin), 0) AS IDCentroCosto
		  ,ISNULL((SELECT DE.IDDepartamento              FROM [RH].[tblDepartamentoEmpleado] DE              WITH(NOLOCK) WHERE EE.IDEvaluador = DE.IDEmpleado  AND DE.FechaIni <= P.FechaFin  AND DE.FechaFin >= P.FechaFin),  0) AS IDDepartamento
		  ,ISNULL((SELECT AE.IDArea			             FROM [RH].[tblAreaEmpleado] AE                      WITH(NOLOCK) WHERE EE.IDEvaluador = AE.IDEmpleado  AND AE.FechaIni <= P.FechaFin  AND AE.FechaFin >= P.FechaFin),  0) AS IDArea
		  ,ISNULL((SELECT PE.IDPuesto		             FROM [RH].[tblPuestoEmpleado] PE                    WITH(NOLOCK) WHERE EE.IDEvaluador = PE.IDEmpleado  AND PE.FechaIni <= P.FechaFin  AND PE.FechaFin >= P.FechaFin),  0) AS IDPuesto
		  ,ISNULL((SELECT PRE.IDTipoPrestacion           FROM [RH].[TblPrestacionesEmpleado] PRE             WITH(NOLOCK) WHERE EE.IDEvaluador = PRE.IDEmpleado AND PRE.FechaIni <= P.FechaFin AND PRE.FechaFin >= P.FechaFin), 0) AS IDTipoPrestacion
		  ,ISNULL((SELECT SE.IDSucursal		             FROM [RH].[tblSucursalEmpleado] SE                  WITH(NOLOCK) WHERE EE.IDEvaluador = SE.IDEmpleado  AND SE.FechaIni <= P.FechaFin  AND SE.FechaFin >= P.FechaFin),  0) AS IDSucursal
		  ,ISNULL((SELECT DVE.IDDivision	             FROM [RH].[tblDivisionEmpleado] DVE                 WITH(NOLOCK) WHERE EE.IDEvaluador = DVE.IDEmpleado AND DVE.FechaIni <= P.FechaFin AND DVE.FechaFin >= P.FechaFin), 0) AS IDDivision
		  ,ISNULL((SELECT RE.IDRegion		             FROM [RH].[tblRegionEmpleado] RE                    WITH(NOLOCK) WHERE EE.IDEvaluador = RE.IDEmpleado  AND RE.FechaIni <= P.FechaFin  AND RE.FechaFin >= P.FechaFin),  0) AS IDRegion
		  ,ISNULL((SELECT CPE.IDClasificacionCorporativa FROM [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK) WHERE EE.IDEvaluador = CPE.IDEmpleado AND CPE.FechaIni <= P.FechaFin AND CPE.FechaFin >= P.FechaFin), 0) AS IDClasificacionCorporativa
		  ,ISNULL((SELECT NEE.IDNivelEmpresarial         FROM [RH].[tblNivelesEmpresarialesEmpleado] NEE     WITH(NOLOCK) WHERE EE.IDEvaluador = NEE.IDEmpleado AND NEE.FechaIni <= P.FechaFin AND NEE.FechaFin >= P.FechaFin), 0) AS IDNivelEmpresarial
	INTO #TblDataEvaluacion
	FROM [Evaluacion360].[tblCatProyectos] P
		-- JOINS GENERALES		
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
	--	LEFT JOIN [RH].[tblEmpleadosMaster] EMPLEADO ON EP.IDEmpleado = EMPLEADO.IDEmpleado
		LEFT JOIN [RH].[tblEmpleados] EMPLEADO ON EP.IDEmpleado = EMPLEADO.IDEmpleado
		LEFT JOIN RH.tblCatGeneros g on g.IDGenero = EMPLEADO.Sexo
		LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto	
		LEFT JOIN [Evaluacion360].[tblCatGrupos] GRUPO ON EE.IDEvaluacionEmpleado = GRUPO.IDReferencia AND GRUPO.TipoReferencia = @PRUEBA_FINAL	 	
		-- JOINS PREGUNTA
		LEFT JOIN [Evaluacion360].[tblCatPreguntas] PREGUNTA ON GRUPO.IDGrupo = PREGUNTA.IDGrupo
		-- JOINS RESPUESTA
		LEFT JOIN [Evaluacion360].[tblRespuestasPreguntas] RESPUESTA ON PREGUNTA.IDPregunta = RESPUESTA.IDPregunta
		-- JOINS INDICADOR
		LEFT JOIN [Evaluacion360].[tblCatIndicadores] INDICADOR ON PREGUNTA.IDIndicador = INDICADOR.IDIndicador
	WHERE P.IDProyecto = @IDProyecto
		  AND (EE.IDEvaluacionEmpleado = @IDEvaluacionEmpleado or isnull(@IDEvaluacionEmpleado, 0) = 0)
		  AND RESPUESTA.Respuesta IS NOT NULL		  
	ORDER BY PREGUNTA.IDPregunta

	RAISERROR ('Delete' , 0, 1) WITH NOWAIT	
	delete [TARGET]
	from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] [TARGET]
		left join #TblDataEvaluacion [SOURCE] on
				[TARGET].IDProyecto				= [SOURCE].IDProyecto                   
			and [TARGET].IDGrupo				= [SOURCE].IDGrupo                  
			and [TARGET].IDEvaluacionEmpleado	= [SOURCE].IDEvaluacionEmpleado                  
			and [TARGET].IDPregunta				= [SOURCE].IDPregunta                  
	where [TARGET].IDProyecto = @IDProyecto and [SOURCE].IDPregunta is null 
		and ([TARGET].IDEvaluacionEmpleado = @IDEvaluacionEmpleado or isnull(@IDEvaluacionEmpleado, 0) = 0)
	
	RAISERROR ('update' , 0, 1) WITH NOWAIT
	update [TARGET]
		set 
			[TARGET].FechaNormalizacion			=  [SOURCE].FechaNormalizacion
			,[TARGET].IDProyecto				=  [SOURCE].IDProyecto
			,[TARGET].IDGrupo					=  [SOURCE].IDGrupo
			,[TARGET].IDTipoPreguntaGrupo		=  [SOURCE].IDTipoPreguntaGrupo
			,[TARGET].IDTipoGrupo				=  [SOURCE].IDTipoGrupo
			,[TARGET].IDEvaluacionEmpleado		=  [SOURCE].IDEvaluacionEmpleado
			,[TARGET].IDEmpleado				=  [SOURCE].IDEmpleado
			,[TARGET].FechaNacimiento			=  [SOURCE].FechaNacimiento
			,[TARGET].TotalPreguntas			=  [SOURCE].TotalPreguntas
			,[TARGET].MaximaCalificacionPosible	=  [SOURCE].MaximaCalificacionPosible
			,[TARGET].CalificacionObtenida		=  [SOURCE].CalificacionObtenida
			,[TARGET].CalificacionMinimaObtenida	=  [SOURCE].CalificacionMinimaObtenida
			,[TARGET].CalificacionMaxinaObtenida	=  [SOURCE].CalificacionMaxinaObtenida
			,[TARGET].Promedio					=  [SOURCE].Promedio
			,[TARGET].Porcentaje				=  [SOURCE].Porcentaje
			,[TARGET].IDPregunta				=  [SOURCE].IDPregunta
			,[TARGET].Respuesta					=  [SOURCE].Respuesta
			,[TARGET].ValorFinal				=  [SOURCE].ValorFinal
			,[TARGET].IDIndicador				=  [SOURCE].IDIndicador
			,[TARGET].IDGenero					=  [SOURCE].IDGenero
			,[TARGET].Antiguedad				=  [SOURCE].Antiguedad
			,[TARGET].IDRango					=  [SOURCE].IDRango
			,[TARGET].IDGeneracion				=  [SOURCE].IDGeneracion
			,[TARGET].IDCliente					=  [SOURCE].IDCliente
			,[TARGET].IDRazonSocial				=  [SOURCE].IDRazonSocial
			,[TARGET].IDRegPatronal				=  [SOURCE].IDRegPatronal
			,[TARGET].IDCentroCosto				=  [SOURCE].IDCentroCosto
			,[TARGET].IDDepartamento			=  [SOURCE].IDDepartamento
			,[TARGET].IDArea					=  [SOURCE].IDArea
			,[TARGET].IDPuesto					=  [SOURCE].IDPuesto
			,[TARGET].IDTipoPrestacion			=  [SOURCE].IDTipoPrestacion
			,[TARGET].IDSucursal				=  [SOURCE].IDSucursal
			,[TARGET].IDDivision				=  [SOURCE].IDDivision
			,[TARGET].IDRegion					=  [SOURCE].IDRegion
			,[TARGET].IDClasificacionCorporativa=  [SOURCE].IDClasificacionCorporativa
			,[TARGET].IDNivelEmpresarial		=  [SOURCE].IDNivelEmpresarial
	from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] [TARGET]
		left join #TblDataEvaluacion [SOURCE] on
				[TARGET].IDProyecto				= [SOURCE].IDProyecto                   
			and [TARGET].IDGrupo				= [SOURCE].IDGrupo                  
			and [TARGET].IDEvaluacionEmpleado	= [SOURCE].IDEvaluacionEmpleado                  
			and [TARGET].IDPregunta				= [SOURCE].IDPregunta  
	where [TARGET].IDProyecto = @IDProyecto and ([TARGET].IDEvaluacionEmpleado = @IDEvaluacionEmpleado or isnull(@IDEvaluacionEmpleado, 0) = 0)
	
	RAISERROR ('Insert' , 0, 1) WITH NOWAIT
	INSERT [InfoDir].[tblRespuestasNormalizadasClimaLaboral](
		FechaNormalizacion
		,IDProyecto
		,IDGrupo
		,IDTipoGrupo
		,IDTipoPreguntaGrupo
		,IDEvaluacionEmpleado
		,IDEmpleado
		,FechaNacimiento
		,TotalPreguntas
		,MaximaCalificacionPosible
		,CalificacionObtenida
		,CalificacionMinimaObtenida
		,CalificacionMaxinaObtenida
		,Promedio
		,Porcentaje
		,IDPregunta
		,Respuesta
		,ValorFinal
		,IDIndicador
		,IDGenero
		,Antiguedad
		,IDRango
		,IDGeneracion
		,IDCliente
		,IDRazonSocial
		,IDRegPatronal
		,IDCentroCosto
		,IDDepartamento
		,IDArea
		,IDPuesto
		,IDTipoPrestacion
		,IDSucursal
		,IDDivision
		,IDRegion
		,IDClasificacionCorporativa
		,IDNivelEmpresarial
	)            
	select
		[TARGET].FechaNormalizacion				 /*FechaNormalizacion*/
		,[TARGET].IDProyecto					 /*,IDProyecto*/
		,[TARGET].IDGrupo						 /*,IDGrupo*/
		,[TARGET].IDTipoGrupo					 /*,IDTipoGrupo*/
		,[TARGET].IDTipoPreguntaGrupo			 /*,IDTipoPreguntaGrupo*/
		,[TARGET].IDEvaluacionEmpleado			 /*,IDEvaluacionEmpleado*/
		,[TARGET].IDEmpleado					 /*,IDEmpleado*/
		,[TARGET].FechaNacimiento				 /*,FechaNacimiento*/
		,[TARGET].TotalPreguntas				 /*,TotalPreguntas*/
		,[TARGET].MaximaCalificacionPosible		 /*,MaximaCalificacionPosible*/
		,[TARGET].CalificacionObtenida			 /*,CalificacionObtenida*/
		,[TARGET].CalificacionMinimaObtenida	 /*,CalificacionMinimaObtenida*/
		,[TARGET].CalificacionMaxinaObtenida	 /*,CalificacionMaxinaObtenida*/
		,[TARGET].Promedio						 /*,Promedio*/
		,[TARGET].Porcentaje					 /*,Porcentaje*/
		,[TARGET].IDPregunta					 /*,IDPregunta*/
		,[TARGET].Respuesta						 /*,Respuesta*/
		,[TARGET].ValorFinal					 /*,ValorFinal*/
		,[TARGET].IDIndicador					 /*,IDIndicador*/
		,[TARGET].IDGenero						 /*,IDGenero*/
		,[TARGET].Antiguedad					 /*,Antiguedad*/
		,[TARGET].IDRango						 /*,IDRango*/
		,[TARGET].IDGeneracion					 /*,IDGeneracion*/
		,[TARGET].IDCliente						 /*,IDCliente*/
		,[TARGET].IDRazonSocial					 /*,IDRazonSocial*/
		,[TARGET].IDRegPatronal					 /*,IDRegPatronal*/
		,[TARGET].IDCentroCosto					 /*,IDCentroCosto*/
		,[TARGET].IDDepartamento				 /*,IDDepartamento*/
		,[TARGET].IDArea						 /*,IDArea*/
		,[TARGET].IDPuesto						 /*,IDPuesto*/
		,[TARGET].IDTipoPrestacion				 /*,IDTipoPrestacion*/
		,[TARGET].IDSucursal					 /*,IDSucursal*/
		,[TARGET].IDDivision					 /*,IDDivision*/
		,[TARGET].IDRegion						 /*,IDRegion*/
		,[TARGET].IDClasificacionCorporativa	 /*,IDClasificacionCorporativa*/
		,[TARGET].IDNivelEmpresarial			 /*,IDNivelEmpresarial*/
	from #TblDataEvaluacion [TARGET]
		left join [InfoDir].[tblRespuestasNormalizadasClimaLaboral] [SOURCE] on
				[TARGET].IDProyecto				= [SOURCE].IDProyecto                   
			and [TARGET].IDGrupo				= [SOURCE].IDGrupo                  
			and [TARGET].IDEvaluacionEmpleado	= [SOURCE].IDEvaluacionEmpleado                  
			and [TARGET].IDPregunta				= [SOURCE].IDPregunta                  
	where [TARGET].IDProyecto = @IDProyecto and [SOURCE].IDPregunta is null 
		and ([TARGET].IDEvaluacionEmpleado = @IDEvaluacionEmpleado or isnull(@IDEvaluacionEmpleado, 0) = 0)
	

--	select * from #TblDataEvaluacion
	
----exec tempdb.sys.sp_help #TblDataEvaluacion;

--	return
	
--	-- ELIMINA DATOS QUE NO TIENEN RESPUESTA (POSTERIORMENTE LOS INSERTA)
--	DELETE DatosEliminados
--	FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] DatosEliminados
--	WHERE DatosEliminados.IDProyecto = @IDProyecto
--		  AND DatosEliminados.IDEvaluacionEmpleado = @IDEvaluacionEmpleado
--		  AND NOT EXISTS (
--							SELECT RP.IDPregunta 
--							FROM [Evaluacion360].[tblRespuestasPreguntas] RP
--							WHERE RP.IDPregunta = DatosEliminados.IDPregunta
--						 )


--	-- ELIMINA DATOS QUE FUERON ACTUALIZADOS EN SU RESPUESTA (POSTERIORMENTE LOS INSERTA)
--	DELETE DatosActualizados
--	FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] AS DatosActualizados
--	WHERE DatosActualizados.IDProyecto = @IDProyecto
--		  AND DatosActualizados.IDEvaluacionEmpleado = @IDEvaluacionEmpleado
--		  AND DatosActualizados.IDPregunta IN (
--											SELECT DE.IDPregunta 
--											FROM #TblDataEvaluacion DE 
--											WHERE DE.IDPregunta = DatosActualizados.IDPregunta
--												  AND DE.Respuesta <> DatosActualizados.Respuesta
--										   )		
	

--	-- INSERTAR DATOS NUEVOS U ACTUALIZADOS
--	INSERT INTO [InfoDir].[tblRespuestasNormalizadasClimaLaboral]
--	SELECT DE.* 
--	FROM #TblDataEvaluacion DE
--	WHERE NOT EXISTS (
--						SELECT RNCL.IDPregunta 
--						FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] RNCL 
--						WHERE RNCL.IDProyecto = DE.IDProyecto
--							  AND RNCL.IDEvaluacionEmpleado = DE.IDEvaluacionEmpleado
--							  AND RNCL.IDPregunta = DE.IDPregunta
--					 )
	
END
GO

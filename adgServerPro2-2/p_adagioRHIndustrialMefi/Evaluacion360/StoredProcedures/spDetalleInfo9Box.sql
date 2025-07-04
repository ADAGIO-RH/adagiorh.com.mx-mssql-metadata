USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene de un proyecto el detalle de los grupos.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-03-12
** Paremetros		: @IDProyecto		Identificador del proyecto.
**					: @JsonFiltros		Contiene la lista de catalogos e identificadores para filtrar la información.
**					: @IDUsuario		Identificador del usuario.
** IDAzure			: 830

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spDetalleInfo9Box](
	@IDProyecto					INT	
	, @JsonFiltros				NVARCHAR(MAX)
	, @IDUsuario				INT
)
AS
	BEGIN
	
		-- VARIABLES
		DECLARE	@PRUEBA_FINAL			INT = 4
				, @ESCALA_DE_LA_PRUEBA	INT = 2
				, @ESCALA_INDIVIDUAL	INT = 3
				, @FUNCION_CLAVE		INT = 5
				, @QuerySelect			NVARCHAR(MAX) = ''
				, @QueryFrom			NVARCHAR(MAX) = ''
				, @QueryWhere			NVARCHAR(MAX) = ''
				, @IDIdioma				VARCHAR(20)
				;
		
		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		-- TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#tempFiltros') IS NOT NULL DROP TABLE #tempFiltros;		

		
		-- CONVERTIMOS FILTROS A TABLA		
		;WITH tblFiltros(catalogo, [value])
		AS
		(
			SELECT *
			FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$'))
			  WITH (
				catalogo NVARCHAR(50) '$.Catalogo',
				valor NVARCHAR(MAX) '$.Value'
			  )
		)
		SELECT * 
		INTO #tempFiltros
		FROM tblFiltros;		
		
		-- ELIMINAMOS FILTROS CON VALOR NULL O VACIO
		DELETE #tempFiltros
		WHERE [value] IS NULL 
				OR [value] = '';
		--SELECT * FROM #tempFiltros;


		-- OBTENEMOS GRUPOS
		SET @QuerySelect = N'
							SELECT P.IDProyecto
									, EMPLEADO.ClaveEmpleado
									, SUBSTRING (EMPLEADO.Nombre, 1, 1) + SUBSTRING (EMPLEADO.Paterno, 1, 1) AS Iniciales
									, EMPLEADO.NOMBRECOMPLETO AS Evaluado
									, EV.ClaveEmpleado + '' - '' + EV.NOMBRECOMPLETO AS Evaluador
									, EE.IDTipoRelacion
									, TIPO_RELACION.Relacion
									, ISNULL(EE.IDTipoEvaluacion, 0) AS IDTipoEvaluacion
									, ISNULL(JSON_VALUE(TIPO_EVALUACION.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''' + LOWER(REPLACE('''+ @IDIdioma +''', ''-'', '''')) + '''', ''Nombre'')), '''') AS TipoEvaluacion
									, GRUPO.IDGrupo
									, GRUPO.Nombre
									, CASE
										WHEN GRUPO.IDTipoPreguntaGrupo IN (' + CAST(@ESCALA_INDIVIDUAL AS VARCHAR(1)) + ')
											THEN (SELECT Min(V1.Valor) FROM Evaluacion360.tblEscalasValoracionesGrupos V1 WHERE V1.IDGrupo = GRUPO.IDGrupo)
											ELSE (SELECT Min(V2.Valor) FROM Evaluacion360.tblEscalasValoracionesProyectos V2 WHERE V2.IDProyecto = P.IDProyecto)
										END AS EscalaViejaMin
									, CASE
										WHEN GRUPO.IDTipoPreguntaGrupo IN (' + CAST(@ESCALA_INDIVIDUAL AS VARCHAR(1)) + ')
											THEN (SELECT Max(V3.Valor) FROM Evaluacion360.tblEscalasValoracionesGrupos V3 WHERE V3.IDGrupo = GRUPO.IDGrupo)
											ELSE (SELECT Max(V4.Valor) FROM Evaluacion360.tblEscalasValoracionesProyectos V4 WHERE V4.IDProyecto = P.IDProyecto)
										END AS EscalaViejaMax
									, GRUPO.IDTipoPreguntaGrupo
									, GRUPO.IDReferencia AS IDEvaluacionEmpleado
									, EMPLEADO.IDEmpleado
									, ISNULL(GRUPO.TotalPreguntas, 0) AS TotalPreguntas
									, ISNULL(GRUPO.MaximaCalificacionPosible, 0) AS MaximaCalificacionPosible
									, ISNULL(GRUPO.CalificacionObtenida, 0) AS CalificacionObtenida									
									, ISNULL(GRUPO.Promedio, 0) AS Promedio									
									-- FILTROS
									, ISNULL(AE.IDArea, 0) AS IDArea
									, ISNULL(CCE.IDCentroCosto, 0) AS IDCentroCosto
									, ISNULL(CPE.IDClasificacionCorporativa, 0) AS IDClasificacionCorporativa
									, ISNULL(CE.IDCliente, 0) AS IDCliente
									, ISNULL(DE.IDDepartamento, 0) AS IDDepartamento
									, ISNULL(DVE.IDDivision, 0) AS IDDivision
									, ISNULL(PRE.IDTipoPrestacion, 0) AS IDTipoPrestacion
									, ISNULL(PE.IDPuesto, 0) AS IDPuesto
									, ISNULL(RS.IDRazonSocial, 0) AS IDRazonSocial
									, ISNULL(RE.IDRegion, 0) AS IDRegion
									, ISNULL(RPE.IDRegPatronal, 0) AS IDRegPatronal
									, ISNULL(SE.IDSucursal, 0) AS IDSucursal '
		SET @QueryFrom  = N'		
							FROM [Evaluacion360].[tblCatProyectos] P
								-- JOINS GENERALES	  
								LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto								
								LEFT JOIN [RH].[tblEmpleadosMaster] EMPLEADO ON EP.IDEmpleado = EMPLEADO.IDEmpleado
								LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
								LEFT JOIN [RH].[tblEmpleadosMaster] EV ON EE.IDEvaluador = EV.IDEmpleado
								LEFT JOIN [Evaluacion360].[tblCatGrupos] GRUPO ON EE.IDEvaluacionEmpleado = GRUPO.IDReferencia
								LEFT JOIN [Evaluacion360].[tblCatTiposRelaciones] TIPO_RELACION ON EE.IDTipoRelacion = TIPO_RELACION.IDTipoRelacion
								LEFT JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TIPO_EVALUACION ON EE.IDTipoEvaluacion = TIPO_EVALUACION.IDTipoEvaluacion
								-- FILTROS	
								LEFT JOIN [RH].[tblAreaEmpleado] AE ON EMPLEADO.IDEmpleado = AE.IDEmpleado AND AE.FechaIni <= P.FechaFin AND AE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblCentroCostoEmpleado] CCE ON EMPLEADO.IDEmpleado = CCE.IDEmpleado AND CCE.FechaIni <= P.FechaFin AND CCE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblClasificacionCorporativaEmpleado] CPE ON EMPLEADO.IDEmpleado = CPE.IDEmpleado AND CPE.FechaIni <= P.FechaFin AND CPE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblClienteEmpleado] CE ON EMPLEADO.IDEmpleado = CE.IDEmpleado AND CE.FechaIni <= P.FechaFin AND CE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblDepartamentoEmpleado] DE ON EMPLEADO.IDEmpleado = DE.IDEmpleado AND DE.FechaIni <= P.FechaFin AND DE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblDivisionEmpleado] DVE ON EMPLEADO.IDEmpleado = DVE.IDEmpleado AND DVE.FechaIni <= P.FechaFin AND DVE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[TblPrestacionesEmpleado] PRE ON EMPLEADO.IDEmpleado = PRE.IDEmpleado AND PRE.FechaIni <= P.FechaFin AND PRE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblPuestoEmpleado] PE ON EMPLEADO.IDEmpleado = PE.IDEmpleado AND PE.FechaIni <= P.FechaFin AND PE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblRazonSocialEmpleado] RS ON EMPLEADO.IDEmpleado = RS.IDEmpleado AND RS.FechaIni <= P.FechaFin AND RS.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblRegionEmpleado] RE ON EMPLEADO.IDEmpleado = RE.IDEmpleado AND RE.FechaIni <= P.FechaFin AND RE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblRegPatronalEmpleado] RPE ON EMPLEADO.IDEmpleado = RPE.IDEmpleado AND RPE.FechaIni <= P.FechaFin AND RPE.FechaFin >= P.FechaFin
								LEFT JOIN [RH].[tblSucursalEmpleado] SE ON EMPLEADO.IDEmpleado = SE.IDEmpleado AND SE.FechaIni <= P.FechaFin AND SE.FechaFin >= P.FechaFin '
		SET @QueryWhere = N'
							WHERE P.IDProyecto = ' + CAST(@IDProyecto AS VARCHAR(10)) + '
									AND GRUPO.TipoReferencia = ' + CAST(@PRUEBA_FINAL AS VARCHAR(1)) + '
									AND GRUPO.IDTipoPreguntaGrupo IN (' + CAST(@ESCALA_DE_LA_PRUEBA AS VARCHAR(1)) + ', ' + CAST(@ESCALA_INDIVIDUAL AS VARCHAR(1)) + ', ' + CAST(@FUNCION_CLAVE AS VARCHAR(1)) + ')
									AND EP.TipoFiltro <> ''Excluir Empleado'' ' +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Relaciones') THEN ' AND ((EE.IDTipoRelacion IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Relaciones''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Grupos') THEN ' AND ((GRUPO.Nombre IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Grupos''), '',''))))' ELSE '' END +									
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Areas') THEN ' AND ((AE.IDArea IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Areas''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'CentrosCostos') THEN ' AND ((CCE.IDCentroCosto IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''CentrosCostos''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'ClasificacionesCorporativas') THEN ' AND ((CPE.IDClasificacionCorporativa IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''ClasificacionesCorporativas''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Clientes') THEN ' AND ((CE.IDCliente IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Clientes''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Departamentos') THEN ' AND ((DE.IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Departamentos''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Divisiones') THEN ' AND ((DVE.IDDivision IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Divisiones''), '',''))))' ELSE '' END +									
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Empleados') THEN ' AND ((EMPLEADO.IDEmpleado IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Empleados''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Excluir Empleado') THEN ' AND ((EMPLEADO.IDEmpleado NOT IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Excluir Empleado''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Prestaciones') THEN ' AND ((PRE.IDTipoPrestacion IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Prestaciones''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Puestos') THEN ' AND ((PE.IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Puestos''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'RazonesSociales') THEN ' AND ((RS.IDRazonSocial IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''RazonesSociales''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Regiones') THEN ' AND ((RE.IDRegion IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Regiones''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'RegPatronales') THEN ' AND ((RPE.IDRegPatronal IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''RegPatronales''), '',''))))' ELSE '' END +
									CASE WHEN EXISTS(SELECT TOP 1 1 FROM #tempFiltros WHERE Catalogo = 'Sucursales') THEN ' AND ((SE.IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltros WHERE Catalogo = ''Sucursales''), '',''))))' ELSE '' END +									
							' ORDER BY GRUPO.IDGrupo';
		
		EXEC (@QuerySelect + @QueryFrom + @QueryWhere);
		--PRINT (@QuerySelect + @QueryFrom + @QueryWhere)		

	END
GO

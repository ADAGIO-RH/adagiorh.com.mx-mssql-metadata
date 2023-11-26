USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Obtiene el porcentaje del reporte clima laboral
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-07-13
** Paremetros		: @IDIndicador
**					: @JsonFiltros
**					: @JsonGroup
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [InfoDir].[spIndicadorClimaLaboral]
(
	@IDProyecto INT
	,@JsonFiltros NVARCHAR(MAX)
	,@JsonGroup NVARCHAR(MAX)
)
AS
	BEGIN		
		
		--DECLARE @IDProyecto INT = 136;

		SET LANGUAGE 'spanish'

		DECLARE @dtFiltros [Nomina].[dtFiltrosRH]
				,@GroupBy NVARCHAR(MAX) = ''
				,@IDLabel VARCHAR(15) = ''
				,@Label VARCHAR(250) = ''
				,@Qry NVARCHAR(MAX)
				,@Qry2 NVARCHAR(MAX)
				,@IDIdioma varchar(20)
				,@Indicador INT = 2
				,@Calificable INT = 1
				,@EscalaPrueba INT = 2
				,@Escalaindividual INT = 3
				;			

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');
		
		-- ELIMINAMOS LAS TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#TblDataSource') IS NOT NULL BEGIN DROP TABLE #TblDataSource END
		IF OBJECT_ID('tempdb..#TblFiltrosDataSource') IS NOT NULL BEGIN DROP TABLE #TblFiltrosDataSource END				
		

		-- CREAMOS TABLAS TEMPORALES
		DECLARE @TblGroupBy TABLE(
			[ID] INT IDENTITY(1,1),
			[Catalogo] VARCHAR(50)
		)		
		
		CREATE TABLE #TblDataSource (
			[FechaNormalizacion] DATE
			,[IDProyecto] INT
			,[IDGrupo] INT
			,[IDTipoGrupo] INT
			,[IDTipoPreguntaGrupo] INT
			,[IDEvaluacionEmpleado] INT
			,[IDEmpleado] INT
			,[FechaNacimiento] DATE
			,[TotalPreguntas] INT
			,[MaximaCalificacionPosible] INT
			,[CalificacionObtenida] INT
			,[CalificacionMinimaObtenida] INT
			,[CalificacionMaxinaObtenida] INT
			,[Promedio] DECIMAL(10, 2)
			,[Porcentaje] DECIMAL(10, 2)
			,[IDPregunta] INT
			,[Respuesta] VARCHAR(MAX)
			,[ValorFinal] DECIMAL(18, 2)
			,[IDIndicador] INT
			,[IDGenero] VARCHAR(50)
			,[Antiguedad] INT
			,[IDRango] INT
			,[IDGeneracion] INT 
			,[IDCliente] INT
			,[IDRazonSocial] INT
			,[IDRegPatronal] INT
			,[IDCentroCosto] INT
			,[IDDepartamento] INT
			,[IDArea] INT
			,[IDPuesto] INT
			,[IDTipoPrestacion] INT
			,[IDSucursal] INT
			,[IDDivision] INT
			,[IDRegion] INT
			,[IDClasificacionCorporativa] INT
			,[IDNivelEmpresarial] INT
			,[Empleado] VARCHAR(255)
			,[NombreIndicador] VARCHAR(255)
			,[Rango] VARCHAR(255)
			,[Generacion] VARCHAR(255)
			,[NombreComercial] VARCHAR(255)
			,[RazonSocial] VARCHAR(255)
			,[RegistroPatronal] VARCHAR(255)
			,[CentroCosto] VARCHAR(255)
			,[Departamento] VARCHAR(255)
			,[Area] VARCHAR(255)
			,[Puesto] VARCHAR(255)
			,[TipoPrestacion] VARCHAR(255)
			,[Sucursal] VARCHAR(255)
			,[Division] VARCHAR(255)
			,[Region] VARCHAR(255)
			,[ClasificacionCorporativa] VARCHAR(255)
			,[NivelEmpresarial] VARCHAR(255)
		);

		CREATE TABLE #TblFiltrosDataSource (
			[FechaNormalizacion] DATE
			,[IDProyecto] INT
			,[IDGrupo] INT
			,[IDTipoGrupo] INT
			,[IDTipoPreguntaGrupo] INT
			,[IDEvaluacionEmpleado] INT
			,[IDEmpleado] INT
			,[FechaNacimiento] DATE
			,[TotalPreguntas] INT
			,[MaximaCalificacionPosible] INT
			,[CalificacionObtenida] INT
			,[CalificacionMinimaObtenida] INT
			,[CalificacionMaxinaObtenida] INT
			,[Promedio] DECIMAL(10, 2)
			,[Porcentaje] DECIMAL(10, 2)
			,[IDPregunta] INT
			,[Respuesta] VARCHAR(MAX)
			,[ValorFinal] DECIMAL(18, 2)
			,[IDIndicador] INT
			,[IDGenero] VARCHAR(50)
			,[Antiguedad] INT
			,[IDRango] INT
			,[IDGeneracion] INT 
			,[IDCliente] INT
			,[IDRazonSocial] INT
			,[IDRegPatronal] INT
			,[IDCentroCosto] INT
			,[IDDepartamento] INT
			,[IDArea] INT
			,[IDPuesto] INT
			,[IDTipoPrestacion] INT
			,[IDSucursal] INT
			,[IDDivision] INT
			,[IDRegion] INT
			,[IDClasificacionCorporativa] INT
			,[IDNivelEmpresarial] INT
			,[Empleado] VARCHAR(255)
			,[NombreIndicador] VARCHAR(255)
			,[Rango] VARCHAR(255)
			,[Generacion] VARCHAR(255)
			,[NombreComercial] VARCHAR(255)
			,[RazonSocial] VARCHAR(255)
			,[RegistroPatronal] VARCHAR(255)
			,[CentroCosto] VARCHAR(255)
			,[Departamento] VARCHAR(255)
			,[Area] VARCHAR(255)
			,[Puesto] VARCHAR(255)
			,[TipoPrestacion] VARCHAR(255)
			,[Sucursal] VARCHAR(255)
			,[Division] VARCHAR(255)
			,[Region] VARCHAR(255)
			,[ClasificacionCorporativa] VARCHAR(255)
			,[NivelEmpresarial] VARCHAR(255)
		);


		-- OBTENEMOS FUENDE DE DATOS
		INSERT INTO #TblDataSource
		SELECT CLIMA_LABORAL.FechaNormalizacion AS Dia
			   ,CLIMA_LABORAL.IDProyecto
			   ,CLIMA_LABORAL.IDGrupo			   
			   ,CLIMA_LABORAL.IDTipoGrupo
			   ,CLIMA_LABORAL.IDTipoPreguntaGrupo
			   ,CLIMA_LABORAL.IDEvaluacionEmpleado
			   ,CLIMA_LABORAL.IDEmpleado
			   ,CLIMA_LABORAL.FechaNacimiento
			   ,CLIMA_LABORAL.TotalPreguntas
			   ,CLIMA_LABORAL.MaximaCalificacionPosible
			   ,CLIMA_LABORAL.CalificacionObtenida
			   ,CLIMA_LABORAL.CalificacionMinimaObtenida
			   ,CLIMA_LABORAL.CalificacionMaxinaObtenida
			   ,CLIMA_LABORAL.Promedio
			   ,CLIMA_LABORAL.Porcentaje
			   ,CLIMA_LABORAL.IDPregunta
			   ,CLIMA_LABORAL.Respuesta
			   ,CLIMA_LABORAL.ValorFinal
			   ,CLIMA_LABORAL.IDIndicador
			   ,CLIMA_LABORAL.IDGenero
			   ,CLIMA_LABORAL.Antiguedad
			   ,CLIMA_LABORAL.IDRango
			   ,CLIMA_LABORAL.IDGeneracion
			   ,CLIMA_LABORAL.IDCliente
			   ,CLIMA_LABORAL.IDRazonSocial
			   ,CLIMA_LABORAL.IDRegPatronal
			   ,CLIMA_LABORAL.IDCentroCosto
			   ,CLIMA_LABORAL.IDDepartamento
			   ,CLIMA_LABORAL.IDArea
			   ,CLIMA_LABORAL.IDPuesto
			   ,CLIMA_LABORAL.IDTipoPrestacion
			   ,CLIMA_LABORAL.IDSucursal
			   ,CLIMA_LABORAL.IDDivision
			   ,CLIMA_LABORAL.IDRegion
			   ,CLIMA_LABORAL.IDClasificacionCorporativa
			   ,CLIMA_LABORAL.IDNivelEmpresarial
			   ,ISNULL(EMPLEADO.NOMBRECOMPLETO, '') AS Empleado
			   ,ISNULL(INDICADOR.Nombre, '') AS NombreIndicador
			   ,ISNULL(RANGO.Descripcion, '') AS Rango
			   ,ISNULL(GENERACION.Descripcion, '') AS Generacion
			   ,ISNULL(JSON_VALUE(CLIENTE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'NombreComercial')), '') AS NombreComercial
			   ,ISNULL(EMPRESA.RFC + ' - ' + EMPRESA.NombreComercial, '') AS RazonSocial
			   ,ISNULL(REG_PATRONAL.RazonSocial, '') AS RegistroPatronal
			   ,ISNULL(CENTRO_COSTO.Descripcion, '') AS CentroCosto
			   ,ISNULL(DEPARTAMENTO.Descripcion, '') AS Departamento
			   ,ISNULL(AREA.Descripcion, '') AS  Area
			   ,ISNULL(JSON_VALUE(PUESTO.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto
			   ,ISNULL(TIPO_PRESTACION.Descripcion, '') AS TipoPrestacion
			   ,ISNULL(SUCURSAL.Descripcion, '') AS Sucursal
			   ,ISNULL(DIVISION.Descripcion, '') AS Division
			   ,ISNULL(REGION.Descripcion, '') AS Region
			   ,ISNULL(CLA_CORPORATIVA.Descripcion, '') AS ClasificacionCorporativa
			   ,ISNULL(NIVEL_EMPRESARIAL.Nombre, '') AS NivelEmpresarial
		FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral] CLIMA_LABORAL
			LEFT JOIN [RH].[tblEmpleadosMaster] EMPLEADO ON CLIMA_LABORAL.IDEmpleado = EMPLEADO.IDEmpleado
			LEFT JOIN [Evaluacion360].[tblCatIndicadores] INDICADOR ON CLIMA_LABORAL.IDIndicador = INDICADOR.IDIndicador
			LEFT JOIN [RH].[tblRangosAntiguedad] RANGO ON CLIMA_LABORAL.IDRango = RANGO.IDRango
			LEFT JOIN [RH].[tblCatGeneraciones] GENERACION ON CLIMA_LABORAL.IDGeneracion = GENERACION.IDGeneracion
			LEFT JOIN [RH].[tblCatClientes] CLIENTE ON CLIMA_LABORAL.IDCliente = CLIENTE.IDCliente
			LEFT JOIN [RH].[tblEmpresa] EMPRESA ON CLIMA_LABORAL.IDRazonSocial = EMPRESA.IdEmpresa
			LEFT JOIN [RH].[tblCatRegPatronal] REG_PATRONAL ON CLIMA_LABORAL.IDRegPatronal = REG_PATRONAL.IDRegPatronal
			LEFT JOIN [RH].[tblCatCentroCosto] CENTRO_COSTO ON CLIMA_LABORAL.IDCentroCosto = CENTRO_COSTO.IDCentroCosto
			LEFT JOIN [RH].[tblCatDepartamentos] DEPARTAMENTO ON CLIMA_LABORAL.IDDepartamento = DEPARTAMENTO.IDDepartamento 
			LEFT JOIN [RH].[tblCatArea] AREA ON CLIMA_LABORAL.IDArea = AREA.IDArea
			LEFT JOIN [RH].[tblCatPuestos] PUESTO ON CLIMA_LABORAL.IDPuesto = PUESTO.IDPuesto
			LEFT JOIN [RH].[tblCatTiposPrestaciones] TIPO_PRESTACION ON CLIMA_LABORAL.IDTipoPrestacion = TIPO_PRESTACION.IDTipoPrestacion
			LEFT JOIN [RH].[tblCatSucursales] SUCURSAL ON CLIMA_LABORAL.IDSucursal = SUCURSAL.IDSucursal 
			LEFT JOIN [RH].[tblCatDivisiones] DIVISION ON CLIMA_LABORAL.IDDivision = DIVISION.IDDivision
			LEFT JOIN [RH].[tblCatRegiones] REGION ON CLIMA_LABORAL.IDRegion = REGION.IDRegion
			LEFT JOIN [RH].[tblCatClasificacionesCorporativas] CLA_CORPORATIVA ON CLIMA_LABORAL.IDClasificacionCorporativa = CLA_CORPORATIVA.IDClasificacionCorporativa
			LEFT JOIN [RH].[tblCatNivelesEmpresariales] NIVEL_EMPRESARIAL ON CLIMA_LABORAL.IDNivelEmpresarial = NIVEL_EMPRESARIAL.IDNivelEmpresarial
				 JOIN [Evaluacion360].[tblCatPreguntas] PREGUNTA ON CLIMA_LABORAL.IDPregunta = PREGUNTA.IDPregunta
		WHERE CLIMA_LABORAL.IDProyecto = @IDProyecto
			  AND CLIMA_LABORAL.IDIndicador IS NOT NULL
			  AND PREGUNTA.Calificar = @Calificable
			  AND CLIMA_LABORAL.IDTipoPreguntaGrupo IN (@EscalaPrueba, @Escalaindividual)
		ORDER BY CLIMA_LABORAL.FechaNormalizacion			   
		
		 				
		-- CONVERTIMOS FILTROS A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );


		-- CONVERTIMOS GROUP BY A TABLA
		INSERT @TblGroupBy(Catalogo)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonGroup,  '$.GroupBy'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo'
		  );
		  

		-- OBTENEMOS LA INFORMACION FILTRADA
		INSERT INTO #TblFiltrosDataSource
		SELECT *
		FROM #TblDataSource
		WHERE
			 (
				IDProyecto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDProyecto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDProyecto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDEmpleado IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDEmpleado'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDEmpleado' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDIndicador IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDIndicador'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDIndicador' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDGenero IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDGenero'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDGenero' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				Antiguedad IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'Antiguedad'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'Antiguedad' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRango IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRango'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRango' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDGeneracion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDGeneracion'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDGeneracion' AND ISNULL(Value, '') <> '')
					)
			 ) AND			 
			 (
				IDCliente IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDCliente'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDCliente' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRazonSocial IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRazonSocial'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRazonSocial' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRegPatronal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRegPatronal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRegPatronal' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDCentroCosto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDCentroCosto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDCentroCosto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDepartamento'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDepartamento' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDArea IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDArea'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDArea' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDTipoPrestacion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDTipoPrestacion'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDTipoPrestacion' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDSucursal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDDivision IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDivision'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDivision' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDRegion IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDRegion'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDRegion' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDClasificacionCorporativa IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDClasificacionCorporativa'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDClasificacionCorporativa' AND ISNULL(Value, '') <> '')
					)
			 ) AND
			 (
				IDNivelEmpresarial IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDNivelEmpresarial'),','))
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDNivelEmpresarial' AND ISNULL(Value, '') <> '')
					)
			 )
		
		
				
		-- OBTENEMOS EL LA PROPIEDAD PRINCIPAL			
		SELECT @Label = Catalogo FROM @TblGroupBy WHERE ID = 1
		IF(@Label = '')
			BEGIN				
				SET @IDLabel = 'IDIndicador'
				SET @Label = 'NombreIndicador';
			END
		ELSE
			BEGIN
				SELECT @IDLabel = (CASE WHEN ISNULL(FI.DisplayValue, '') <> '' THEN FI.DisplayValue ELSE '' END) 
				FROM [InfoDir].[tblCatFiltrosItems] FI
				WHERE FI.DisplayMember = @Label AND FI.IDTipoItem = @Indicador;

				IF(@IDLabel = '')	
					BEGIN
						SELECT 'No existe la propiedad ' + @Label;
						RETURN 0;
					END
			END


		-- OBTENEMOS EL GROUP BY PARA APLICARLO A LA CONSULTA DINAMICA		
		SELECT @GroupBy = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), catalogo) FROM @TblGroupBy WHERE ID > 1 FOR XML PATH('')), 1, 1, '')
		IF(@GroupBy IS NULL)
			BEGIN				
				SET @GroupBy = 'IDTipoPreguntaGrupo, MaximaCalificacionPosible';
			END
		ELSE
			BEGIN 
				SET @GroupBy = @GroupBy + ', IDTipoPreguntaGrupo, MaximaCalificacionPosible';
			END
		

		-- DATOS FILTRADOS
		-- SELECT * FROM #TblFiltrosDataSource

		-- RESULTADO FINAL
		SET @Qry2 = 'WITH TblLabel (' + @IDLabel + ',' + @Label + ') AS
					 (
						SELECT ' + @IDLabel + ',
							   ' + @Label + '
						FROM #TblFiltrosDataSource
						GROUP BY ' + @IDLabel + ',' + @Label + '
					 )	
						SELECT (
							SELECT T.' + @IDLabel + ' AS IDTitle,
								   T.' + @Label + ' AS Title,
							(	
								SELECT CAST(AVG(ResultadoGroup) AS DECIMAL(18,2)) AS Resultado
								FROM (
									SELECT								
									ROUND(CAST(SUM(ValorFinal) / (COUNT(IDPregunta) * MaximaCalificacionPosible) AS FLOAT) * 100, 2) AS ResultadoGroup ' +
									(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ', ' + @GroupBy ELSE '' END) + '
									FROM #TblFiltrosDataSource AS Grupo
									WHERE T.' + @IDLabel + ' = Grupo.' + @IDLabel + ' AND T.' + @Label + ' = Grupo.' + @Label + 
									(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ' GROUP BY ' + @GroupBy ELSE '' END) + '
								) AS SubQuery
							) AS Total,
							''Green'' AS Color
							FROM TblLabel T
							GROUP BY T.' + @IDLabel + ', T.' + @Label + '
							ORDER BY T.' + @IDLabel + ', T.' + @Label + '
							FOR JSON AUTO
						) AS ResultJson
				    ';
		--SELECT @Qry2
		EXEC (@Qry2)

		
		/*
			-- CONSULTAS PARA PRUEBAS					
		
			SELECT ROUND(CAST(SUM(ValorFinal) / (COUNT(IDPregunta) * MaximaCalificacionPosible) AS FLOAT) * 100, 2) AS ResultadoGroup 
				   , Departamento
				   , SUM(ValorFinal) as sumValorFinal
				   , COUNT(IDPregunta) as COUNTIDPregunta
				   , MaximaCalificacionPosible
				   , IDTipoPreguntaGrupo
				   , MaximaCalificacionPosible           
			FROM #TblFiltrosDataSource AS Grupo           
			WHERE Departamento = 'CONTABILIDAD'
			GROUP BY Departamento, IDTipoPreguntaGrupo, MaximaCalificacionPosible         
			ORDER BY Grupo.MaximaCalificacionPosible

			SELECT ROUND(CAST(SUM(ValorFinal) / (COUNT(IDPregunta) * MaximaCalificacionPosible) AS FLOAT) * 100, 2) AS ResultadoGroup 
				   , Departamento
				   , NombreIndicador
				   , SUM(ValorFinal) as sumValorFinal
				   , COUNT(IDPregunta) as COUNTIDPregunta
				   , MaximaCalificacionPosible 
				   , IDTipoPreguntaGrupo
				   , MaximaCalificacionPosible          
			FROM #TblFiltrosDataSource AS Grupo           
			WHERE Departamento = 'CONTABILIDAD'
			GROUP BY Departamento, NombreIndicador, IDTipoPreguntaGrupo, MaximaCalificacionPosible  
			ORDER BY Grupo.MaximaCalificacionPosible, NombreIndicador

			SELECT ROUND(CAST(SUM(ValorFinal) / (COUNT(IDPregunta) * MaximaCalificacionPosible) AS FLOAT) * 100, 2) AS ResultadoGroup 
				   , Departamento
				   , NombreIndicador
				   , SUM(ValorFinal) as sumValorFinal
				   , COUNT(IDPregunta) as COUNTIDPregunta
				   , MaximaCalificacionPosible 
				   , IDTipoPreguntaGrupo
				   , MaximaCalificacionPosible          
			FROM #TblFiltrosDataSource AS Grupo           
			WHERE Departamento = 'CONTABILIDAD'
			GROUP BY Departamento, NombreIndicador, IDTipoPreguntaGrupo, MaximaCalificacionPosible  
			ORDER BY NombreIndicador, Grupo.MaximaCalificacionPosible       
		*/
		

	END
GO

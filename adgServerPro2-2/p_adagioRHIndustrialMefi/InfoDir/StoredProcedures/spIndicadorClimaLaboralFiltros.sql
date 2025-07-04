USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Obtiene la informacion solicitada de la tabla tblRespuestasNormalizadasClimaLaboral
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-07-13
** Paremetros		: @IDIndicador
**					: @JsonFiltros
**					: @TipoInformacion
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2024-11-07			Alejandro Paredes	Obtenemos el resultado en base a los IDsEmpleados que tiene asignado el usuario y que existan en la evaluación.
***************************************************************************************************/

CREATE   PROC [InfoDir].[spIndicadorClimaLaboralFiltros] (
	@IDProyecto			INT
	,@IDSucursal		INT = 0
	,@JsonFiltros		NVARCHAR(MAX)	
	,@TipoInformacion	INT = 1
	,@IDUsuario			INT
)
AS
	BEGIN
		
		SET LANGUAGE 'spanish'

		DECLARE 
			@dtFiltros						[Nomina].[dtFiltrosRH]
			,@TblDataSource					[InfoDir].[dtIndicadorClimaLaboral]
			,@IDIdioma						VARCHAR(20)
			,@TIPO_INDICADOR				INT = 1
			,@TIPO_MENSAJE					INT = 2
			,@TIPO_CUADRANTE				INT = 3
			,@ESCALA_PRUEBA					INT = 2
			,@ESCALA_INDIVIDUAL				INT = 3
			,@IMPORTANCIA_INDICADORES		INT = 6
			,@ID_TIPO_PREGUNTA_TEXTO_SIMPLE INT = 4
			,@ID_TIPO_PREGUNTA_RANKING		INT = 10
		;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');		
				
		-- TABLAS TEMPORALES
		DECLARE @TempDetalleFiltrosEmpleadosUsuarios TABLE (
			IDEmpleado INT
		);		

		-- OBTENEMOS LOS IDsEMPLEADO ASIGNADOS AL USUARIO A TRAVÉS DE LOS FILTROS GRUPOS, VERIFICANDO ADEMÁS QUE DICHOS EMPLEADOS PARTICIPEN EN EL PROYECTO DE EVALUACIÓN CORRESPONDIENTE.
		INSERT INTO @TempDetalleFiltrosEmpleadosUsuarios (IDEmpleado)
		SELECT DEFU.IDEmpleado
		FROM [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] DEFU
		WHERE DEFU.IDUsuario = @IDUsuario
				AND EXISTS (
						SELECT 1
						FROM [Evaluacion360].[tblCatProyectos] P
							JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
							JOIN [RH].[tblEmpleadosMaster] EVALUADO ON EP.IDEmpleado = EVALUADO.IDEmpleado
						WHERE P.IDProyecto = @IDProyecto
								AND EVALUADO.IDEmpleado = DEFU.IDEmpleado
					);
		--SELECT * FROM @TempDetalleFiltrosEmpleadosUsuarios

		
		-- CONVERTIMOS FILTROS A TABLA
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		-- OBTENEMOS FUENDE DE DATOS
		INSERT INTO @TblDataSource
		SELECT 
			CLIMA_LABORAL.FechaNormalizacion AS Dia
			, CLIMA_LABORAL.IDProyecto
			, CLIMA_LABORAL.IDGrupo			   
			, CLIMA_LABORAL.IDTipoGrupo
			, CLIMA_LABORAL.IDTipoPreguntaGrupo
			, CLIMA_LABORAL.IDEvaluacionEmpleado
			, CLIMA_LABORAL.IDEmpleado
			, CLIMA_LABORAL.FechaNacimiento
			, CLIMA_LABORAL.TotalPreguntas
			, CLIMA_LABORAL.MaximaCalificacionPosible
			, CLIMA_LABORAL.CalificacionObtenida
			, CLIMA_LABORAL.CalificacionMinimaObtenida
			, CLIMA_LABORAL.CalificacionMaxinaObtenida
			, CLIMA_LABORAL.Promedio
			, CLIMA_LABORAL.Porcentaje
			, CLIMA_LABORAL.IDPregunta
			, CLIMA_LABORAL.Respuesta
			, CLIMA_LABORAL.ValorFinal
			, CLIMA_LABORAL.IDIndicador
			, CLIMA_LABORAL.IDGenero
			, ISNULL(JSON_VALUE(GENEROS.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Genero
			, CLIMA_LABORAL.Antiguedad
			, CLIMA_LABORAL.IDRango
			, CLIMA_LABORAL.IDGeneracion
			, CLIMA_LABORAL.IDCliente
			, CLIMA_LABORAL.IDRazonSocial
			, CLIMA_LABORAL.IDRegPatronal
			, CLIMA_LABORAL.IDCentroCosto
			, CLIMA_LABORAL.IDDepartamento
			, CLIMA_LABORAL.IDArea
			, CLIMA_LABORAL.IDPuesto
			, CLIMA_LABORAL.IDTipoPrestacion
			, CLIMA_LABORAL.IDSucursal
			, CLIMA_LABORAL.IDDivision
			, CLIMA_LABORAL.IDRegion
			, CLIMA_LABORAL.IDClasificacionCorporativa
			, CLIMA_LABORAL.IDNivelEmpresarial
			, ISNULL(EMPLEADO.NOMBRECOMPLETO, '') AS Empleado
			, ISNULL(INDICADOR.Nombre, '')	AS NombreIndicador
			, ISNULL(RANGO.Descripcion, '')	AS Rango
			, ISNULL(GENERACION.Descripcion, '') AS Generacion
			, ISNULL(JSON_VALUE(CLIENTE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'NombreComercial')), '') AS NombreComercial
			, ISNULL(EMPRESA.RFC + ' - ' + EMPRESA.NombreComercial, '') AS RazonSocial
			, ISNULL(REG_PATRONAL.RazonSocial, '') AS RegistroPatronal
			, ISNULL(JSON_VALUE(CENTRO_COSTO.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS CentroCosto			
			, ISNULL(JSON_VALUE(DEPARTAMENTO.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') as Departamento
			, ISNULL(JSON_VALUE(AREA.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS  Area
			, ISNULL(JSON_VALUE(PUESTO.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Puesto
			, ISNULL(JSON_VALUE(TIPO_PRESTACION.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS TipoPrestacion
			, ISNULL(SUCURSAL.Descripcion, '')	AS Sucursal
			, ISNULL(JSON_VALUE(DIVISION.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '')	AS Division
			, ISNULL(JSON_VALUE(REGION.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '')	AS Region
			, ISNULL(CLA_CORPORATIVA.Descripcion, '')	AS ClasificacionCorporativa
			, ISNULL(NIVEL_EMPRESARIAL.Nombre, '')		AS NivelEmpresarial
		FROM [InfoDir].[tblRespuestasNormalizadasClimaLaboral]	CLIMA_LABORAL
				 JOIN @TempDetalleFiltrosEmpleadosUsuarios		EMPLEADOS_FILTRADOS	ON CLIMA_LABORAL.IDEmpleado = EMPLEADOS_FILTRADOS.IDEmpleado
			LEFT JOIN [RH].[tblEmpleadosMaster]					EMPLEADO			ON CLIMA_LABORAL.IDEmpleado = EMPLEADO.IDEmpleado
			LEFT JOIN [Evaluacion360].[tblCatIndicadores]		INDICADOR			ON CLIMA_LABORAL.IDIndicador = INDICADOR.IDIndicador
			LEFT JOIN [RH].[tblRangosAntiguedad]				RANGO				ON CLIMA_LABORAL.IDRango = RANGO.IDRango
			LEFT JOIN [RH].[tblCatGeneraciones]					GENERACION			ON CLIMA_LABORAL.IDGeneracion = GENERACION.IDGeneracion
			LEFT JOIN [RH].[tblCatClientes]						CLIENTE				ON CLIMA_LABORAL.IDCliente = CLIENTE.IDCliente
			LEFT JOIN [RH].[tblEmpresa]							EMPRESA				ON CLIMA_LABORAL.IDRazonSocial = EMPRESA.IdEmpresa
			LEFT JOIN [RH].[tblCatRegPatronal]					REG_PATRONAL		ON CLIMA_LABORAL.IDRegPatronal = REG_PATRONAL.IDRegPatronal
			LEFT JOIN [RH].[tblCatCentroCosto]					CENTRO_COSTO		ON CLIMA_LABORAL.IDCentroCosto = CENTRO_COSTO.IDCentroCosto
			LEFT JOIN [RH].[tblCatDepartamentos]				DEPARTAMENTO		ON CLIMA_LABORAL.IDDepartamento = DEPARTAMENTO.IDDepartamento 
			LEFT JOIN [RH].[tblCatArea]							AREA				ON CLIMA_LABORAL.IDArea = AREA.IDArea
			LEFT JOIN [RH].[tblCatPuestos]						PUESTO				ON CLIMA_LABORAL.IDPuesto = PUESTO.IDPuesto
			LEFT JOIN [RH].[tblCatTiposPrestaciones]			TIPO_PRESTACION		ON CLIMA_LABORAL.IDTipoPrestacion = TIPO_PRESTACION.IDTipoPrestacion
			LEFT JOIN [RH].[tblCatSucursales]					SUCURSAL			ON CLIMA_LABORAL.IDSucursal = SUCURSAL.IDSucursal 
			LEFT JOIN [RH].[tblCatDivisiones]					DIVISION			ON CLIMA_LABORAL.IDDivision = DIVISION.IDDivision
			LEFT JOIN [RH].[tblCatRegiones]						REGION				ON CLIMA_LABORAL.IDRegion = REGION.IDRegion
			LEFT JOIN [RH].[tblCatClasificacionesCorporativas]	CLA_CORPORATIVA		ON CLIMA_LABORAL.IDClasificacionCorporativa = CLA_CORPORATIVA.IDClasificacionCorporativa
			LEFT JOIN [RH].[tblCatNivelesEmpresariales]			NIVEL_EMPRESARIAL	ON CLIMA_LABORAL.IDNivelEmpresarial = NIVEL_EMPRESARIAL.IDNivelEmpresarial
			LEFT JOIN [RH].[tblCatGeneros]						GENEROS				ON CLIMA_LABORAL.IDGenero = GENEROS.IDGenero
				 JOIN [Evaluacion360].[tblCatPreguntas]			PREGUNTA			ON CLIMA_LABORAL.IDPregunta = PREGUNTA.IDPregunta
		WHERE CLIMA_LABORAL.IDProyecto = @IDProyecto 
				AND (CLIMA_LABORAL.IDSucursal = @IDSucursal or ISNULL(@IDSucursal, 0) = 0) 
				AND (
						(@TipoInformacion = @TIPO_INDICADOR AND PREGUNTA.Calificar = 1 AND CLIMA_LABORAL.IDTipoPreguntaGrupo IN (@ESCALA_PRUEBA, @ESCALA_INDIVIDUAL) AND ISNULL(CLIMA_LABORAL.IDIndicador, 0) > 0)
							OR
						(@TipoInformacion = @TIPO_MENSAJE AND PREGUNTA.Calificar = 0 AND CLIMA_LABORAL.IDTipoPreguntaGrupo = @IMPORTANCIA_INDICADORES AND PREGUNTA.IDTipoPregunta = @ID_TIPO_PREGUNTA_TEXTO_SIMPLE)
							OR
						(@TipoInformacion = @TIPO_CUADRANTE AND PREGUNTA.Calificar = 0 AND CLIMA_LABORAL.IDTipoPreguntaGrupo = @IMPORTANCIA_INDICADORES AND PREGUNTA.IDTipoPregunta = @ID_TIPO_PREGUNTA_RANKING)
					)
		ORDER BY CLIMA_LABORAL.FechaNormalizacion

		-- DATOS FILTRADOS
		SELECT *
		FROM @TblDataSource
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

	END
GO

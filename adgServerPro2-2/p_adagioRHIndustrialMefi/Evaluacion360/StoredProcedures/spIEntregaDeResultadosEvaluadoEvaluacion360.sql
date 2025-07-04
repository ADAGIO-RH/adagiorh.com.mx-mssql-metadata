USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta la entrega de resultados del evaluado de las evaluaciones 360.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-20
** Parametros		: @IDProyecto			Identificador del proyecto
**					: @FilesEvaluaciones	Lista de archivos
** IDAzure			: #1303

** DataTypes Relacionados:
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spIEntregaDeResultadosEvaluadoEvaluacion360](	
	@IDProyecto				INT = 0
	, @FilesEvaluaciones	[App].[dtAdgFiles] READONLY
)
AS
	BEGIN

		-- VARIABLES
		DECLARE @Link VARCHAR(MAX) = NULL;
		

		-- TABLA TEMPORAL
		DECLARE @TblArchivos AS TABLE
		(
			IDAdgFile							INT
			, [Name]							VARCHAR(MAX)
			, Extension							VARCHAR(MAX)
			, PathFile							VARCHAR(MAX)
			, RelativePath						VARCHAR(MAX)
			, DownloadURL						VARCHAR(MAX)
			, RequiereAutenticacion				BIT			
		);


		-- IDENTIFICAMOS LOS ARCHIVOS
		INSERT INTO @TblArchivos
		SELECT AF.IDAdgFile
				, AF.[Name]
				, AF.Extension
				, AF.PathFile
				, AF.RelativePath
				, AF.DownloadURL
				, AF.RequiereAutenticacion
		FROM [App].[tblAdgFiles] AF
			JOIN @FilesEvaluaciones FE ON AF.[name] = FE.[name];
		--SELECT * FROM @TblArchivos


		-- BUSCAMOS LINK BASE DE DESCARGA
		SELECT TOP 1 @Link = Valor 
		from [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
		WHERE IDConfiguracion = 'Url';
		
		
		-- RESULTADO FINAL
		INSERT INTO [Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacion360]
		SELECT	-- PROYECTO
				P.IDProyecto					
				, P.Nombre AS NombreProyecto
				, P.Descripcion AS DescripcionProyecto
				, P.FechaCreacion AS FechaCreacionProyecto
				, P.FechaInicio AS FechaInicioProyecto
				, P.FechaFin AS FechaFinProyecto
				-- ENCARGADOS PROYECTOS				
				, CASE WHEN ENP.IDCatalogoGeneral = 3 THEN COALESCE(ENP.Nombre, '') ELSE '' END NombreContactoProyecto
				, CASE WHEN ENP.IDCatalogoGeneral = 3 THEN COALESCE(ENP.Email, '') ELSE '' END EmailContactoProyecto
				-- EVALUADO
				, EM.IDEmpleado AS IDEvaluado
				, EM.ClaveEmpleado AS ClaveEvaluado
				, EM.RFC AS RFCEvaluado
				, EM.CURP AS CURPEvaluado
				, EM.IMSS AS IMSSEvaluado
				, EM.Nombre AS NombreEvaluado
				, EM.Paterno AS PaternoEvaluado
				, EM.Materno AS MaternoEvaluado
				, EM.NOMBRECOMPLETO AS NOMBRECOMPLETOEvaluado
				, EM.LocalidadNacimiento AS LocalidadNacimientoEvaluado
				, EM.MunicipioNacimiento AS MunicipioNacimientoEvaluado
				, EM.EstadoNacimiento AS EstadoNacimientoEvaluado
				, EM.PaisNacimiento AS PaisNacimientoEvaluado
				, EM.FechaNacimiento AS FechaNacimientoEvaluado
				, EM.EstadoCivil AS EstadoCivilEvaluado
				, EM.Sexo AS SexoEvaluado
				, EM.Escolaridad AS EscolaridadEvaluado
				, EM.DescripcionEscolaridad AS DescripcionEscolaridadEvaluado
				, EM.Institucion AS InstitucionEvaluado
				, EM.Probatorio AS ProbatorioEvaluado
				, EM.FechaIngreso AS FechaIngresoEvaluado
				, EM.FechaAntiguedad AS FechaAntiguedadEvaluado
				, EM.JornadaLaboral AS JornadaLaboralEvaluado
				, EM.TipoRegimen AS TipoRegimenEvaluado
				, EM.Departamento AS DepartamentoEvaluado
				, EM.Sucursal AS SucursalEvaluado
				, EM.Puesto AS PuestoEvaluado
				, EM.Cliente AS ClienteEvaluado
				, EM.Empresa AS EmpresaEvaluado
				, EM.CentroCosto AS CentroCostoEvaluado
				, EM.Area AS AreaEvaluado
				, EM.Division AS DivisionEvaluado
				, EM.Region AS RegionEvaluado
				, EM.ClasificacionCorporativa AS ClasificacionCorporativaEvaluado
				, EM.RegPatronal AS RegPatronalEvaluado
				, EM.TipoNomina AS TipoNominaEvaluado
				, EM.RazonSocial AS RazonSocialEvaluado
				, EM.Afore AS AforeEvaluado
				, EM.FechaIniContrato AS FechaIniContratoEvaluado
				, EM.FechaFinContrato AS FechaFinContratoEvaluado
				, EM.TiposPrestacion AS TiposPrestacionEvaluado
				, EM.tipoTrabajadorEmpleado AS TipoTrabajadorEmpleadoEvaluado
				-- ARCHIVOS DE RESULTADOS
				, F.IDAdgFile
				, '' + @Link + 'App/download?id=' + CAST(IDAdgFile AS VARCHAR(MAX)) + '' AS LinkDescarga
				-- EMAILS
				, Email = CASE WHEN C.Email IS NOT NULL THEN C.Email ELSE U.Email END
				, EmailValid = [Utilerias].[fsValidarEmail](CASE WHEN C.Email IS NOT NULL THEN C.Email ELSE U.Email END)
				-- ENTREGA DE RESULTADOS A COLABORADOR
				, ENVIAR_RESULTADO.Valor AS EnviarResultadoAColaborador
		FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
			JOIN @TblArchivos F ON CAST(F.[name] AS INT) = EP.IDEmpleadoProyecto
			JOIN [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK) ON P.IDProyecto = EP.IDProyecto
			LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] ENP WITH (NOLOCK) ON ENP.IDProyecto = EP.IDProyecto
			JOIN [Evaluacion360].[tblEnviarResultadosAColaboradores] ENVIAR_RESULTADO WITH (NOLOCK) ON ENVIAR_RESULTADO.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
			JOIN [RH].[tblEmpleadosMaster] EM WITH (NOLOCK) ON EM.IDEmpleado = EP.IDEmpleado			
			LEFT JOIN [Seguridad].[tblUsuarios] U WITH (NOLOCK) ON U.IDEmpleado = EM.IDEmpleado
			LEFT JOIN
			(
				SELECT CE.IDEmpleado
						, LOWER(CE.[Value]) AS Email
						, CE.Predeterminado
						, ROW_NUMBER() OVER(PARTITION BY CE.IDEmpleado ORDER BY CE.Predeterminado DESC) AS [ROW]
				FROM [RH].[tblContactoEmpleado] CE WITH (NOLOCK)
					JOIN [RH].[tblCatTipoContactoEmpleado] CTCE WITH (NOLOCK) ON CTCE.IDTipoContacto = CE.IDTipoContactoEmpleado AND CTCE.IDMedioNotificacion = 'email'
				WHERE CE.[Value] IS NOT NULL
			) C ON C.IDEmpleado = EM.IDEmpleado AND C.[ROW] = 1
		WHERE P.IDProyecto = @IDProyecto
				AND EP.PDFGenerado = 1
				AND NOT EXISTS(SELECT T2.[IDAdgFile] FROM [Evaluacion360].[tblEntregaDeResultadosEvaluadoEvaluacion360] T2 WHERE T2.[IDAdgFile] = F.[IDAdgFile])
		ORDER BY F.IDAdgFile, EM.NOMBRECOMPLETO

		
	END
GO

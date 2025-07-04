USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta los recordatorios de las evaluaciones de desempeño pendientes.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-12
** Parametros		: @IsGeneral				Indicador que determina si la solicitud se origina desde una tarea o como parte de la contestación a una evaluación.
**					: @IDProyecto				Identificador del proyecto
**					: @IDEvaluacionEmpleado		Identificador de la evaluación
**					: @IDEvaluador				Identificador del evaluador
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #1286

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spIRecordatoriosEvaluacionDesempeno](
	@IsGeneral				INT = 0
	, @IDProyecto			INT = 0
	, @IDEvaluacionEmpleado	INT = 0
	, @IDEvaluador			INT = 0	
	, @IDUsuario			INT = 0
)
AS
	BEGIN

		-- VARIABLES
		DECLARE @ListaPersonasPorEvaluar_ESMX	VARCHAR(MAX) = NULL
				, @ListaPersonasPorEvaluar_ENUS	VARCHAR(MAX) = NULL
				, @NO							BIT = 0
				, @SI							BIT = 1
				;
				

		-- OBTENEMOS EL IDEvaluador
		IF(@IsGeneral = @NO)
			BEGIN
				SELECT @IDEvaluador = IDEvaluador
				FROM [Evaluacion360].[tblEvaluacionesEmpleados]
				WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado;
			END	


		-- OBTENEMOS LA LISTA DE COLABORADORES PENDIENTES POR EVALUAR EN ESPAÑOL
		SELECT @ListaPersonasPorEvaluar_ESMX = (
			'<ul class=''leaders''>' + 
			(
				SELECT TOP 3
					'<li><b>' + ISNULL(JSON_VALUE(TR.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Relacion')), '') + ' - ' + ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Nombre')), '') + ':</b> ' + E.ClaveEmpleado + ' - ' + E.NOMBRECOMPLETO + '</li>'
				FROM [Evaluacion360].[tblCatProyectos] P
					JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
					JOIN [RH].[tblEmpleadosMaster] E ON EP.IDEmpleado = E.IDEmpleado
					JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
					JOIN [Evaluacion360].[tblCatTiposRelaciones] TR ON EE.IDTipoRelacion = TR.IDTipoRelacion
					JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TE ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion
					LEFT JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
				WHERE P.IDProyecto = @IDProyecto
						AND EE.IDEvaluador = @IDEvaluador						
						AND G.IDGrupo IS NULL
						AND (
							  @IsGeneral = @SI
							  OR (@IsGeneral <> @SI AND (EE.IDEvaluacionEmpleado <> @IDEvaluacionEmpleado))
							)
				ORDER BY TR.IDTipoRelacion
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') + '</ul>'
		);
		-- SELECT @ListaEvaluacionesPendientes_ESMX

		-- OBTENEMOS LA LISTA DE COLABORADORES PENDIENTES POR EVALUAR EN INGLES
		SELECT @ListaPersonasPorEvaluar_ENUS = (
			'<ul class=''leaders''>' + 
			(
				SELECT TOP 3
					'<li><b>' + ISNULL(JSON_VALUE(TR.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('enus', '-', '')) + '', 'Relacion')), '') + ' - ' + ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Nombre')), '') + ':</b> ' + E.ClaveEmpleado + ' - ' + E.NOMBRECOMPLETO + '</li>'
				FROM [Evaluacion360].[tblCatProyectos] P
					JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
					JOIN [RH].[tblEmpleadosMaster] E ON EP.IDEmpleado = E.IDEmpleado
					JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
					JOIN [Evaluacion360].[tblCatTiposRelaciones] TR ON EE.IDTipoRelacion = TR.IDTipoRelacion
					JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TE ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion
					LEFT JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
				WHERE P.IDProyecto = @IDProyecto
						AND EE.IDEvaluador = @IDEvaluador						
						AND G.IDGrupo IS NULL
						AND (
							  @IsGeneral = @SI
							  OR (@IsGeneral <> @SI AND (EE.IDEvaluacionEmpleado <> @IDEvaluacionEmpleado))
							)
				ORDER BY TR.IDTipoRelacion
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') + '</ul>'
		);
		-- SELECT @ListaEvaluacionesPendientes_ENUS

		

		IF(@ListaPersonasPorEvaluar_ESMX IS NOT NULL AND @ListaPersonasPorEvaluar_ENUS IS NOT NULL)
			BEGIN
			
				-- CREAR RECORDATORIOS NUEVOS
				INSERT INTO [Evaluacion360].[tblRecordatoriosEvaluacionDesempeno]
				SELECT -- PROYECTO
					  P.IDProyecto
					, @IDEvaluacionEmpleado AS IDEvaluacionEmpleado
					, P.Nombre AS NombreProyecto
					, P.Descripcion AS DescripcionProyecto
					, P.FechaCreacion AS FechaCreacionProyecto
					, P.FechaInicio AS FechaInicioProyecto
					, P.FechaFin AS FechaFinProyecto
					-- ENCARGADOS PROYECTOS				
					, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Nombre, '') ELSE '' END NombreContactoProyecto
					, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Email, '') ELSE '' END EmailContactoProyecto
					-- TIPO DE EVALUACIONES
					, ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Nombre')), 'GENERAL') AS TipoEvaluacion
					-- EVALUADOR
					, EM1.IDEmpleado AS IDEvaluador
					, EM1.ClaveEmpleado AS ClaveEvaluador
					, EM1.RFC AS RFCEvaluador
					, EM1.CURP AS CURPEvaluador
					, EM1.IMSS AS IMSSEvaluador
					, EM1.Nombre AS NombreEvaluador
					, EM1.Paterno AS PaternoEvaluador
					, EM1.Materno AS MaternoEvaluador
					, EM1.NOMBRECOMPLETO AS NOMBRECOMPLETOEvaluador
					, EM1.LocalidadNacimiento AS LocalidadNacimientoEvaluador
					, EM1.MunicipioNacimiento AS MunicipioNacimientoEvaluador
					, EM1.EstadoNacimiento AS EstadoNacimientoEvaluador
					, EM1.PaisNacimiento AS PaisNacimientoEvaluador
					, EM1.FechaNacimiento AS FechaNacimientoEvaluador
					, EM1.EstadoCivil AS EstadoCivilEvaluador
					, EM1.Sexo AS SexoEvaluador
					, EM1.Escolaridad AS EscolaridadEvaluador
					, EM1.DescripcionEscolaridad AS DescripcionEscolaridadEvaluador
					, EM1.Institucion AS InstitucionEvaluador
					, EM1.Probatorio AS ProbatorioEvaluador
					, EM1.FechaIngreso AS FechaIngresoEvaluador
					, EM1.FechaAntiguedad AS FechaAntiguedadEvaluador
					, EM1.JornadaLaboral AS JornadaLaboralEvaluador
					, EM1.TipoRegimen AS TipoRegimenEvaluador
					, EM1.Departamento AS DepartamentoEvaluador
					, EM1.Sucursal AS SucursalEvaluador
					, EM1.Puesto AS PuestoEvaluador
					, EM1.Cliente AS ClienteEvaluador
					, EM1.Empresa AS EmpresaEvaluador
					, EM1.CentroCosto AS CentroCostoEvaluador
					, EM1.Area AS AreaEvaluador
					, EM1.Division AS DivisionEvaluador
					, EM1.Region AS RegionEvaluador
					, EM1.ClasificacionCorporativa AS ClasificacionCorporativaEvaluador
					, EM1.RegPatronal AS RegPatronalEvaluador
					, EM1.TipoNomina AS TipoNominaEvaluador
					, EM1.RazonSocial AS RazonSocialEvaluador
					, EM1.Afore AS AforeEvaluador
					, EM1.FechaIniContrato AS FechaIniContratoEvaluador
					, EM1.FechaFinContrato AS FechaFinContratoEvaluador
					, EM1.TiposPrestacion AS TiposPrestacionEvaluador
					, EM1.tipoTrabajadorEmpleado AS TipoTrabajadorEmpleadoEvaluador
					-- PENDIENTES POR EVALUAR
					, '{"esmx": {"ValorDinamico": "' + REPLACE(REPLACE(@ListaPersonasPorEvaluar_ESMX, '"', '\"'), '''', '\"')  + '"},"enus": {"ValorDinamico": "' + REPLACE(REPLACE(@ListaPersonasPorEvaluar_ENUS, '"', '\"'), '''', '\"') + '"}}' AS ListaPersonasPorEvaluar
				FROM [Evaluacion360].[tblCatProyectos] P			
					LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EP WITH (NOLOCK) ON EP.IDProyecto = @IDProyecto
					LEFT JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EE.IDEvaluacionEmpleado = @IDEvaluacionEmpleado
					LEFT JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TE ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion
					LEFT JOIN [RH].[tblEmpleadosMaster] EM1 WITH (NOLOCK) ON EM1.IDEmpleado = @IDEvaluador
				WHERE P.IDProyecto = @IDProyecto

			END		


	END
GO

USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta los recordatorios de las evaluaciones de clima laboral pendientes.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-12-12
** Parametros		: @IDProyecto				Identificador del proyecto
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

CREATE   PROC [Evaluacion360].[spIRecordatoriosEvaluacionClimaLaboral](	
	@IDProyecto		INT = 0	
	, @IDEvaluador	INT = 0	
	, @IDUsuario	INT = 0
)
AS
	BEGIN

		-- VERIFICAMOS SI EL COLABORADOR TIENE EVALUACIONES PENDIENTES
		IF EXISTS (
			SELECT TOP 1 1			
			FROM [Evaluacion360].[tblCatProyectos] P
				JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON P.IDProyecto = EP.IDProyecto
				JOIN [RH].[tblEmpleadosMaster] E ON EP.IDEmpleado = E.IDEmpleado
				JOIN [Evaluacion360].[tblEvaluacionesEmpleados] EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto					
				LEFT JOIN [Evaluacion360].[tblCatGrupos] G ON EE.IDEvaluacionEmpleado = G.IDReferencia
			WHERE P.IDProyecto = @IDProyecto
					AND EE.IDEvaluador = @IDEvaluador					
					AND G.IDGrupo IS NULL					
		)
			BEGIN
			
				-- CREAR RECORDATORIOS NUEVOS
				INSERT INTO [Evaluacion360].[tblRecordatoriosEvaluacionClimaLaboral]
				SELECT -- PROYECTO
					  P.IDProyecto
					, 0 AS IDEvaluacionEmpleado
					, P.Nombre AS NombreProyecto
					, P.Descripcion AS DescripcionProyecto
					, P.FechaCreacion AS FechaCreacionProyecto
					, P.FechaInicio AS FechaInicioProyecto
					, P.FechaFin AS FechaFinProyecto
					-- ENCARGADOS PROYECTOS				
					, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Nombre, '') ELSE '' END NombreContactoProyecto
					, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Email, '') ELSE '' END EmailContactoProyecto					
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
				FROM [Evaluacion360].[tblCatProyectos] P
					LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EP WITH (NOLOCK) ON EP.IDProyecto = @IDProyecto
					LEFT JOIN [RH].[tblEmpleadosMaster] EM1 WITH (NOLOCK) ON EM1.IDEmpleado = @IDEvaluador
				WHERE P.IDProyecto = @IDProyecto

			END		


	END
GO

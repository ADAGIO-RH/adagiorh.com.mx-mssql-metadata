USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	
CREATE   VIEW [Evaluacion360].[vwDatosEvaluacion] 
	AS 

		SELECT -- PROYECTO
			   EE.IDEvaluacionEmpleado
			   , P.Nombre AS NombreProyecto
			   , P.Descripcion AS DescripcionProyecto
			   , P.FechaCreacion AS FechaCreacionProyecto
			   , P.FechaInicio AS FechaInicioProyecto
			   , P.FechaFin AS FechaFinProyecto
			   -- ENCARGADOS PROYECTOS				
			   , CASE WHEN EPR.IDCatalogoGeneral = 3 THEN COALESCE(EPR.Nombre, '') ELSE '' END NombreContactoProyecto
			   , CASE WHEN EPR.IDCatalogoGeneral = 3 THEN COALESCE(EPR.Email, '') ELSE '' END EmailContactoProyecto
			   -- TIPO DE EVALUACIONES
			   , ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Nombre')), 'GENERAL') AS TipoEvaluacion
			   -- EVALUADOR
			   , EE.IDEvaluador AS IDEvaluador
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
			   -- EVALUADO
			   , EP.IDEmpleado AS IDEvaluado
			   , EM2.ClaveEmpleado AS ClaveEvaluado
			   , EM2.RFC AS RFCEvaluado
			   , EM2.CURP AS CURPEvaluado
			   , EM2.IMSS AS IMSSEvaluado
			   , EM2.Nombre AS NombreEvaluado
			   , EM2.Paterno AS PaternoEvaluado
			   , EM2.Materno AS MaternoEvaluado
			   , EM2.NOMBRECOMPLETO AS NOMBRECOMPLETOEvaluado
			   , EM2.LocalidadNacimiento AS LocalidadNacimientoEvaluado
			   , EM2.MunicipioNacimiento AS MunicipioNacimientoEvaluado
			   , EM2.EstadoNacimiento AS EstadoNacimientoEvaluado
			   , EM2.PaisNacimiento AS PaisNacimientoEvaluado
			   , EM2.FechaNacimiento AS FechaNacimientoEvaluado
			   , EM2.EstadoCivil AS EstadoCivilEvaluado
			   , EM2.Sexo AS SexoEvaluado
			   , EM2.Escolaridad AS EscolaridadEvaluado
			   , EM2.DescripcionEscolaridad AS DescripcionEscolaridadEvaluado
			   , EM2.Institucion AS InstitucionEvaluado
			   , EM2.Probatorio AS ProbatorioEvaluado
			   , EM2.FechaIngreso AS FechaIngresoEvaluado
			   , EM2.FechaAntiguedad AS FechaAntiguedadEvaluado
			   , EM2.JornadaLaboral AS JornadaLaboralEvaluado
			   , EM2.TipoRegimen AS TipoRegimenEvaluado
			   , EM2.Departamento AS DepartamentoEvaluado
			   , EM2.Sucursal AS SucursalEvaluado
			   , EM2.Puesto AS PuestoEvaluado
			   , EM2.Cliente AS ClienteEvaluado
			   , EM2.Empresa AS EmpresaEvaluado
			   , EM2.CentroCosto AS CentroCostoEvaluado
			   , EM2.Area AS AreaEvaluado
			   , EM2.Division AS DivisionEvaluado
			   , EM2.Region AS RegionEvaluado
			   , EM2.ClasificacionCorporativa AS ClasificacionCorporativaEvaluado
			   , EM2.RegPatronal AS RegPatronalEvaluado
			   , EM2.TipoNomina AS TipoNominaEvaluado
			   , EM2.RazonSocial AS RazonSocialEvaluado
			   , EM2.Afore AS AforeEvaluado
			   , EM2.FechaIniContrato AS FechaIniContratoEvaluado
			   , EM2.FechaFinContrato AS FechaFinContratoEvaluado
			   , EM2.TiposPrestacion AS TiposPrestacionEvaluado
			   , EM2.tipoTrabajadorEmpleado AS TipoTrabajadorEmpleadoEvaluado
		FROM (
				SELECT T1.IDEvaluacionEmpleado
						, T1.IDEvaluador
						, T1.IDEmpleadoProyecto
						, T1.IDTipoEvaluacion
				FROM [Evaluacion360].[tblEvaluacionesEmpleados] T1
					LEFT JOIN [Evaluacion360].[tblEstatusEvaluacionEmpleado] T2 ON T1.IDEvaluacionEmpleado = T2.IDEvaluacionEmpleado
				WHERE T1.IDEvaluador = T1.IDEvaluador 
						  AND T2.IDEstatus IN (11, 12) -- (11- EVALUADOR ASIGNADO / 12- EN PROCESO)
						  --AND T1.IDEvaluacionEmpleado = 67039
				GROUP BY T1.IDEvaluacionEmpleado, T1.IDEvaluador, T1.IDEmpleadoProyecto, T1.IDTipoEvaluacion
			 ) EE
			JOIN [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
			JOIN [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK) ON EP.IDProyecto = P.IDProyecto
			LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EPR WITH (NOLOCK) ON P.IDProyecto = EPR.IDProyecto
			LEFT JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TE ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion 
			LEFT JOIN [RH].[tblEmpleadosMaster] EM1 WITH (NOLOCK) ON EE.IDEvaluador = EM1.IDEmpleado
			LEFT JOIN [RH].[tblEmpleadosMaster] EM2 WITH (NOLOCK) ON EP.IDEmpleado = EM2.IDEmpleado

			



		/****************************************************************** OLD ******************************************************************/
		/*
			SELECT -- PROYECTO
				   EE.IDEvaluacionEmpleado
				   , P.Nombre AS NombreProyecto
				   , P.Descripcion AS DescripcionProyecto
				   , P.FechaCreacion AS FechaCreacionProyecto
				   , P.FechaInicio AS FechaInicioProyecto
				   , P.FechaFin AS FechaFinProyecto
				   -- ENCARGADOS PROYECTOS				
				   , CASE WHEN EPR.IDCatalogoGeneral = 3 THEN COALESCE(EPR.Nombre, '') ELSE '' END NombreContactoProyecto
				   , CASE WHEN EPR.IDCatalogoGeneral = 3 THEN COALESCE(EPR.Email, '') ELSE '' END EmailContactoProyecto
				   -- TIPO DE EVALUACIONES
				   , ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Nombre')), 'GENERAL') AS TipoEvaluacion
				   -- EVALUADOR
				   , EE.IDEvaluador AS IDEvaluador
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
				   -- EVALUADO
				   , EP.IDEmpleado AS IDEvaluado
				   , EM2.ClaveEmpleado AS ClaveEvaluado
				   , EM2.RFC AS RFCEvaluado
				   , EM2.CURP AS CURPEvaluado
				   , EM2.IMSS AS IMSSEvaluado
				   , EM2.Nombre AS NombreEvaluado
				   , EM2.Paterno AS PaternoEvaluado
				   , EM2.Materno AS MaternoEvaluado
				   , EM2.NOMBRECOMPLETO AS NOMBRECOMPLETOEvaluado
				   , EM2.LocalidadNacimiento AS LocalidadNacimientoEvaluado
				   , EM2.MunicipioNacimiento AS MunicipioNacimientoEvaluado
				   , EM2.EstadoNacimiento AS EstadoNacimientoEvaluado
				   , EM2.PaisNacimiento AS PaisNacimientoEvaluado
				   , EM2.FechaNacimiento AS FechaNacimientoEvaluado
				   , EM2.EstadoCivil AS EstadoCivilEvaluado
				   , EM2.Sexo AS SexoEvaluado
				   , EM2.Escolaridad AS EscolaridadEvaluado
				   , EM2.DescripcionEscolaridad AS DescripcionEscolaridadEvaluado
				   , EM2.Institucion AS InstitucionEvaluado
				   , EM2.Probatorio AS ProbatorioEvaluado
				   , EM2.FechaIngreso AS FechaIngresoEvaluado
				   , EM2.FechaAntiguedad AS FechaAntiguedadEvaluado
				   , EM2.JornadaLaboral AS JornadaLaboralEvaluado
				   , EM2.TipoRegimen AS TipoRegimenEvaluado
				   , EM2.Departamento AS DepartamentoEvaluado
				   , EM2.Sucursal AS SucursalEvaluado
				   , EM2.Puesto AS PuestoEvaluado
				   , EM2.Cliente AS ClienteEvaluado
				   , EM2.Empresa AS EmpresaEvaluado
				   , EM2.CentroCosto AS CentroCostoEvaluado
				   , EM2.Area AS AreaEvaluado
				   , EM2.Division AS DivisionEvaluado
				   , EM2.Region AS RegionEvaluado
				   , EM2.ClasificacionCorporativa AS ClasificacionCorporativaEvaluado
				   , EM2.RegPatronal AS RegPatronalEvaluado
				   , EM2.TipoNomina AS TipoNominaEvaluado
				   , EM2.RazonSocial AS RazonSocialEvaluado
				   , EM2.Afore AS AforeEvaluado
				   , EM2.FechaIniContrato AS FechaIniContratoEvaluado
				   , EM2.FechaFinContrato AS FechaFinContratoEvaluado
				   , EM2.TiposPrestacion AS TiposPrestacionEvaluado
				   , EM2.tipoTrabajadorEmpleado AS TipoTrabajadorEmpleadoEvaluado
			FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE
				JOIN [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
				JOIN [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK) ON EP.IDProyecto = P.IDProyecto
				LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EPR WITH (NOLOCK) ON P.IDProyecto = EPR.IDProyecto
				LEFT JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TE ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion 
				LEFT JOIN [RH].[tblEmpleadosMaster] EM1 WITH (NOLOCK) ON EE.IDEvaluador = EM1.IDEmpleado
				LEFT JOIN [RH].[tblEmpleadosMaster] EM2 WITH (NOLOCK) ON EP.IDEmpleado = EM2.IDEmpleado
				LEFT JOIN [Evaluacion360].[tblEstatusEvaluacionEmpleado] EEE on EE.IDEvaluacionEmpleado = EEE.IDEvaluacionEmpleado			
			WHERE EE.IDEvaluador = EE.IDEvaluador 
				  AND EEE.IDEstatus IN (11, 12)
				  --AND EE.IDEvaluacionEmpleado = 67039
		*/
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Concentra la información de empleados master
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-10-31
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   VIEW [Comunicacion].[vwDatosEmpleadosMaster]
	AS 
		SELECT EM.IDEmpleado
				, EM.ClaveEmpleado
				, EM.RFC
				, EM.CURP
				, EM.IMSS
				, EM.Nombre
				, EM.SegundoNombre
				, EM.Paterno
				, EM.Materno
				, EM.NOMBRECOMPLETO
				, EM.LocalidadNacimiento
				, EM.MunicipioNacimiento
				, EM.EstadoNacimiento
				, EM.PaisNacimiento
				, EM.FechaNacimiento
				, EM.EstadoCivil
				, EM.Sexo
				, EM.Escolaridad
				, EM.DescripcionEscolaridad
				, EM.Institucion
				, EM.Probatorio
				, EM.FechaPrimerIngreso
				, EM.FechaIngreso
				, EM.FechaAntiguedad
				, EM.Sindicalizado
				, EM.JornadaLaboral
				, EM.UMF
				, EM.CuentaContable
				, EM.Departamento
				, EM.Sucursal
				, EM.Puesto
				, EM.Cliente
				, EM.Empresa
				, EM.CentroCosto
				, EM.Area
				, EM.Division
				, EM.Region
				, EM.ClasificacionCorporativa
				, EM.RegPatronal
				, EM.SalarioDiario	
				, EM.SalarioDiarioReal
				, EM.SalarioIntegrado
				, EM.SalarioVariable
				, EM.Afore
				, EM.TipoNomina	
				, SE.TipoSangre
		FROM [RH].[tblEmpleadosMaster] EM
			LEFT JOIN [RH].[tblSaludEmpleado] SE ON EM.IDEmpleado = SE.IDEmpleado
GO

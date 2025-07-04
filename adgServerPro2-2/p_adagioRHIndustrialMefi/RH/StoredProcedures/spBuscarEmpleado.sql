USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpleado] --'ADG0001'
(
	@ClaveEmpleado VArchar(20)
)
AS
BEGIN
	declare @IDEmpleado int
	
	set @IDEmpleado = (Select IDEmpleado from RH.tblEmpleados where ClaveEmpleado = @ClaveEmpleado)
	IF(@IDEmpleado IS NOT NULL)
	BEGIN
		--/////////////////////////////////////////////////////////////////////
		--	Tabla Empleado y relaciones directas
		--/////////////////////////////////////////////////////////////////////

		SELECT 
			E.IDEmpleado
			,E.ClaveEmpleado
			,E.RFC
			,E.CURP
			,E.IMSS
			,E.Nombre
			,E.SegundoNombre
			,E.Paterno
			,E.Materno
			,ISNULL(E.IDMunicipioNacimiento,0) AS IDMunicipioNacimiento
			,'['+M.Codigo+'] '+M.Descripcion AS MunicipioNacimiento
			,ISNULL(E.IDEstadoNacimiento,0) AS IDEstadoNacimiento
			,'['+Est.Codigo+'] '+Est.NombreEstado AS EstadoNacimiento
			,ISNULL(E.IDPaisNacimiento,0) AS IDPaisNacimiento
			,'['+P.Codigo+'] '+P.Descripcion AS EstadoNacimiento
			,E.FechaNacimiento
			,ISNULL(E.IDEstadoCivil,0) AS IDEstadoCivil
			,'['+EC.Codigo+'] '+EC.Descripcion AS EstadoNacimiento
			,E.Sexo
			,ISNULL(E.IDEscolaridad,0) AS IDEscolaridad
			,'['+ES.Codigo+'] '+ES.Descripcion AS EstadoNacimiento
			,E.DescripcionEscolaridad
			,E.FechaPrimerIngreso
			,E.FechaIngreso
			,E.FechaAntiguedad
			,Cast(ISNULL(E.Sindicalizado,0) as Bit) AS Sindicalizado
			,ISNULL(E.IDJornadaLaboral,0) as IDJornadaLaboral
			,'['+TJ.Codigo+'] '+TJ.Descripcion AS JornadaLaboral
			,E.UMF
			,E.CuentaContable
			,E.IDPreferencia
			,E.Password
		From RH.tblEmpleados E
			Left Join Sat.tblCatMunicipios M on E.IDMunicipioNacimiento = M.IDMunicipio
			Left Join Sat.tblCatEstados Est on Est.IDEstado = E.IDEstadoNacimiento
			Left Join sat.tblCatPaises P on E.IDPaisNacimiento = P.IDPais
			Left Join RH.tblCatEstadosCiviles EC on E.IDEstadoCivil = EC.IDEstadoCivil	
			Left Join STPS.tblCatEstudios ES on E.IDEscolaridad = ES.IDEstudio
			Left Join Sat.tblCatTiposJornada TJ on E.IDJornadaLaboral = TJ.IDTipoJornada
		Where E.IDEmpleado = @IDEmpleado

		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarAreaEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarAreaEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarClienteEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarClienteEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarContactoEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarContactoEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarContratoEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarContratoEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarDepartamentoEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarDepartamentoEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarDireccionEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarDireccionEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarEmpresaEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarEmpresaEmpleado] @IDEmpleado		
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarJornadaEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarJornadaEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarPuestoEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarPuestoEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarRegPatronalEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarRegPatronalEmpleado] @IDEmpleado
		--/////////////////////////////////////////////////////////////////////
		--	Procedure [RH].[spBuscarSucursalEmpleado]
		--/////////////////////////////////////////////////////////////////////
			Exec [RH].[spBuscarSucursalEmpleado] @IDEmpleado
	END
END
GO

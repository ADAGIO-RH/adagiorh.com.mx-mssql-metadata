USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIEmpleadosImportacionUpdate]  
(  
	@IDEmpleado int  
	,@IDCliente int  
	,@IDTipoNomina int  
	,@ClaveEmpleado Varchar(50)  
	,@RFC Varchar(50)  
	,@CURP Varchar(50)  
	,@IMSS Varchar(50)  
	,@Nombre Varchar(50)  
	,@SegundoNombre Varchar(50)  
	,@Paterno Varchar(50)  
	,@Materno Varchar(50)  
	,@IDMunicipioNacimiento int  
	,@IDEstadoNacimiento int  
	,@IDPaisNacimiento int  
	,@FechaNacimiento Date  
	,@IDEstadoCivil int  
	,@Sexo varchar(20)  
	,@FechaPrimerIngreso date  
	,@FechaIngreso date  
	,@FechaAntiguedad date  
	,@IDJornadaLaboral int  
	,@IDDepartamento int  
	,@IDSucursal int  
	,@IDPuesto int  
	,@IDEmpresa int  
	,@IDRegPatronal int  
	,@IDLayoutPago int  
	,@IDBanco int  
	,@NoCuenta Varchar(50)  
	,@Interbancaria Varchar(50)  
	,@NoTarjeta  Varchar(50)  
	,@IDBancario Varchar(50)  
	,@SucursalBanco Varchar(50)  
	,@SalarioDiario Decimal(18,2)  
	,@SalarioDiarioReal Decimal(18,2)  
	,@SalarioIntegrado Decimal(18,2)  
	,@SalarioVariable Decimal(18,2)  
	,@IDTipoPrestacion int  
	,@CorreoElectronico varchar(255)
)  
AS  
BEGIN  
	select  
		@IDEmpleado as IDEmpleado  
		,@IDCliente as IDCliente  
		,@IDTipoNomina as IDTipoNomina  
		,@ClaveEmpleado as [ClaveEmpleado]  
		,@RFC as [RFC]   
		,@CURP as [CURP]  
		,@IMSS as [IMSS]   
		,@Nombre as [Nombre]   
		,@SegundoNombre as [SegundoNombre]  
		,@Paterno as [Paterno]   
		,@Materno as [Materno]   
		,@IDMunicipioNacimiento as [IDMunicipioNacimiento]  
		,(Select TOP 1 Descripcion from SAT.tblCatMunicipios Where IDMunicipio = @IDMunicipioNacimiento) as [MunicipioNacimiento]  
		,@IDEstadoNacimiento as [IDEstadoNacimiento]  
		,(Select TOP 1 NombreEstado from SAT.tblCatEstados Where IDEstado = @IDEstadoNacimiento) as [EstadoNacimiento]  
		,@IDPaisNacimiento as [IDPaisNacimiento]  
		,(Select TOP 1 Descripcion from SAT.tblCatPaises Where IDPais = @IDPaisNacimiento) as [PaisNacimiento]  
		,cast(@FechaNacimiento as DATE) as [FechaNacimiento]  
		,@IDEstadoCivil as [IDEstadoCivil]  
		,(Select TOP 1 Descripcion from RH.tblCatEstadosCiviles Where IDEstadoCivil = @IDEstadoCivil)as [EstadoCivil]   
		,@Sexo as [Sexo]   
		,cast(@FechaPrimerIngreso AS DATE) as [FechaPrimerIngreso]  
		,cast(@FechaIngreso as DATE ) as [FechaIngreso]  
		,cast(@FechaAntiguedad as DATE) as [FechaAntiguedad]  
		,@IDJornadaLaboral as [IDJornadaLaboral]  
		,isnull((Select TOP 1 Descripcion from SAT.tblCatTiposJornada Where IDTipoJornada = @IDJornadaLaboral ),'') as [JornadaLaboral]  
		,@IDDepartamento as [IDDepartamento]  
		,(Select TOP 1 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))from RH.tblCatDepartamentos Where IDDepartamento = @IDDepartamento) as [Departamento]  
		,@IDSucursal as [IDSucursal]  
		,(Select TOP 1  Descripcion from RH.TblCatSucursales Where IDSucursal = @IDSucursal) as [Sucursal]  
  
		,@IDPuesto as [IDPuesto]  
		,(Select TOP 1 Descripcion from RH.tblCatPuestos Where IDPuesto = @IDPuesto) as [Puesto]  
  
		,@IDEmpresa as [IDEmpresa]  
		,(Select TOP 1 NombreComercial  from RH.tblEmpresa Where IdEmpresa = @IDEmpresa) as [Empresa]  
		,@IDRegPatronal as [IDRegPatronal]   
		,(Select TOP 1 RazonSocial from RH.tblCatRegPatronal Where IDRegPatronal = @IDRegPatronal) as [RegPatronal]  
		,@IDLayoutPago as [IDLayoutPago]   
		,(Select TOP 1 Descripcion from Nomina.tblLayoutPago Where IDLayoutPago = @IDLayoutPago) as [LayoutPago]   
		,@IDBanco as [IDBanco]   
		,(Select TOP 1 Descripcion from Sat.tblCatBancos Where IDBanco = @IDBanco) as [Banco]   
		,@NoCuenta as [NoCuenta]   
		,@Interbancaria as [Interbancaria]  
		,@NoTarjeta as [NoTarjeta]   
		,@IDBancario as [IDBancario]  
		,@SucursalBanco as [SucursalBanco]   
		,@SalarioDiario as [SalarioDiario]   
		,@SalarioDiarioReal as [SalarioDiarioReal]   
		,@SalarioIntegrado as [SalarioIntegrado]  
		,@SalarioVariable as [SalarioVariable]   
		,@IDTipoPrestacion as [IDTipoPrestacion]   
		,(Select TOP 1 JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) from RH.tblCatTiposPrestaciones Where IDTipoPrestacion = @IDTipoPrestacion) as [TipoPrestacion]  
		,@CorreoElectronico as CorreoElectronico
END
GO

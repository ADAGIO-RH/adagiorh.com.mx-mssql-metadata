USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUImportacionEmpleados]  
(  
	@IDCliente int,  
	@IDTipoNomina int,  
	@dtEmpleados [RH].[dtEmpleadosImportacion] READONLY  
)  
AS  
BEGIN   
	select 
		ROW_NUMBER()over(Order by RFC ASC) as IDEmpleado  
		,@IDCliente as IDCliente  
		,@IDTipoNomina as IDTipoNomina  
		,E.[ClaveEmpleado]  
		,E.[RFC]   
		,E.[CURP]  
		,E.[IMSS]   
		,E.[Nombre]   
		,E.[SegundoNombre]  
		,E.[Paterno]   
		,E.[Materno]   
		,isnull((Select TOP 1 IDMunicipio from SAT.tblCatMunicipios Where Descripcion like '%'+E.[MunicipioNacimiento] +'%'),0) as [IDMunicipioNacimiento]  
		,E.[MunicipioNacimiento]   
		,isnull((Select TOP 1 IDEstado from SAT.tblCatEstados Where NombreEstado like '%'+E.[EstadoNacimiento] +'%'),0) as [IDEstadoNacimiento]  
		,E.[EstadoNacimiento]   
		,isnull((Select TOP 1 IDPais from SAT.tblCatPaises Where Descripcion like '%'+E.[PaisNacimiento] +'%'),0) as [IDPaisNacimiento]  
		,E.[PaisNacimiento]  
		,cast(isnull(E.[FechaNacimiento],'9999-12-31') as DATE) as [FechaNacimiento]  
		,isnull((Select TOP 1 IDEstadoCivil from RH.tblCatEstadosCiviles Where Descripcion like '%'+E.[EstadoCivil] +'%'),0) as [IDEstadoCivil]  
		,E.[EstadoCivil]   
		,E.[Sexo]   
		,cast(E.[FechaPrimerIngreso] AS DATE) as [FechaPrimerIngreso]  
		,cast(E.[FechaIngreso] as DATE ) as [FechaIngreso]  
		,cast(E.[FechaAntiguedad] as DATE) as [FechaAntiguedad]  
		,isnull((Select TOP 1 IDTipoJornada from SAT.tblCatTiposJornada Where Descripcion like '%'+E.[JornadaLaboral] +'%'),0) as [IDJornadaLaboral]  
		,E.[JornadaLaboral]   
		,isnull((Select TOP 1 IDDepartamento from RH.tblCatDepartamentos Where Descripcion like '%'+E.[Departamento] +'%'),0) as [IDDepartamento]  
		,E.[Departamento]   
		,isnull((Select TOP 1 IDSucursal from RH.TblCatSucursales Where Descripcion like '%'+E.[Sucursal] +'%'),0) as [IDSucursal]  
		,E.[Sucursal]  
		,isnull((Select TOP 1 IDPuesto from RH.tblCatPuestos Where Descripcion like '%'+E.[Puesto] +'%'),0) as [IDPuesto]  
		,E.[Puesto]   
		,isnull((Select TOP 1 IdEmpresa from RH.tblEmpresa Where NombreComercial like '%'+E.[Empresa] +'%'),0) as [IDEmpresa]  
		,E.[Empresa]  
		,isnull((Select TOP 1 IDRegPatronal from RH.tblCatRegPatronal Where RegistroPatronal like '%'+E.[RegPatronal] +'%'),0) as [IDRegPatronal]   
		,E.[RegPatronal]  
		,isnull((Select TOP 1 IDLayoutPago from Nomina.tblLayoutPago Where Descripcion like '%'+E.[LayoutPago]  +'%'),0) as [IDLayoutPago]   
		,E.[LayoutPago]   
		,isnull((Select TOP 1 IDBanco from Sat.tblCatBancos Where Descripcion like '%'+E.[Banco] +'%'),0) as [IDBanco]   
		,E.[Banco]   
		,E.[NoCuenta]   
		,E.[Interbancaria]  
		,E.[NoTarjeta]   
		,E.[IDBancario]  
		,E.[SucursalBanco]   
		,E.[SalarioDiario]   
		,E.[SalarioDiarioReal]   
		,E.[SalarioIntegrado]  
		,E.[SalarioVariable]   
		,isnull((Select TOP 1 IDTipoPrestacion from RH.tblCatTiposPrestaciones Where Codigo like '%'+E.[TipoPrestacion] +'%'),0) as [IDTipoPrestacion]   
		,E.[TipoPrestacion]  
		,E.[CorreoElectronico]
	from @dtEmpleados E  
	WHERE isnull(E.Nombre,'') <>''   
  
 --select 1  
END
GO

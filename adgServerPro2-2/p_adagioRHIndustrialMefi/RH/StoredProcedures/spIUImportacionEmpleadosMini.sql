USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUImportacionEmpleadosMini]  
(  
	@IDCliente int,  
	@IDTipoNomina int,  
	@dtEmpleados [RH].[dtEmpleadosImportacionMini] READONLY  
)  
AS  
BEGIN   
	select 
		ROW_NUMBER()over(Order by [ClaveEmpleado] ASC) as IDEmpleado  
		,@IDCliente as IDCliente  
		,@IDTipoNomina as IDTipoNomina  
		,E.[ClaveEmpleado]  
		,E.[Nombre]   
		,E.[SegundoNombre]  
		,E.[Paterno]   
		,E.[Materno]   
		,cast(isnull(E.[FechaNacimiento],'9999-12-31') as DATE) as [FechaNacimiento]  
		,E.[Sexo]   
		,cast(E.[FechaIngreso] as DATE ) as [FechaIngreso]  
		,isnull((Select TOP 1 IDDepartamento from RH.tblCatDepartamentos Where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion'))  like '%'+E.[Departamento] +'%'),0) as [IDDepartamento]  
		,Departamento = case when isnull((Select TOP 1 IDDepartamento from RH.tblCatDepartamentos with(nolock) Where Descripcion like '%'+E.[Departamento] +'%'),0) > 0 then isnull((Select TOP 1 Descripcion from RH.tblCatDepartamentos with(nolock) Where Descripcion like '%'+E.[Departamento] +'%'),0) else E.[Departamento] end  
		,isnull((Select TOP 1 IDSucursal from RH.TblCatSucursales Where Descripcion like '%'+E.[Sucursal] +'%'),0) as [IDSucursal]  
		,Sucursal = case when isnull((Select TOP 1 IDSucursal from RH.TblCatSucursales with(nolock) Where Descripcion like '%'+E.[Sucursal] +'%'),0) > 0 then isnull((Select TOP 1 Descripcion from RH.TblCatSucursales with(nolock) Where Descripcion like '%'+E.[Sucursal] +'%'),0) else E.[Sucursal] end
		,isnull((Select TOP 1 IDPuesto from RH.tblCatPuestos Where Descripcion like '%'+E.[Puesto] +'%'),0) as [IDPuesto]  
		,Puesto = case when isnull((Select TOP 1 IDPuesto from RH.tblCatPuestos with(nolock) Where Descripcion like '%'+E.[Puesto] +'%'),0) > 0 then isnull((Select TOP 1 Descripcion from RH.tblCatPuestos with(nolock) Where Descripcion like '%'+E.[Puesto] +'%'),0) else E.[Puesto] end
		,isnull((Select TOP 1 IdEmpresa from RH.tblEmpresa Where NombreComercial like '%'+E.[Empresa] +'%'),0) as [IDEmpresa]  
		,Empresa = case when isnull((Select TOP 1 IdEmpresa from RH.tblEmpresa with(nolock) Where NombreComercial like '%'+E.[Empresa] +'%'),0) > 0 then isnull((Select TOP 1 NombreComercial from RH.tblEmpresa with(nolock) Where NombreComercial like '%'+E.[Empresa] +'%'),0) else E.[Empresa]  end
		,E.[CorreoElectronico]
	from @dtEmpleados E  
	WHERE isnull(E.Nombre,'') <>''   
  
 --select 1  
END
GO

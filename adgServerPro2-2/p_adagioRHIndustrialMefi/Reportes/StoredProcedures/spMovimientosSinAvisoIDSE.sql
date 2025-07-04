USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Reportes.spMovimientosSinAvisoIDSE
(
 @IDRegPatronal int,
 @FechaIni date = '1900-01-01',                  
 @Fechafin date = '9999-12-31',                                
 @dtDepartamentos varchar(max)='',
 @dtSucursales varchar(max)='',
 @dtPuestos varchar(max)='',
 @dtDivisiones varchar(max)='',
 @dtClasificacionCorporativas varchar(max)='',
 @IDUsuario int = 0
)
AS
BEGIN


 Declare @dtFiltros [Nomina].[dtFiltrosRH] 

 insert into @dtFiltros(Catalogo,Value)  
 values('Departamentos',@dtDepartamentos)  
  
 insert into @dtFiltros(Catalogo,Value)  
 values('Sucursales',@dtSucursales)  
   
 insert into @dtFiltros(Catalogo,Value)  
 values('Puestos',@dtPuestos)  
  
 insert into @dtFiltros(Catalogo,Value)  
 values('Divisiones',@dtDivisiones)   

  insert into @dtFiltros(Catalogo,Value)  
 values('ClasificacionesCorporativas',@dtClasificacionCorporativas)   

	
	SELECT EmpleadosMaster.IDEmpleado,
		   EmpleadosMaster.ClaveEmpleado,
		   EmpleadosMaster.NOMBRECOMPLETO,
		   EmpleadosMaster.Departamento,
		   EmpleadosMaster.Puesto,
		   EmpleadosMaster.Sucursal,

		   Tmov.Codigo CodigoMovimiento,
		   Tmov.Descripcion Movimiento,
		   Mov.Fecha,
		   RMov.Codigo CodigoRazon,
		   RMov.Descripcion Razon,
		   Mov.FechaIDSE

	 from IMSS.tblMovAfiliatorios Mov
		inner join IMSS.tblCatTipoMovimientos TMov
			on MOV.IDTipoMovimiento = TMov.IDTipoMovimiento
		left join IMSS.tblCatRazonesMovAfiliatorios RMov
			on RMov.IDRazonMovimiento = Mov.IDRazonMovimiento
		Inner Join RH.tblCatRegPatronal RegPatronal
			on RegPatronal.IDRegPatronal = mov.IDRegPatronal
		inner join RH.tblEmpleadosMaster EmpleadosMaster
			on mov.IDEmpleado = EmpleadosMaster.IDEmpleado
		where 
			Mov.Fecha Between @FechaIni and @Fechafin
			and RegPatronal.IDRegPatronal = @IDRegPatronal
			and Mov.FechaIDSE IS NULL
   and ((EmpleadosMaster.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))                 
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))                
   and ((EmpleadosMaster.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))                 
      or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))                
   and ((EmpleadosMaster.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))                 
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))                 
   and ((EmpleadosMaster.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))                 
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))          
 and ((EmpleadosMaster.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))                 
     or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))             


END
GO

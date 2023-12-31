USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spReportesTimbradoDeNominaConErrores]  
(      
     @dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int            
)      
AS      
BEGIN      
       
	 	Select
		 p.Ejercicio        as EJERCICIO
	    ,p.Descripcion      as PERIODO
		,Timbrado.IDHistorialEmpleadoPeriodo as [FOLIO]  -- no estoy seguro
		,tpr.Descripcion    as [REGIMEN]
		,e.ClaveEmpleado	as [CLAVE EMPLEADO]
		,e.NOMBRECOMPLETO	as [NOMBRE COMPLETO]
		,e.RFC              as [RFC EMPLEADO]
		,e.CURP             as [CURP]
		,e.Cliente          as CLIENTE
		,e.TipoNomina       as [TIPO NOMINA]
		,e.Empresa			as [RAZON SOCIAL]
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as [CENTRO COSTO]

		--,UPPER(isnull(Timbrado.UUID,'')) as UUID
		,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,Timbrado.CodigoError
		,Timbrado.Error
	from Nomina.tblCatPeriodos P with (nolock) 
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = p.IDPeriodo --and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
        inner join  rh.tblEmpleadosMaster e with (nolock) 
		    on e.IDEmpleado = Historial.IDEmpleado
        inner join   SAT.tblCatTiposRegimen tpr with (nolock) 
		    on Timbrado.IDTipoRegimen = tpr.IDTipoRegimen
  WHERE Estatustimbrado.Descripcion = 'ERROR'
      
END
GO

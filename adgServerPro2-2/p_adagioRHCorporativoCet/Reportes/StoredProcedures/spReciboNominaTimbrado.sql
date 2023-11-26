USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Reportes.spReciboNominaTimbrado @IDEmpleado=1,@IDPeriodo=87
CREATE PROCEDURE [Reportes].[spReciboNominaTimbrado] --20314, 2        
(        
  @IDEmpleado int,          
  @IDPeriodo int,
  @IDUsuario int          
)        
AS        
BEGIN        
         
DECLARE         
   @empleados [RH].[dtEmpleados]        
  ,@periodo [Nomina].[dtPeriodos]        
  ,@Conceptos [Nomina].[dtConceptos]        
  ,@dtFiltros [Nomina].[dtFiltrosRH]        
  ,@fechaIniPeriodo  date        
  ,@fechaFinPeriodo  date        
         
        
 if(isnull(@IDEmpleado,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)        
   END;        
        
    Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)        
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado     
    
     
    from Nomina.TblCatPeriodos        
    where IDPeriodo = @IDPeriodo        
        
        
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago        
    from Nomina.TblCatPeriodos        
    where IDPeriodo = @IDPeriodo        
        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros , @IDUsuario= @IDUsuario       

    select         
   p.IDPeriodo        
  ,p.ClavePeriodo        
  ,p.Descripcion as Periodo        
  ,p.FechaInicioPago         
  ,p.FechaFinPago        
  ,e.IDEmpleado        
  ,e.ClaveEmpleado        
  ,e.NOMBRECOMPLETO        
  ,e.RFC as RFCEmpleado        
  ,e.CURP         
  ,e.IMSS        
  ,e.JornadaLaboral        
  ,e.FechaAntiguedad       
  ,e.IDTipoNomina       
  ,e.TipoNomina        
  ,e.SalarioDiario        
  ,e.SalarioIntegrado         
  ,dep.Descripcion as Departamento        
  ,puesto.Descripcion as Puesto        
  ,suc.Descripcion as Sucursal        
  ,empresa.NombreComercial Empresa        
  ,empresa.RFC RFCEmpresa        
  ,RF.Descripcion as EmpresaRegimenFiscal        
  ,estados.NombreEstado as EmpresaEstado        
  ,municipios.Descripcion as EmpresaMunicipio        
  ,regpatronal.RegistroPatronal        
  ,p.FechaFinPago as FechaExpedicion        
  ,t.ACUSE       
  ,t.CadenaOriginal       
  ,t.NoCertificadoSat       
  ,t.SelloCFDI       
  ,t.SelloSAT       
  ,t.UUID       
   from         
  Nomina.tblHistorialesEmpleadosPeriodos hep        
   inner join @periodo p         
    on hep.IDPeriodo = p.IDPeriodo        
   inner join @empleados e         
    on e.IDEmpleado = hep.IDEmpleado        
   left join RH.tblCatCentroCosto cc        
    on cc.IDCentroCosto = hep.IDCentroCosto        
   left join RH.tblCatDepartamentos Dep        
    on Dep.IDDepartamento = hep.IDDepartamento        
   left join RH.tblCatSucursales suc        
    on suc.IDSucursal = hep.IDSucursal        
   left join rh.tblCatPuestos puesto        
    on puesto.IDPuesto = hep.IDPuesto        
   left join RH.tblCatRegPatronal regpatronal        
    on regpatronal.IDRegPatronal = hep.IDRegPatronal        
   left join RH.tblCatClientes cliente        
    on cliente.IDCliente = hep.IDCliente        
   left join rh.tblEmpresa empresa        
    on empresa.IdEmpresa = hep.IDEmpresa        
   left join RH.tblCatArea area        
    on area.IDArea = hep.IDArea        
   left join RH.tblCatDivisiones div        
    on div.IDDivision = hep.IDDivision        
   left join RH.tblCatClasificacionesCorporativas ClasCorp        
    on ClasCorp.IDClasificacionCorporativa = hep.IDClasificacionCorporativa        
   left join rh.tblCatRegiones reg        
    on reg.IDRegion = hep.IDRegion        
   left join RH.tblCatRazonesSociales RS        
    on RS.IDRazonSocial = hep.IDRazonSocial        
   --CROSS Apply (select top 1 * from Facturacion.TblTimbrado where IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo order by Fecha desc) timbrado        
 left join Sat.tblCatRegimenesFiscales RF        
    on RF.IDRegimenFiscal = empresa.IDRegimenFiscal        
   left join Sat.tblCatEstados estados        
    on estados.IDEstado = Empresa.IDEstado        
   left join Sat.tblCatMunicipios municipios        
    on municipios.IDMunicipio = Empresa.IDMunicipio       
 inner join Facturacion.TblTimbrado T      
  on T.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo       
  and t.Actual = 1      
END
GO

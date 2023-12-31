USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from RH.tblEmpleadosMaster where ClaveEmpleado = '05931'
--select * from Nomina.tblCatPeriodos where IDTipoNomina = 17 and Ejercicio = 2023
--exec Reportes.spReciboNominaTimbrado @IDEmpleado=948,@IDPeriodo=357,@IDUsuario = 1
--exec Reportes.[spReciboNominaTimbradoAvilab] @IDEmpleado=948,@IDPeriodo=357,@IDUsuario = 1
--GUTIERREZ  ACEVES LAURA FABIOLA
--GUTIERREZ  ACEVES LAURA FABIOLA
CREATE PROCEDURE [Reportes].[spReciboNominaTimbradoAvilab] --20314, 2        
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
        
        --select * from @dtFiltros return
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago        
    from Nomina.TblCatPeriodos        
    where IDPeriodo = @IDPeriodo 
	
	--select @fechaIniPeriodo,@fechaFinPeriodo,@IDUsuario return
        
    insert into @empleados        
		exec [RH].[spBuscarEmpleados] 
			--@FechaIni = @fechaIniPeriodo ,
			--@Fechafin = @fechaFinPeriodo, 
			@dtFiltros = @dtFiltros , 
			@IDUsuario= @IDUsuario     
			if OBJECT_ID('tempdb..#tempMovAfiliatorios') is not null drop table #tempMovAfiliatorios  

		select ROW_NUMBER() over (PARTition by IDEmpleado order by Fecha desc) as numero,*  into #tempMovAfiliatorios from imss.tblMovAfiliatorios where fecha <= @fechaFinPeriodo 
		update e set e.SalarioDiario = t.SalarioDiario, e.SalarioIntegrado = t.SalarioIntegrado from @empleados as e inner join #tempMovAfiliatorios t on e.idempleado = t.idempleado where numero=1
			--select * from @empleados return

    select         
   p.IDPeriodo        
  ,p.ClavePeriodo        
  ,p.Descripcion as Periodo        
  ,p.FechaInicioPago         
  ,p.FechaFinPago        
  ,e.IDEmpleado        
  ,e.ClaveEmpleado        
  --,e.NOMBRECOMPLETO        
  ,UPPER(TRIM(COALESCE(E.Paterno,''))+' '+ TRIM(CASE WHEN ISNULL(E.Materno,'') <> '' THEN ' '+COALESCE(E.Materno,'') ELSE '' END)  +' '+TRIM(COALESCE(E.Nombre,''))+ CASE WHEN TRIM(ISNULL(E.SegundoNombre,'')) <> '' THEN ' '+TRIM(COALESCE(E.SegundoNombre,'')) ELSE '' END)  AS NOMBRECOMPLETO
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
  ,empresa.Calle as EmpresaCalle
  ,isnull(empresa.Exterior,'') as EmpresaNumero  
  ,colonias.NombreAsentamiento  as EmpresaColonia 
  ,CodPostal.CodigoPostal as EmpresaCP  
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
	left join sat.tblCatColonias colonias
		on colonias.IDColonia = empresa.idcolonia    
	left join sat.tblCatCodigosPostales CodPostal
		on CodPostal.IDCodigoPostal = empresa.idCodigoPostal   
 inner join Facturacion.TblTimbrado T      
  on T.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo       
  and t.Actual = 1      
END
GO

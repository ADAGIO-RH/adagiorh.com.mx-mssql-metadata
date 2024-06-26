USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from RH.tblEmpleados where ClaveEmpleado = 'JM00604'
--select * from nomina.tblCatTipoNomina
CREATE PROCEDURE [Reportes].[spCartaFiniquitoMX] --577, 99, 1     
(      
  @ClaveEmpleado VARCHAR(10),   
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
  ,@Finiquito bit
  ,@diasPagables int
  ,@IDConceptoRD010 INT
       
      
 if(isnull(@IDEmpleado,'')<>'')      
   BEGIN      
   insert into @dtFiltros(Catalogo,Value)      
   values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)      
   END
   ELSE
   BEGIN
   Select @IDEmpleado = IDEmpleado from rh.tblEmpleadosMaster where ClaveEmpleado = @ClaveEmpleado
   insert into @dtFiltros(Catalogo,Value)      
   values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)
   END



    Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)      
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado   
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodo      
      
      
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago, @Finiquito = ISNULL(Finiquito,0)      
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodo      

    select @IDConceptoRD010=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD010'
      
    insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster]@FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario      
     
     select @diasPagables=CantidadDias
        from Nomina.tblDetallePeriodo DP
        WHERE IDPeriodo=@IDPeriodo AND IDEmpleado=@IDEmpleado AND IDConcepto=@IDConceptoRD010
	  
    select       
   p.IDPeriodo      
  ,p.ClavePeriodo      
  ,p.Descripcion as Periodo      
  ,p.FechaInicioPago       
  ,p.FechaFinPago      
  ,hep.IDEmpleado 
  ,hep.CentroCosto     
  ,hep.ClaveEmpleado      
  ,hep.NOMBRECOMPLETO 
  ,hep.Nombre
  ,hep.SegundoNombre
  ,hep.Materno
  ,hep.Paterno     
  ,hep.RFC as RFCEmpleado      
  ,hep.CURP       
  ,hep.IMSS      
  ,hep.JornadaLaboral      
  ,hep.FechaAntiguedad      
  ,hep.TipoNomina      
  ,hep.SalarioDiario
  ,hep.SalarioDiario * 30 as Sueldo      
  ,hep.SalarioIntegrado    
  ,PE.Cuenta
  ,dep.Descripcion as Departamento      
  ,puesto.Descripcion as Puesto      
  ,suc.Descripcion as Sucursal      
  ,empresa.NombreComercial Empresa      
  ,empresa.RFC RFCEmpresa      
  ,RF.Descripcion as EmpresaRegimenFiscal      
  ,estados.NombreEstado as EmpresaEstado      
  ,municipios.Descripcion as EmpresaMunicipio      
  ,regpatronal.RegistroPatronal      
  ,Convert(varchar , cf.FechaBaja,103) as Fechabaja   
  ,Convert(varchar , cf.FechaAntiguedad,103) as FechaAntiguedad  
  ,cliente.Codigo as CodigoCliente
  ,@Finiquito as Finiquito
  ,Convert(varchar , cf.FechaBaja,103) as FechaBajaFiniquito
  ,Convert(varchar , cf.FechaAntiguedad,103) as FechaAntiguedadFiniquito
  ,isnull((Select top 1 Importetotal1 from Nomina.tblDetallePeriodo with(nolock) where IDConcepto = (select IDConcepto from nomina.tblCatConceptos where Codigo = '550')and IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado),0)as TotalPercepciones    
  ,isnull((Select top 1 Importetotal1 from Nomina.tblDetallePeriodo with(nolock) where IDConcepto = (select IDConcepto from nomina.tblCatConceptos where Codigo = '560')and IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado),0)as TotalDeducciones     
  ,isnull((Select top 1 Importetotal1 from Nomina.tblDetallePeriodo with(nolock) where IDConcepto = (select IDConcepto from nomina.tblCatConceptos where Codigo = '604')and IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado),0)as TotalPagado   
  ,Utilerias.fnConvertNumerosALetras(isnull((Select top 1 Importetotal1 from Nomina.tblDetallePeriodo with(nolock) where IDConcepto = (select IDConcepto from nomina.tblCatConceptos where Codigo = '604')and IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado),0.00))+' M.N' as TotalAPagarEnLetras
  ,@diasPagables AS DIASPAGABLES
  ,CAST((DATEDIFF(Day,cf.FechaAntiguedad,cf.FechaBaja)/30.4375)/12 as int ) as Añostrabajados
  ,CAST((DATEDIFF(Day,cf.FechaAntiguedad,cf.FechaBaja)/30.4375)%12 as int ) as Mesestrabajados
  ,CAST((((DATEDIFF(Day,cf.FechaAntiguedad,cf.FechaBaja)/30.4375)%12)%1)*30.4375 as int ) as Diastrabajados
  ,isnull(nota.Nota,'N/A') as Nota
    from       
  @empleados hep       
   CROSS JOIN @periodo p 

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
   left join Nomina.tblControlFiniquitos CF
		on CF.IDPeriodo = p.IDPeriodo
		and CF.IDEmpleado = hep.IDEmpleado
    left join rh.tblPagoEmpleado PE
        ON PE.IDEmpleado=HEP.IDEmpleado
    left join IMSS.tblMovAfiliatorios mov 
        ON mov.IDEmpleado = hep.IDEmpleado  
    left join rh.tblNotasEmpleados nota 
        ON nota.IDEmpleado = hep.IDEmpleado
END
GO

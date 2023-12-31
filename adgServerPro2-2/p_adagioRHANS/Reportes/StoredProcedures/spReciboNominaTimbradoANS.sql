USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Reportes.spReciboNominaTimbrado @IDEmpleado=1,@IDPeriodo=87
CREATE PROCEDURE [Reportes].[spReciboNominaTimbradoANS] --1182, 147,1       
(        
  @IDEmpleado int,          
  @IDPeriodo int,
  @IDUsuario int          
)        
AS        
BEGIN        
     
	 
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	 
DECLARE         
   @empleados [RH].[dtEmpleados]        
  ,@periodo [Nomina].[dtPeriodos]        
  ,@Conceptos [Nomina].[dtConceptos]        
  ,@dtFiltros [Nomina].[dtFiltrosRH]        
  ,@fechaIniPeriodo  date        
  ,@fechaFinPeriodo  date   
  ,@IDMes int
  ,@Bimestre Varchar(max)
  ,@Ejercicio int
  ,@Descuento varchar(max)
         
        
 if(isnull(@IDEmpleado,'')<>'')        
   BEGIN        
  insert into @dtFiltros(Catalogo,Value)        
  values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)        
   END;        
        
    Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)        
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado     
    
     
    from Nomina.TblCatPeriodos        
    where IDPeriodo = @IDPeriodo        
        
        
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago, @IDMes = IDMes, @Ejercicio = Ejercicio        
    from Nomina.TblCatPeriodos        
    where IDPeriodo = @IDPeriodo    
	
	select @Bimestre =  CASE WHEN @IDMes IN (1,2) THEN 'APORTACIONES 1ER BIMESTRE: ENE-FEB '+CAST(@Ejercicio AS VARCHAR(MAX))
							 WHEN @IDMes IN (3,4) THEN 'APORTACIONES 2DO BIMESTRE: MAR-ABR '+CAST(@Ejercicio AS VARCHAR(MAX))
							 WHEN @IDMes IN (5,6) THEN 'APORTACIONES 3ER BIMESTRE: MAY-JUN '+CAST(@Ejercicio AS VARCHAR(MAX))
							 WHEN @IDMes IN (7,8) THEN 'APORTACIONES 4TO BIMESTRE: JUL-AGO '+CAST(@Ejercicio AS VARCHAR(MAX))
							 WHEN @IDMes IN (9,10) THEN 'APORTACIONES 5TO BIMESTRE: SEP-OCT '+CAST(@Ejercicio AS VARCHAR(MAX))
							 WHEN @IDMes IN (11,12) THEN 'APORTACIONES 6TO BIMESTRE: NOV-DIC '+CAST(@Ejercicio AS VARCHAR(MAX))
						ELSE ''
						END
        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros , @IDUsuario= @IDUsuario    
	
		
	IF object_ID('TEMPDB..#TempSalarioPeriodo') IS NOT NULL DROP TABLE #TempSalarioPeriodo
	
	select ROW_NUMBER() over (PARTition by IDEmpleado order by Fecha desc) as RN, * 
	into #TempSalarioPeriodo
	from [IMSS].[tblMovAfiliatorios]
	WHERE Fecha <= @fechaFinPeriodo and idtipomovimiento <> 2

	update e set e.SalarioDiario = temp.salarioDiario        
				,e.SalarioIntegrado = temp.SalarioIntegrado
	from @empleados e
		inner join #TempSalarioPeriodo temp
		on temp.idempleado = e.idempleado and temp.RN = 1

	IF object_ID('TEMPDB..#TempConceptos') IS NOT NULL DROP TABLE #TempConceptos 

	Select c.Codigo,
		   c.Descripcion,
		   dp.ImporteTotal1
		into #TempConceptos
	from Nomina.tblDetallePeriodo dp with(nolock)
		inner join Nomina.tblCatConceptos c with(nolock)
			on dp.IDConcepto = c.IDConcepto
		where dp.IDPeriodo = @IDPeriodo
		and dp.IDEmpleado = @IDEmpleado
		and dp.ImporteTotal1 <> 0
			

	select @Descuento = case 
							when isnull((SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo = '047'),0) > 0 then 'DESCUENTO DE HORAS  ('+CAST(isnull((SELECT cast(SUM(isnull(Importetotal1,0))as decimal(16,2)) from #TempConceptos where Codigo = '047'),0) AS VARCHAR(MAX))+')  $-'+ CAST(cast(((E.SalarioDiario/8.0) * isnull((SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo = '047'),0)) as decimal(16,2))  AS VARCHAR(MAX))
							ELSE ''
							END
	FROM @empleados E


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
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo in ('002','005','007')) as DiasVacaciones
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo in ('004','003')) as FaltasInca
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo = '047') as DescuentoHora
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo = '550') as TotalPercepciones
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo = '560') as TotalDeducciones
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo = '030') as PercepcionGravable
  ,(SELECT SUM(isnull(Importetotal1,0)) from #TempConceptos where Codigo in ('601','602','603','604','605','606','607')) as NETO
  ,@Bimestre AS Bimestre
  ,0.00 as RETIRO
  ,0.00 as CESANTIA
  ,0.00 as AMORTTRABAJADOR
  ,0.00 as AMORTPATRONAL
  ,@Descuento DESCUENTO
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
 left join Facturacion.TblTimbrado T      
  on T.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo       
  and t.Actual = 1      
END
GO

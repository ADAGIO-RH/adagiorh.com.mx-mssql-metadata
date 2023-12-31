USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Reportes.spReciboNominaTimbrado @IDEmpleado=72,@IDPeriodo=116,@IDUsuario  = 1
CREATE PROCEDURE [Reportes].[spReciboNominaTimbradoColibri] --20314, 2        
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
  ,@IDIdioma varchar(20)	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
        
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
	--select  @fechaIniPeriodo, @fechaFinPeriodo
 --   select * from @dtFiltros
	IF((Select top 1 ISNULL(Finiquito,0) FROM @periodo) = 0)
	BEGIN
	print('general')
		insert into @empleados        
		exec [RH].[spBuscarEmpleados] 
			@dtFiltros = @dtFiltros 
			, @IDUsuario= @IDUsuario
			, @FechaIni = @fechaIniPeriodo
			, @FechaFin = @fechaFinPeriodo    
			
			--select * from @empleados
	END
	ELSE
	BEGIN
	print('Finiquito')

		if object_id('tempdb..#tempEmpleadosPeriodo') is not null drop table #tempEmpleadosPeriodo;
		if object_id('tempdb..#TempHistorial') is not null drop table #TempHistorial;
		if object_id('tempdb..#TempEmpleadosFiniquito') is not null drop table #TempEmpleadosFiniquito;
		if object_id('tempdb..#tempEmpleadosPeriodoAsimilado') is not null drop table #tempEmpleadosPeriodoAsimilado;

			Declare @IDEmpleadoFiniquitoProceso int = 0,
					@ClaveEmpleado varchar(20),
					@fechaBaja Date,
					@FechaAntiguedad Date

			select @IDEmpleadoFiniquitoProceso = CF.IDEmpleado
				, @ClaveEmpleado = e.ClaveEmpleado
				, @fechaBaja =  cf.FechaBaja
				, @FechaAntiguedad  = isnull(cf.FechaAntiguedad,dateadd(day,-1,cf.FechaBaja)) 
			
			from Nomina.tblControlFiniquitos cf with(nolock)
				inner join RH.tblEmpleados e with(nolock)
					on cf.IDEmpleado = e.IDEmpleado
			where cf.IDPeriodo = @IDPeriodo
				and CF.IDEmpleado = @IDEmpleado
		
		

		insert into @empleados        
		exec [RH].[spBuscarEmpleados] 
			@EmpleadoIni = @ClaveEmpleado
			,@EmpleadoFin = @ClaveEmpleado
			, @IDUsuario= @IDUsuario
			, @FechaIni = @FechaAntiguedad
			, @FechaFin = @fechaBaja 

	END
	
    select         
	   p.IDPeriodo        
	  ,p.ClavePeriodo        
	  ,p.Descripcion as Periodo        
	  ,p.FechaInicioPago         
	  ,p.FechaFinPago   
	  ,p.Dias
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
	  ,JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto        
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
	 -- ,Utilerias.fnConvertNumerosALetras(isnull(dp.ImporteTotal1,0.00)) +' M.N' as ImporteConLetra
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
	--left join Nomina.tblDetallePeriodo dp
	--	on dp.IDEmpleado = e.IDEmpleado
	--		and dp.IDPeriodo = @IDPeriodo
	--			and dp.IDConcepto =  5 --select * from Nomina.tblCatTipoConcepto  select * from Nomina.tblCatConceptos
	 inner join Facturacion.TblTimbrado T      
		on T.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo       
			 and t.Actual = 1      
END
GO

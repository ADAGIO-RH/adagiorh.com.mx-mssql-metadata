USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Reportes.spReciboNominaTimbrado @IDEmpleado=72,@IDPeriodo=116,@IDUsuario  = 1
CREATE PROCEDURE [Reportes].[spReciboNominaTimbrado](        
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
	  ,@IDIdioma varchar(20)	
	;

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
	
	IF((Select top 1 ISNULL(Finiquito,0) FROM @periodo) = 0)
	BEGIN
		insert into @empleados        
		exec [RH].[spBuscarEmpleados] 
			@dtFiltros = @dtFiltros 
			, @IDUsuario= @IDUsuario
			, @FechaIni = @fechaIniPeriodo
			, @FechaFin = @fechaFinPeriodo    
	END
	ELSE
	BEGIN
		if object_id('tempdb..#tempEmpleadosPeriodo') is not null drop table #tempEmpleadosPeriodo;
		if object_id('tempdb..#TempHistorial') is not null drop table #TempHistorial;
		if object_id('tempdb..#TempEmpleadosFiniquito') is not null drop table #TempEmpleadosFiniquito;
		if object_id('tempdb..#tempEmpleadosPeriodoAsimilado') is not null drop table #tempEmpleadosPeriodoAsimilado;

		Declare
			@IDEmpleadoFiniquitoProceso int = 0,
			@ClaveEmpleado varchar(20),
			@fechaBaja Date,
			@FechaAntiguedad Date
		;

		select 
			CF.IDEmpleado
			, e.ClaveEmpleado
			, cf.FechaBaja
			, isnull(cf.FechaAntiguedad,dateadd(day,-1,cf.FechaBaja)) FechaAntiguedad
		into #TempEmpleadosFiniquito
		from Nomina.tblControlFiniquitos cf with(nolock)
			inner join RH.tblEmpleados e with(nolock) on cf.IDEmpleado = e.IDEmpleado
		where cf.IDPeriodo = @IDPeriodo
			and cf.IDEStatusFiniquito = 2 and CF.IDEmpleado = @IDEmpleado
		
		select @IDEmpleadoFiniquitoProceso = min(IDEmpleado) 
		from #TempEmpleadosFiniquito
		where IDEmpleado > @IDEmpleadoFiniquitoProceso

		select 
			@ClaveEmpleado	= ClaveEmpleado,
			@fechaBaja		= FechaBaja,
			@FechaAntiguedad = FechaAntiguedad
		from #TempEmpleadosFiniquito
		where IDEmpleado = @IDEmpleadoFiniquitoProceso

		insert into @empleados        
		exec [RH].[spBuscarEmpleados] 
			@dtFiltros = @dtFiltros 
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
		,e.IDEmpleado        
		,e.ClaveEmpleado        
		--,e.NOMBRECOMPLETO
        ,RH.fnFormatNombreCompleto(e.nombre,e.segundoNombre,e.Paterno,e.Materno) as NOMBRECOMPLETO        
		,e.RFC as RFCEmpleado        
		,e.CURP         
		,e.IMSS        
		,e.JornadaLaboral        
		,e.FechaAntiguedad       
		,e.IDTipoNomina       
		,e.TipoNomina        
		,e.SalarioDiario        
		,e.SalarioIntegrado         
		,JSON_VALUE(Dep.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))as Departamento        
		,JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto        
		,suc.Descripcion as Sucursal        
		,empresa.NombreComercial Empresa        
		,empresa.RFC RFCEmpresa        
		,RF.Descripcion as EmpresaRegimenFiscal        
		,estados.NombreEstado as EmpresaEstado        
		,municipios.Descripcion as EmpresaMunicipio        
		,regpatronal.RegistroPatronal        
		,t.Fecha as FechaExpedicion        
		,t.ACUSE       
		,t.CadenaOriginal       
		,t.NoCertificadoSat       
		,t.SelloCFDI       
		,t.SelloSAT       
		,t.UUID       
	from Nomina.tblHistorialesEmpleadosPeriodos hep        
		inner join @periodo p on hep.IDPeriodo = p.IDPeriodo        
		inner join @empleados e on e.IDEmpleado = hep.IDEmpleado        
		left join RH.tblCatCentroCosto cc on cc.IDCentroCosto = hep.IDCentroCosto        
		left join RH.tblCatDepartamentos Dep on Dep.IDDepartamento = hep.IDDepartamento        
		left join RH.tblCatSucursales suc on suc.IDSucursal = hep.IDSucursal        
		left join rh.tblCatPuestos puesto on puesto.IDPuesto = hep.IDPuesto        
		left join RH.tblCatRegPatronal regpatronal on regpatronal.IDRegPatronal = hep.IDRegPatronal        
		left join RH.tblCatClientes cliente on cliente.IDCliente = hep.IDCliente        
		left join rh.tblEmpresa empresa on empresa.IdEmpresa = hep.IDEmpresa        
		left join RH.tblCatArea area on area.IDArea = hep.IDArea        
		left join RH.tblCatDivisiones div on div.IDDivision = hep.IDDivision        
		left join RH.tblCatClasificacionesCorporativas ClasCorp on ClasCorp.IDClasificacionCorporativa = hep.IDClasificacionCorporativa        
		left join rh.tblCatRegiones reg on reg.IDRegion = hep.IDRegion        
		left join RH.tblCatRazonesSociales RS on RS.IDRazonSocial = hep.IDRazonSocial        
	   --CROSS Apply (select top 1 * from Facturacion.TblTimbrado where IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo order by Fecha desc) timbrado        
		left join Sat.tblCatRegimenesFiscales RF on RF.IDRegimenFiscal = empresa.IDRegimenFiscal        
		left join Sat.tblCatEstados estados on estados.IDEstado = Empresa.IDEstado        
		left join Sat.tblCatMunicipios municipios on municipios.IDMunicipio = Empresa.IDMunicipio       
		inner join Facturacion.TblTimbrado T on T.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo and t.Actual = 1      
END
GO

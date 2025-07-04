USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoNoFiscalNominaFull](
    @IDUsuario int   
   ,@IDCliente int 
   ,@IDTipoNomina int 
   ,@IDPeriodo int = 0
   ,@dtDepartamentos Varchar(MAX) = null
   ,@dtSucursales Varchar(MAX) = null
   ,@dtPuestos Varchar(MAX) = null
   ,@dtEmpleados Varchar(MAX) = '690'
   ,@dtPrestaciones Varchar(MAX) = null
)
AS
BEGIN

	DECLARE 
		 @empleados [RH].[dtEmpleados]
		,@IDPeriodoSeleccionado int=0
		,@periodo [Nomina].[dtPeriodos]
		,@configs [Nomina].[dtConfiguracionNomina]
		,@Conceptos [Nomina].[dtConceptos]
		,@dtFiltros [Nomina].[dtFiltrosRH]
		,@fechaIniPeriodo  date
		,@fechaFinPeriodo  date
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if(isnull(@dtEmpleados,'')<>'')
	BEGIN
		insert into @dtFiltros(Catalogo,Value)
		values('Empleados',case when @dtEmpleados is null then '' else @dtEmpleados end)
	END;

	if(isnull(@dtDepartamentos,'')<>'')
	BEGIN
		insert into @dtFiltros(Catalogo,Value)
		values('Departamentos',case when @dtDepartamentos is null then '' else @dtDepartamentos end)
	END;

	if(isnull(@dtSucursales,'')<>'')
	BEGIN
		insert into @dtFiltros(Catalogo,Value)
		values('Sucursales',case when @dtSucursales is null then '' else @dtSucursales end)
	END;

	if(isnull(@dtPuestos,'')<>'')
	BEGIN
		insert into @dtFiltros(Catalogo,Value)
		values('Puestos',case when @dtPuestos is null then '' else @dtPuestos end)
	END;

	if(isnull(@dtPrestaciones,'')<>'')
	BEGIN
		insert into @dtFiltros(Catalogo,Value)
		values('Prestaciones',case when @dtPrestaciones is null then '' else @dtPrestaciones end)
	END;

	IF(isnull(@IDPeriodo,0)=0)
	BEGIN	
		select @IDPeriodoSeleccionado = IDPeriodo
		from Nomina.tblCatTipoNomina
		where IDTipoNomina=@IDTipoNomina
	END
	ELSE
	BEGIN
		set @IDPeriodoSeleccionado = @IDPeriodo
	END

	Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Cerrado)
	select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Cerrado
	from Nomina.TblCatPeriodos
	where IDPeriodo = @IDPeriodoSeleccionado
	
	select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago
	from Nomina.TblCatPeriodos
	where IDPeriodo = @IDPeriodoSeleccionado

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */
	insert into @empleados
	exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin=	@fechaFinPeriodo, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

	IF OBJECT_ID ('tempdb..#temp') is not null drop table #temp
	IF OBJECT_ID ('tempdb..#temp1') is not null drop table #temp1
	IF OBJECT_ID ('tempdb..#temp3') is not null drop table #temp3
	IF OBJECT_ID ('tempdb..#temp4') is not null drop table #temp4


	select  E.IDEmpleado,E.ClaveEmpleado,EM.IDEmpresa, S.NombreComercial, S.RFC, EMP.FechaFin, F.Descripcion AS RegFiscal, municipios.Descripcion AS EmpresaMunicipio, estados.NombreEstado AS EmpresaEstado  
	into #temp  
	from RH.tblEmpresaEmpleado EM
		join RH.tblEmpleados E	on E.IDEmpleado = EM.IDEmpleado
		join RH.tblEmpresa S on EM.IDEmpresa = S.IdEmpresa
		join RH.tblEmpresaEmpleado EMP ON EMP.IDEmpleado = E.IDEmpleado AND EMP.IDEmpresa = S.IdEmpresa
		join [Sat].[tblCatRegimenesFiscales] F ON F.IDRegimenFiscal = S.IDRegimenFiscal
		left join [Sat].[tblCatMunicipios] municipios on municipios.IDMunicipio = S.IDMunicipio
		left join [Sat].[tblCatEstados] estados on estados.IDEstado = S.IDEstado
							
	  
	select ROW_NUMBER() OVER (PARTITION BY #temp.IDEmpleado ORDER BY #temp.FECHAFIN DESC) AS registro 
		,#temp.IDEmpleado,#temp.claveEmpleado,#temp.Nombrecomercial,#temp.FechaFin, #temp.RFC, #temp.RegFiscal, #temp.EmpresaMunicipio, #temp.EmpresaEstado
			into #temp1
	from #temp

	select  E.IDEmpleado,E.ClaveEmpleado,RP.IDRegPatronal, S.RegistroPatronal, EMP.FechaFin 
		into #temp3  
	from RH.tblRegPatronalEmpleado RP
		join RH.tblEmpleados E	on E.IDEmpleado = RP.IDEmpleado
				join RH.tblCatRegPatronal S on RP.IDRegPatronal = S.IDRegPatronal
				JOIN RH.tblRegPatronalEmpleado EMP ON EMP.IDEmpleado = E.IDEmpleado AND EMP.IDRegPatronal = S.IDRegPatronal

	select ROW_NUMBER() OVER (PARTITION BY #temp3.IDEmpleado ORDER BY #temp3.FECHAFIN DESC) AS registro 
		,#temp3.IDEmpleado,#temp3.claveEmpleado,#temp3.RegistroPatronal,#temp3.FechaFin
			into #temp4
	from #temp3

	delete from #temp1 where registro <> 1
	delete from #temp4 where registro <> 1

	select  
		dp.IDPeriodo
		,cp.Descripcion as Periodo
		,registro.RegistroPatronal
		,cp.Descripcion as Periodo
		,cp.IDTipoNomina as IDTipoNomina
		,tn.Descripcion as TipoNomina
		,tn.IDCliente as IDCliente
		,JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,tn.IDPeriodicidadPago as IDPeriodicidadPago
		,pp.Descripcion as PeriodicidadPago
		,dp.IDConcepto
		,ccp.Codigo
		,ccp.Descripcion as Concepto
		,ccp.IDTipoConcepto
		,tc.Descripcion as TipoConcepto
		,ccp.OrdenCalculo
		,dp.Descripcion
		,dp.CantidadMonto as CantidadMonto
		,dp.CantidadDias as CantidadDias
		,dp.CantidadVeces as CantidadVeces
		,dp.CantidadOtro1 as CantidadOtro1
		,dp.CantidadOtro2 as CantidadOtro2
	    ,dp.ImporteGravado as ImporteGravado
	    ,dp.ImporteExcento as ImporteExcento
	    ,dp.ImporteOtro as ImporteOtro
	    ,dp.ImporteTotal1 as ImporteTotal1
	    ,dp.ImporteTotal2 ImporteTotal2	   
	    ,dp.ImporteAcumuladoTotales as ImporteAcumuladoTotales
		,E.*
		,empresa.RFC as RFCEmpresa
		,empresa.RegFiscal as EmpresaRegimenFiscal
		,empresa.EmpresaMunicipio
		,empresa.EmpresaEstado
		,cp.FechaFinPago as FechaExpedicion
	from [Nomina].[tblDetallePeriodo] dp with (nolock)
		LEFT join [Nomina].[tblCatPeriodos] cp with (nolock) on dp.IDPeriodo = cp.IDPeriodo
		INNER join @empleados e on dp.IDEmpleado = e.IDEmpleado
		LEFT join #temp4 Registro on Registro.IDEmpleado = dp.IDEmpleado
		LEFT join [Nomina].[tblCatTipoNomina] tn with (nolock) on tn.IDTipoNomina = cp.IDTipoNomina
		LEFT join [RH].[tblCatClientes] cc with (nolock) on cc.IDCliente = tn.IDCliente
		LEFT join [Sat].[tblCatPeriodicidadesPago] pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago
		LEFT join [Nomina].[tblCatConceptos] ccp with (nolock) on dp.IDConcepto = ccp.IDConcepto
		LEFT join [Nomina].[tblCatTipoConcepto] tc with (nolock) on tc.IDTipoConcepto = ccp.IDTipoConcepto
		LEFT join #temp1 empresa with (nolock) on empresa.ClaveEmpleado = e.ClaveEmpleado
		where cp.IDPeriodo = @IDPeriodoSeleccionado  
			ORDER BY e.Paterno, e.Materno, e.Nombre ,OrdenCalculo ASC  
		--LEFT join RH.tblEmpresaEmpleado EE on dp.IDEmpleado = EE.IDEmpleado
		--LEFT join RH.tblEmpresa EP on EP.IdEmpresa = EE.IDEmpresa
		--LEFT JOIN RH.tblEmpresa EMP ON EMP.NombreComercial = tmpE.NombreComercial
		--LEFT join [Sat].[tblCatRegimenesFiscales] RF on RF.IDRegimenFiscal = empresa.IDRegimenFiscal
		--LEFT join [Sat].[tblCatMunicipios] municipios on municipios.IDMunicipio = empresa.IDMunicipio
		--LEFT join [Sat].[tblCatEstados] estados on estados.IDEstado = empresa.IDEstado
END
GO

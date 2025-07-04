USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoDeTimbradoNomina](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('IDTipoNomina',4)
	--	  ,('IDPeriodoInicial',75)
	--	  ,('IDPeriodoFinal',98)

	declare @empleados [RH].[dtEmpleados]      
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDPeriodoFinal int 
		,@IDCliente int
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END


	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDPeriodoFinal	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoFinal'),',')
	Select @IDCliente		= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')

	select @fechaIniPeriodo = FechaInicioPago, @IDTipoNomina = IDTipoNomina from Nomina.tblCatPeriodos with (nolock) where IDPeriodo = @IDPeriodoInicial
	select @fechaFinPeriodo = FechaFinPago from Nomina.tblCatPeriodos with (nolock) where IDPeriodo = @IDPeriodoFinal

	insert into @periodo
	select *
		--IDPeriodo
		--,IDTipoNomina
		--,Ejercicio
		--,ClavePeriodo
		--,Descripcion
		--,FechaInicioPago
		--,FechaFinPago
		--,FechaInicioIncidencia
		--,FechaFinIncidencia
		--,Dias
		--,AnioInicio
		--,AnioFin
		--,MesInicio
		--,MesFin
		--,IDMes
		--,BimestreInicio
		--,BimestreFin
		--,Cerrado
		--,General
		--,Finiquito
		--,isnull(Especial,0)
	from Nomina.tblCatPeriodos with (nolock)
	where IDTipoNomina = @IDTipoNomina and FechaInicioPago >= @fechaIniPeriodo and FechaFinPago <= @fechaFinPeriodo

	--	((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                 
	--	or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))  

	--select 
	--	top 1 @fechaIniPeriodo = FechaInicioPago
	--from @periodo	
	--order by FechaInicioPago asc

	--insert @periodo
	--select 
	--	IDPeriodo
	--	,IDTipoNomina
	--	,Ejercicio
	--	,ClavePeriodo
	--	,Descripcion
	--	,FechaInicioPago
	--	,FechaFinPago
	--	,FechaInicioIncidencia
	--	,FechaFinIncidencia
	--	,Dias
	--	,AnioInicio
	--	,AnioFin
	--	,MesInicio
	--	,MesFin
	--	,IDMes
	--	,BimestreInicio
	--	,BimestreFin
	--	,Cerrado
	--	,General
	--	,Finiquito
	--	,isnull(Especial,0)
	--from Nomina.tblCatPeriodos
	--where 
	--	((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoFinal'),','))                 
	--	or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoFinal' and isnull(Value,'')<>'')))) 

	--select 
	--	top 1 @fechaFinPeriodo = FechaFinPago
	--from @periodo
	--order by FechaFinPago desc

	 /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
    insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	update E
		set E.Vigente = M.Vigente
	from RH.tblEmpleadosMaster M
		Inner join @empleados E
			on M.IDEmpleado = E.IDEmpleado


	Select distinct
		p.ClavePeriodo as CLAVE_PERIODO,
		p.Descripcion as PERIODO,
		e.ClaveEmpleado as [CLAVE COLABORADOR],
		e.NOMBRECOMPLETO as NOMBRE,
		e.RFC as [RFC ],
		CASE WHEN E.Vigente = 1 THEN 'SI' ELSE 'NO' END [VIGENTE HOY],
		isnull(dpPercepciones.ImporteTotal1,0) as [IMPORTE TOTAL PERCEPCIONES],
		isnull(dpDeducciones.ImporteTotal1,0) as [IMPORTE TOTAL DEDUCCIONES],
		isnull(dpTotal.ImporteTotal1,0) as [IMPORTE TOTAL],
		ISNULL(t.UUID,'') as [FOLIO UUID],
		ISNULL(emp.RFC,'') as [RFC EMISOR],
		ISNULL(emp.NombreComercial,'') as [RAZON SOCIAL],
		Suc.Codigo as SUCURSAL,
		e.Sucursal as [SUCURSAL DESCRIPCION],
		Depto.Codigo as DEPARTAMENTO,
		JSON_VALUE(Depto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [DEPARTAMENTO DESCRIPCION],
		Puesto.Codigo as PUESTO,
		JSON_VALUE(Puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))as [PUESTO DESCRIPCION],
		Div.Codigo as DIVISION,
        JSON_VALUE(Div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))as [DIVISION DESCRIPCION],
		CC.Codigo as [CENTRO COSTO],
		JSON_VALUE(CC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [CENTRO COSTO DESCRIPCION],
		Clasificacion.Codigo as [CLASIFICACION CORPORATIVA],
		e.ClasificacionCorporativa as [CLASIFICACION CORPORATIVA DESCRIPCION],
		clientes.Codigo as CLIENTE,
		JSON_VALUE(clientes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as [CLIENTE DESCRIPCION],
		ISNULL(TT.Descripcion,'EVENTUAL') as [TIPO TRABAJADOR],
		ISNULL(JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'NINGUNA') as [TIPO PRESTACION]
	from Nomina.tblHistorialesEmpleadosPeriodos HEP with (nolock)
		INNER JOIN	@periodo P
			on HEP.IDPeriodo = P.IDPeriodo
		inner join @empleados e
			on HEP.IDEmpleado = e.IDEmpleado
		Inner join Facturacion.TblTimbrado T with (nolock)
			on T.IDHistorialEmpleadoPeriodo = HEP.IDHistorialEmpleadoPeriodo
				and T.Actual = 1
		left join RH.tblEmpresa emp with (nolock)
			on hep.IDEmpresa = emp.IdEmpresa	
		left join RH.tblCatSucursales Suc with (nolock)
			on Suc.IDSucursal = e.IDSucursal
		left join RH.tblCatDepartamentos Depto with (nolock)
			on Depto.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos Puesto with (nolock)
			on Puesto.IDPuesto = E.IDPuesto
		left join RH.tblCatDivisiones Div with(nolock)
			on div.IDDivision = e.IDDivision
		left join RH.tblCatCentroCosto CC with(nolock)
			on CC.IDCentroCosto = e.IDCentroCosto
		left join RH.tblCatClasificacionesCorporativas Clasificacion with(nolock)
			on Clasificacion.IDClasificacionCorporativa = e.IDClasificacionCorporativa
		left join RH.tblCatClientes clientes with(nolock)
			on clientes.IDCliente = e.IDCliente
		left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = HEP.IDEmpleado and TTE.[Row] = 1
		left join IMSS.tblCatTipoTrabajador TT with (nolock)
			on TT.IDTipoTrabajador = TTE.IDTipoTrabajador	
		left join RH.tblCatTiposPrestaciones TP with (nolock)
			on TP.IDTipoPrestacion = E.IDTipoPrestacion	
		left join Nomina.tblDetallePeriodo dpPercepciones with (nolock)
			on p.IDPeriodo = dpPercepciones.IDPeriodo
				and dpPercepciones.IDEmpleado = hep.IDEmpleado
				and dpPercepciones.IDConcepto = (Select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo = '550')
		left join Nomina.tblDetallePeriodo dpDeducciones with (nolock)
			on p.IDPeriodo = dpDeducciones.IDPeriodo
				and dpDeducciones.IDEmpleado = hep.IDEmpleado
				and dpDeducciones.IDConcepto = (Select IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo = '560')
		left join Nomina.tblDetallePeriodo dpTotal with (nolock)
			on p.IDPeriodo = dpTotal.IDPeriodo
				and dpTotal.IDEmpleado = hep.IDEmpleado
				and dpTotal.IDConcepto in (Select IDConcepto from Nomina.tblCatConceptos with (nolock) where IDTipoConcepto = 5)
	ORDER BY e.ClaveEmpleado ASC
GO

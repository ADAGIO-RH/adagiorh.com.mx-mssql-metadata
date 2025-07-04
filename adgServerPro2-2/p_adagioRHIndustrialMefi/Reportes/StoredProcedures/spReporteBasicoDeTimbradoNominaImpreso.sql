USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoDeTimbradoNominaImpreso](
	 @Cliente  varchar(max) = null
	,@TipoNomina  varchar(max) = null
	,@IDPeriodoInicial int
	,@IDPeriodoFinal int
    ,@Departamentos				  varchar(max) = ''
	,@Sucursales				  varchar(max) = ''
	,@Puestos					  varchar(max) = ''
	,@Prestaciones				  varchar(max) = ''
	,@TiposContratacion			  varchar(max) = ''
	,@RazonesSociales			  varchar(max) = ''
	,@RegPatronales				  varchar(max) = ''
	,@Divisiones				  varchar(max) = ''
	,@ClasificacionesCorporativas varchar(max) = ''
	,@CentrosCostos				  varchar(max) = ''
	,@Regiones					  varchar(max) = ''
	,@IDUsuario int
) as
	IF 1=0 
	BEGIN
		SET FMTONLY OFF
	END;
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
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date      
		,@IDTipoNomina int
		,@dtFiltros Nomina.dtFiltrosRH   
        ,@IDIdioma varchar (max)
	;  
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


	insert into @dtFiltros(Catalogo,Value)
	values
		('Departamentos',@Departamentos)
		,('RazonesSociales',@RazonesSociales)
		,('RegistrosPatronales',@RegPatronales)
		,('Regiones',@Regiones)
		,('Divisiones',@Divisiones)
		,('ClasificacionesCorporativas',@ClasificacionesCorporativas)
		,('CentrosCostos',@CentrosCostos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('Cliente',@Cliente)

	select @fechaIniPeriodo = FechaInicioPago, @IDTipoNomina = IDTipoNomina from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodoInicial
	select @fechaFinPeriodo = FechaFinPago from Nomina.tblCatPeriodos where IDPeriodo = @IDPeriodoFinal

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

	 /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
      insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	Select
		p.ClavePeriodo as CLAVE_PERIODO,
		p.Descripcion as PERIODO,
		e.ClaveEmpleado as CLAVE_COLABORADOR,
		e.NOMBRECOMPLETO as NOMBRE,
		e.RFC as RFC,
		isnull(dpPercepciones.ImporteTotal1,0) as IMPORTE_TOTAL_PERCEPCIONES,
		isnull(dpDeducciones.ImporteTotal1,0) as IMPORTE_TOTAL_DEDUCCIONES,
		isnull(dpTotal.ImporteTotal1,0) as IMPORTE_TOTAL,
		ISNULL(t.UUID,'') as FOLIO_UUID,
		ISNULL(emp.RFC,'') as RFC_EMISOR,
		ISNULL(emp.NombreComercial,'') as RAZON_SOCIAL,
		e.Sucursal as SUCURSAL,
		e.Departamento as DEPARTAMENTO,
		e.Puesto as PUESTO,
		e.Division as DIVISION,
		e.CentroCosto as CENTRO_COSTO,
		e.ClasificacionCorporativa as CLASIFICACION_CORPORATIVA,
		e.Cliente as CLIENTE,
		ISNULL(TT.Descripcion,'EVENTUAL') as TIPO_TRABAJADOR,
		ISNULL(JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'NINGUNA') as TIPO_PRESTACION
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

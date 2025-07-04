USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoNominaListaEmpleadosFiniquitosMasivos](    
	 @dtFiltros Nomina.dtFiltrosRH  readonly,
	 @IDUsuario int    
) as    
	SET FMTONLY OFF 

	declare @empleados [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0        
		,@periodo [Nomina].[dtPeriodos]        
		,@configs [Nomina].[dtConfiguracionNomina]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date 
		,@IDTipoNomina   int    
		,@IDPeriodoInicial int
	;    
  
	set @IDTipoNomina = 
		case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
			then (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		else 0  
		END  
  
	/* Se buscan el periodo seleccionado */    
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
	where
	   ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>'')))) 
	
	select top 1 @IDPeriodoInicial=IDPeriodo, @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago from @periodo  
  
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
    
	Select 
		E.ClaveEmpleado as [CLAVE EMPLEADO], 
		E.NOMBRECOMPLETO as [NOMBRE COMPLETO], 
		rs.RFC as [RFC RAZON SOCIAL],
		E.Empresa as [RAZON SOCIAL],
		cd.Codigo as [COD. DEPARTAMENTO],
		E.DEPARTAMENTO,
		cs.Codigo as [COD. SUCURSAL],
		E.SUCURSAL,
		format(e.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD],
		format(p.FechaFinPago,'dd/MM/yyyy') as [FECHA FIN PAGO],
		datediff(day, e.fechaAntiguedad, p.fechaFinPago)/365.0 as [AÑOS],
		e.SalarioDiario as  [SALARIO DIARIO],
		[DIAS VACACIONES] =  [Asistencia].[fnBuscarDiasVacacionesProporcionales] ( e.IDEmpleado,e.IDTipoPrestacion,e.FechaAntiguedad,p.FechaFinPago) - [Asistencia].[fnBuscarIncidenciasEmpleado](e.IDEmpleado,'V',e.FechaAntiguedad, p.FechaFinPago)  ,
		[IMPORTE VACACIONES] =  ([Asistencia].[fnBuscarDiasVacacionesProporcionales] ( e.IDEmpleado,e.IDTipoPrestacion,e.FechaAntiguedad,p.FechaFinPago) - [Asistencia].[fnBuscarIncidenciasEmpleado](e.IDEmpleado,'V',e.FechaAntiguedad, p.FechaFinPago))  * e.SalarioDiario,
		[IMPORTE PRIMAS VACACIONALES] = isnull(pd.PrimaVacacional,0) * ([Asistencia].[fnBuscarDiasVacacionesProporcionales] ( e.IDEmpleado,e.IDTipoPrestacion,e.FechaAntiguedad,p.FechaFinPago) - [Asistencia].[fnBuscarIncidenciasEmpleado](e.IDEmpleado,'V',e.FechaAntiguedad, p.FechaFinPago))  * e.SalarioDiario ,
		[DIAS AGUINALDO] = [Asistencia].[fnBuscarDiasAguinaldoProporcionales] (e.IDEmpleado, e.IDTipoPrestacion, e.FechaAntiguedad,p.FechaFinPago),
		[IMPORTE AGUINALDO] = [Asistencia].[fnBuscarDiasAguinaldoProporcionales] (e.IDEmpleado, e.IDTipoPrestacion, e.FechaAntiguedad,p.FechaFinPago) * e.SalarioDiario,
		90 as [90 DIAS INDEMNIZACION], 
		90 * (select top 1 SalarioMinimo from Nomina.tblSalariosMinimos sm where sm.Fecha <= p.FechaFinPago) as [IMPORTE 90 DIAS INDEMNIZACION], 
		20 * (datediff(day, e.FechaAntiguedad, p.FechaFinPago)/365.0) as [20 DIAS INDEMNIZACION X AÑO], 
		20 * (datediff(day, e.FechaAntiguedad, p.FechaFinPago)/365.0) * (select top 1 SalarioMinimo from Nomina.tblSalariosMinimos sm where sm.Fecha <= p.FechaFinPago)   as [IMPORTE 20 DIAS INDEMNIZACION X AÑO], 
		12 * (datediff(day, e.FechaAntiguedad, p.FechaFinPago)/365.0)   as [DIAS POR PRIMA ANTIGUEDAD], 
		12 * (datediff(day, e.FechaAntiguedad, p.FechaFinPago)/365.0) * (select top 1 SalarioMinimo from Nomina.tblSalariosMinimos sm where sm.Fecha <= p.FechaFinPago)  as [IMPORT POR PRIMA ANTIGUEDAD],
		case when isnull(ee.Vigente,0) = 1 then 'SI' else 'NO' end  [VIGENTE HOY]
	from @empleados E
		inner join RH.tblEmpleadosMaster ee with (nolock) on ee.IDEmpleado = e.IDEmpleado
		left join RH.tblEmpresa rs with (nolock) on rs.IDEmpresa = e.IDEmpresa
		left join RH.tblCatDepartamentos cd with (nolock) on cd.IDDepartamento = e.IDDepartamento
		left join RH.tblCatSucursales cs with (nolock) on cs.IDSucursal = e.IDSucursal
		left join @periodo p on p.IDPeriodo = @IDPeriodoInicial
		left join RH.tblCatTiposPrestacionesDetalle pd with (nolock)
			on  pd.IDTipoPrestacion = e.IDTipoPrestacion
			and pd.Antiguedad =  case when (datediff(year, e.FechaAntiguedad, p.FechaFinPago)) < 1 then 1 else cast(datediff(year, e.FechaAntiguedad, p.FechaFinPago) as int) end
GO

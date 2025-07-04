USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoCapturasPorConceptosImpreso](
	@CatalogoConceptos varchar(max)
	,@ClaveEmpleadoInicial varchar(20) = '0'
	,@ClaveEmpleadoFinal varchar(20) ='zzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
	,@IDPeriodoInicial int
	,@TipoNomina int 
	,@Departamentos				  varchar(max) = ''
	,@Sucursales				  varchar(max) = ''
	,@Puestos					  varchar(max) = ''
	,@RazonesSociales			  varchar(max) = ''
	,@Divisiones				  varchar(max) = ''
	,@IDUsuario int
)as
	--declare 
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int = 1

	--insert into @dtFiltros(Catalogo,Value)
	--values('IDPeriodoInicial','98')
	--	--,('CatalogoConceptos','219')

	declare 
		@empleados [RH].[dtEmpleados]      
		,@dtFiltros Nomina.dtFiltrosRH  
		 
		,@Periodo varchar(max)
		--,@CatalogoConceptos nvarchar(max)   
		,@FechaIniPeriodo  date        
		,@FechaFinPeriodo  date        
	;    

		select @ClaveEmpleadoInicial = case when @ClaveEmpleadoInicial is null or @ClaveEmpleadoInicial = '' then '0' else @ClaveEmpleadoInicial end
		,@ClaveEmpleadoFinal = case when @ClaveEmpleadoFinal is null or @ClaveEmpleadoFinal = '' then 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzz' else @ClaveEmpleadoFinal end

	insert into @dtFiltros(Catalogo,Value)
	values
		('Departamentos',@Departamentos)
		,('RazonesSociales',@RazonesSociales)
		,('Divisiones',@Divisiones)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)

	select 
		@FechaIniPeriodo = p.FechaInicioPago
		,@FechaFinPeriodo = p.FechaFinPago	
		,@Periodo = p.Descripcion
	from Nomina.tblCatPeriodos p with (nolock)
	where p.IDPeriodo = @IDPeriodoInicial


	insert into @empleados        
    exec [RH].[spBuscarEmpleados] 
		@IDTipoNomina = @TipoNomina
		,@EmpleadoIni = @ClaveEmpleadoInicial
		,@EmpleadoFin = @ClaveEmpleadoFinal
		,@FechaIni=@fechaIniPeriodo
		, @Fechafin = @fechaFinPeriodo 
		,@dtFiltros = @dtFiltros
		, @IDUsuario = @IDUsuario     
    
	Select  
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Nombre
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.Division
		,replace(replace(replace(c.Codigo+'_'+c.Descripcion,' ','_'),'-',''),'.','') as Concepto
		,isnull(dp.CantidadMonto,0) as CantidadMonto  
		,isnull(dp.CantidadDias,0)  as CantidadDias  
		,isnull(dp.CantidadVeces,0) as CantidadVeces  
		,isnull(dp.CantidadOtro1,0) as CantidadOtro1  
		,isnull(dp.CantidadOtro2,0) as CantidadOtro2  
		,isnull(dp.ImporteGravado,0) as ImporteGravado  
		,isnull(dp.ImporteExcento,0) as ImporteExento  
		,isnull(dp.ImporteTotal1,0) as ImporteTotal1  
		,isnull(dp.ImporteTotal2,0) as ImporteTotal2 
		,isnull(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales 
		,@Periodo as Periodo
		,Titulo = 'REPORTE DE TOTALES POR CONCEPTOS' 
	from  Nomina.tblDetallePeriodo dp with (nolock) 
		inner join Nomina.tblCatPeriodos P with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo  
		inner join Nomina.tblCatConceptos c with (nolock)  
			on C.IDConcepto = dp.IDConcepto  
		Inner join Nomina.tblCatTipoConcepto tc  with (nolock) 
			on tc.IDTipoConcepto = c.IDTipoConcepto  
		inner join @empleados e  
			on dp.IDEmpleado = e.IDEmpleado  
	where p.IDPeriodo = @IDPeriodoInicial
		and (dp.IDConcepto in (select cast(Item as int) from App.Split(@CatalogoConceptos,',')) or @CatalogoConceptos is null)
		and (
		isnull(dp.CantidadMonto,0)
		+isnull(dp.CantidadDias,0) 
		+isnull(dp.CantidadVeces,0)
		+isnull(dp.CantidadOtro1,0)
		+isnull(dp.CantidadOtro2,0)
		+isnull(dp.ImporteTotal1,0)
		+isnull(dp.ImporteTotal2,0)
		) <> 0
	order by c.OrdenCalculo,e.ClaveEmpleado
GO

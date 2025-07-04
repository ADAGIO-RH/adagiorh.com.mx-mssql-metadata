USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoISN](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        
    
	--declare    
	--  @dtFiltros Nomina.dtFiltrosRH     
	--  ,@IDUsuario int = 1    
    
    
	--  insert @dtFiltros    
	--  Values    
	--  --('Departamentos','5')    
	--  --,    
	--  ('IDTipoNomina','4')    
	--  ,('IDPeriodoInicial','76')    
        
	declare 
		@empleados [RH].[dtEmpleados]            
		,@IDPeriodoSeleccionado int=0            
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]            
		,@IDTipoNomina		int         
		,@fechaIniPeriodo	date            
		,@fechaFinPeriodo	date   
		,@IDConcepto540		int           
	;        
      
	select @IDConcepto540 = IDConcepto from Nomina.tblCatConceptos with (nolock) where Codigo = '540'  
      
	/* Se buscan el periodo seleccionado */        
	insert into @periodo      
	select    *   
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
		(((IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))  
		)                       
		and IDMes in (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))   
	   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))                      
    
	--Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')  
	--Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),',')  
	--select * from @periodo      
   
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */            
    insert into @empleados            
    exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario         
      
	Select   
		E.ClaveEmpleado as ClaveEmpleado,  
		E.NOMBRECOMPLETO as NombreCompleto,  
		isnull(e.Departamento  ,'SIN DEPARTAMENTO') as Departamento,    
		isnull(e.Sucursal,'SIN SUCURSAL') as Sucursal,    
		isnull(e.Puesto,'SIN PUESTO') as Puesto,    
		isnull(e.RazonSocial  ,'SIN RAZÓN SOCIAL') as [Razon Social],    
		isnull(e.RegPatronal ,'SIN REGISTRO PATRONAL') as [Registro Patronal],    
		--replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.','') as Concepto,      
		SUM(isnull(dp.ImporteTotal1,0)) as [Importe ISN]
	from @periodo P      
		inner join Nomina.tblDetallePeriodo dp      
			on p.IDPeriodo = dp.IDPeriodo      
		inner join Nomina.tblCatConceptos c      
			on C.IDConcepto = dp.IDConcepto    
				and c.IDConcepto =  @IDConcepto540  
		left join @empleados e      
			on dp.IDEmpleado = e.IDEmpleado      
	Where (e.IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))  
		)  
	Group by 
		c.Descripcion,     
		e.RazonSocial,    
		e.RegPatronal,    
		e.Departamento,    
		e.ClaveEmpleado,    
		e.NOMBRECOMPLETO,    
		e.Puesto,    
		e.Sucursal,    
		c.Codigo      
	ORDER BY E.Sucursal, E.ClaveEmpleado, E.NOMBRECOMPLETO
GO

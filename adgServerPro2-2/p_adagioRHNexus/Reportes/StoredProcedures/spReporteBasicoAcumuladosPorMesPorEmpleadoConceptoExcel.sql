USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoAcumuladosPorMesPorEmpleadoConceptoExcel](        
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
		,@IDTipoNomina int         
		,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date   
		,@CatalogoConceptos varchar(max)
		,@IDConcepto int = 0
	;        

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
						else 0  
						END  

	set @IDConcepto = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CatalogoConceptos'),',')) 
							then (Select top 1 cast(item as int) 
								from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CatalogoConceptos'),','))  
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
	from Nomina.tblCatPeriodos With (nolock)      
	where      
		(((IDTipoNomina in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
		or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoNomina' and isnull(Value,'')<>''))  
		)                       
		   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))   
		and isnull(Cerrado,0) = 1
    
	
	select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  
	--select  @fechaIniPeriodo,  @fechaFinPeriodo 
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */            
    insert into @empleados            
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo 
	,@Fechafin = @fechaFinPeriodo
	,@dtFiltros = @dtFiltros
	,@IDUsuario = @IDUsuario         
	
	DECLARE  
		@DinamicColumns nvarchar(max)
		,@DinamicColumnsISNULL nvarchar(max)
		,@DinamicColumnsTotal nvarchar(max)
		,@query  AS NVARCHAR(MAX)

	select @DinamicColumns='[ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE]'
		  ,@DinamicColumnsISNULL= 'isnull([ENERO],0) as ENERO,isnull([FEBRERO],0) as FEBRERO,isnull([MARZO],0) as MARZO,isnull([ABRIL],0) as ABRIL,isnull([MAYO],0) as MAYO,isnull([JUNIO],0) as JUNIO,isnull([JULIO],0) as JULIO,isnull([AGOSTO],0) as AGOSTO,isnull([SEPTIEMBRE],0) as SEPTIEMBRE,isnull([OCTUBRE],0) as OCTUBRE,isnull([NOVIEMBRE],0) as NOVIEMBRE,isnull([DICIEMBRE],0) as DICIEMBRE'
		  ,@DinamicColumnsTotal = ',isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL'

	SELECT   ClaveEmpleado as [CLAVE EMPLEADO]
			,NombreCompleto as [NOMBRE COMPLETO]
	        ,Codigo as CODIGO
			,Concepto AS CONCEPTO
			,isnull([ENERO],0) as ENERO
			,isnull([FEBRERO],0) as FEBRERO
			,isnull([MARZO],0) as MARZO
			,isnull([ABRIL],0) as ABRIL
			,isnull([MAYO],0) as MAYO
			,isnull([JUNIO],0) as JUNIO
			,isnull([JULIO],0) as JULIO
			,isnull([AGOSTO],0) as AGOSTO
			,isnull([SEPTIEMBRE],0) as SEPTIEMBRE
			,isnull([OCTUBRE],0) as OCTUBRE
			,isnull([NOVIEMBRE],0) as NOVIEMBRE
			,isnull([DICIEMBRE],0) as DICIEMBRE
			,isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0)  + isnull([ABRIL],0)		+ isnull([MAYO],0)    + 
			 isnull([JUNIO],0) + isnull([JULIO],0)	 + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0)  + isnull([OCTUBRE],0) + 
			 isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL 
		from (
				select
					e.ClaveEmpleado
					,e.NOMBRECOMPLETO as NombreCompleto
					,c.Codigo
					,c.DESCRIPCION as Concepto
					,m.Nombre as Mes
					,SUM(isnull(dp.ImporteTotal1,0)) as Total
				from Nomina.tblDetallePeriodo dp with (nolock) 
					inner join @periodo P on dp.IDPeriodo = P.IDPeriodo
					inner join (select 
									ccc.*
									,tc.Descripcion as TipoConcepto
									,crr.Orden
								from Nomina.tblCatConceptos ccc with (nolock) 
									inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
									inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
								) c on c.IDConcepto = dp.IDConcepto
					inner join Utilerias.tblMeses m with (nolock) on P.IDMes = m.IDMes
					inner join  @empleados e on dp.IDEmpleado = e.IDEmpleado
				where c.IDConcepto = @IDConcepto
				Group by e.ClaveEmpleado,e.NOMBRECOMPLETO , c.Codigo,c.DESCRIPCION,m.Nombre
            ) x
            pivot 
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p order by ClaveEmpleado asc
GO

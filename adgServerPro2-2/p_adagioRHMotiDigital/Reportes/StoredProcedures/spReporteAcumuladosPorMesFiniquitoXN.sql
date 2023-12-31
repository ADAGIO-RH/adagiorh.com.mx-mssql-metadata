USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteAcumuladosPorMesFiniquitoXN](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        
    if object_id('tempdb..#Tempuser') is not null drop table #Tempuser;
	if object_id('tempdb..#TempEmpresa') is not null drop table #TempEmpresa;
	if object_id('tempdb..#TempTipoNomina') is not null drop table #TempTipoNomina;
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
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]  
		--,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date           
	;        

	
	
	   --se creo esta parte para poder filtrar a la empresa o al tipo de nomina cuando no se le aplica filtro

	create table #TempTipoNomina
	(idtiponomina int  )

	create table #TempEmpresa
	(idempresa int  )

	
	 if (Select Value from @dtFiltros where Catalogo = 'TipoNomina') > 0
	 begin
		insert into #TempTipoNomina select IDTipoNomina from nomina.tblCatTipoNomina where IDTipoNomina in (Select Value from @dtFiltros where Catalogo = 'TipoNomina')
	  end
	 else 
		insert into #TempTipoNomina select IDTipoNomina from nomina.tblCatTipoNomina

	 
	 if (Select Value from @dtFiltros where Catalogo = 'RazonesSociales')> 0
	 begin 
		insert into #TempEmpresa select idempresa from rh.tblempresa where idempresa in (select Value from @dtFiltros where Catalogo = 'RazonesSociales' )
	 end
	 else 
		insert into #TempEmpresa select idempresa from rh.tblEmpresa




      
	/* Se buscan el periodo seleccionado */        
	insert into @periodo      
	select       
		IDPeriodo      
		,IDTipoNomina      
		,Ejercicio      
		,ClavePeriodo      
		,Descripcion      
		,FechaInicioPago      
		,FechaFinPago      
		,FechaInicioIncidencia      
		,FechaFinIncidencia      
		,Dias      
		,AnioInicio      
		,AnioFin      
		,MesInicio      
		,MesFin      
		,IDMes      
		,BimestreInicio      
		,BimestreFin      
		,Cerrado      
		,General      
		,Finiquito      
		,isnull(Especial,0)      
	from Nomina.tblCatPeriodos With (nolock)      
	where      
		((                     
		 (IDMes between (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
			and (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
		)   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))   
		and isnull(Cerrado,0) = 1
    
	--select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */ 
	 
	--if  @fechaIniPeriodo is not null
	--	begin
	--		insert into @empleados            
	--		exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario         
	--	end


		select  
		hp.IDPeriodo,m.claveempleado,m.NOMBRECOMPLETO,hp.IDEmpleado,hp.IDSucursal,hp.IDPuesto,hp.IDRegPatronal,hp.IDCliente,hp.IDEmpresa,ce.NombreComercial,hp.IDArea,hp.IDDivision
		, p.IDMes,p.IDTipoNomina,p.Ejercicio,p.ClavePeriodo,p.Descripcion,p.MesInicio,p.MesFin,p.Finiquito,f.IDEstatusTimbrado as timbrado
		 into #Tempuser
					from rh.tblempleadosmaster m
					inner join [Nomina].[tblHistorialesEmpleadosPeriodos] hp on hp.idempleado=m.idempleado
					inner join @periodo p on p.IDPeriodo=hp.IDPeriodo
					inner join Facturacion.TblTimbrado f on f.IDHistorialEmpleadoPeriodo=hp.IDHistorialEmpleadoPeriodo
					inner join rh.tblEmpresa ce on ce.IdEmpresa=hp.IDEmpresa
				where  hp.IDEmpresa in (select IDEmpresa from #TempEmpresa ) and p.IDTipoNomina in (select IDTipoNomina from #TempTipoNomina) and f.IDEstatusTimbrado=2	
		 order by hp.IDEmpleado,p.IDMes
		 

		--	select ClaveEmpleado,IDPeriodo,ClavePeriodo,IDMes,Descripcion 
		--	from #Tempuser  
		--	group by ClaveEmpleado,IDPeriodo,ClavePeriodo,Descripcion,IDMes
		--	order by IDMes,IDPeriodo
		--return;



	DECLARE  
		@DinamicColumns nvarchar(max)
		,@DinamicColumnsISNULL nvarchar(max)
		,@DinamicColumnsTotal nvarchar(max)
		,@query  AS NVARCHAR(MAX)

	select @DinamicColumns='[ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE]'
		  ,@DinamicColumnsISNULL= 'isnull([ENERO],0) as ENERO,isnull([FEBRERO],0) as FEBRERO,isnull([MARZO],0) as MARZO,isnull([ABRIL],0) as ABRIL,isnull([MAYO],0) as MAYO,isnull([JUNIO],0) as JUNIO,isnull([JULIO],0) as JULIO,isnull([AGOSTO],0) as AGOSTO,isnull([SEPTIEMBRE],0) as SEPTIEMBRE,isnull([OCTUBRE],0) as OCTUBRE,isnull([NOVIEMBRE],0) as NOVIEMBRE,isnull([DICIEMBRE],0) as DICIEMBRE'
		  ,@DinamicColumnsTotal = ',isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL'

	

	 SELECT 
			ClaveEmpleado
			,[Nombre Completo]
			,[Razon Social]
			,Periodo
			,Codigo
			,Concepto
			,TipoConcepto
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
					 ,e.NOMBRECOMPLETO as [Nombre Completo]
					 ,e.NombreComercial as [Razon Social]
					 ,e.descripcion as Periodo
					 ,e.IDPeriodo as numero
					,c.Codigo
					,c.DESCRIPCION as Concepto
					,c.TipoConcepto
					,m.Nombre as Mes
					,SUM(isnull(dp.ImporteTotal1,0)) as Total
					,c.Orden as OrdenCalculo
					,case when c.IDTipoConcepto = 1 then 1 
						   WHEN c.IDTipoConcepto = 4 then 2
						   WHEN c.IDTipoConcepto = 2 then 3
						   WHEN c.IDTipoConcepto = 3 then 4
						   WHEN c.IDTipoConcepto = 6 then 5
						   WHEN c.IDTipoConcepto = 5 then 6
						else 0
						end as ordenshow
				from Nomina.tblDetallePeriodo dp with (nolock)
					inner join #Tempuser e on dp.IDEmpleado = e.IDEmpleado and dp.IDPeriodo=e.IDPeriodo
					inner join (select 
									ccc.*
									,tc.Descripcion as TipoConcepto
									,crr.Orden
								from Nomina.tblCatConceptos ccc with (nolock) 
									inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
									inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
								) c on c.IDConcepto = dp.IDConcepto
					inner join Utilerias.tblMeses m with (nolock) on e.IDMes = m.IDMes
				Group by e.ClaveEmpleado,e.NOMBRECOMPLETO,e.Descripcion,e.IDPeriodo,c.Codigo,c.IDTipoConcepto,c.DESCRIPCION,m.Nombre, c.Orden,c.TipoConcepto,e.NombreComercial
            ) x
            pivot 
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p order by numero,ordenshow,OrdenCalculo asc
GO

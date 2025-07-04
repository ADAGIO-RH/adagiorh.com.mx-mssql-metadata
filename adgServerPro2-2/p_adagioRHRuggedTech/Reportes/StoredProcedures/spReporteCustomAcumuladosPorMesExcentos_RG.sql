USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

			
CREATE proc [Reportes].[spReporteCustomAcumuladosPorMesExcentos_RG](        
	@dtFiltros Nomina.dtFiltrosRH readonly        
	,@IDUsuario int        
) as        
    
	declare 
		@empleados [RH].[dtEmpleados]            
		,@IDPeriodoSeleccionado int=0            
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]            
		,@IDTipoNomina int         
		,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date           
	;        

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
							 then (Select top 1 cast(item as int) 
								   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
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
		and (IDMes between (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
			and (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
		)   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))   
		and isnull(Cerrado,0) = 1
	select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */            
    insert into @empleados            
    exec [RH].[spBuscarEmpleadosEnIntervalos] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario         


   
	DECLARE  
		@DinamicColumns nvarchar(max)
		,@DinamicColumnsISNULL nvarchar(max)
		,@DinamicColumnsTotal nvarchar(max)
		,@query  AS NVARCHAR(MAX)

	select @DinamicColumns='[ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE]'
		  ,@DinamicColumnsISNULL= 'isnull([ENERO],0) as ENERO,isnull([FEBRERO],0) as FEBRERO,isnull([MARZO],0) as MARZO,isnull([ABRIL],0) as ABRIL,isnull([MAYO],0) as MAYO,isnull([JUNIO],0) as JUNIO,isnull([JULIO],0) as JULIO,isnull([AGOSTO],0) as AGOSTO,isnull([SEPTIEMBRE],0) as SEPTIEMBRE,isnull([OCTUBRE],0) as OCTUBRE,isnull([NOVIEMBRE],0) as NOVIEMBRE,isnull([DICIEMBRE],0) as DICIEMBRE'
		  ,@DinamicColumnsTotal = ',isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL'

	SELECT Codigo
			,Concepto
			,TipoConcepto as [TIPO CONCEPTO]
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
					c.Codigo
					,c.DESCRIPCION as Concepto
					,c.TipoConcepto
					,m.Nombre as Mes
					,SUM(isnull(dp.ImporteExcento,0)) as Total
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
					inner join @periodo P on dp.IDPeriodo = P.IDPeriodo
                    
					inner join (select 
									ccc.*
									,tc.Descripcion as TipoConcepto
									,crr.Orden
								from Nomina.tblCatConceptos ccc with (nolock) 
									inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto and tc.IDTipoConcepto in (1,4)
									inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
								) c on c.IDConcepto = dp.IDConcepto
					inner join Utilerias.tblMeses m with (nolock) on P.IDMes = m.IDMes
					inner join @empleados e on dp.IDEmpleado = e.IDEmpleado
                    inner join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDPeriodo = P.IDPeriodo and e.IDEmpleado = hep.IDEmpleado
                    where ( hep.IDArea = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')) IS NULL )
                    AND ( hep.IDCentroCosto = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),',')) IS NULL )
                    AND ( hep.IDDepartamento = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),',')) IS NULL )
                    AND ( hep.IDSucursal = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),',')) IS NULL )  
                    AND ( hep.IDPuesto = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),',')) IS NULL )   
                    AND ( hep.IDRegPatronal = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')) IS NULL ) 
                    AND ( hep.IDCliente = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')) IS NULL )
                    AND ( hep.IDEmpresa = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')) IS NULL )  
                    AND ( hep.IDDivision = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')) IS NULL )  
                    AND ( hep.IDClasificacionCorporativa = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')) IS NULL ) 
                    AND ( hep.IDRegion = (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),','))  
                            or  (Select top 1 cast(item as int) 
										   from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')) IS NULL )     

				Group by c.Codigo,c.IDTipoConcepto,c.DESCRIPCION,m.Nombre, c.Orden,c.TipoConcepto
            ) x
            pivot 
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p order by ordenshow,OrdenCalculo asc

GO

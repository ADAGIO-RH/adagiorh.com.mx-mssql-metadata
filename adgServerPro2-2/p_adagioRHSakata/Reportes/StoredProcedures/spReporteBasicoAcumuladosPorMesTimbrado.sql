USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoAcumuladosPorMesTimbrado](        
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
		,@empleadosTemp [RH].[dtEmpleados]  
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
    
	select  @fechaIniPeriodo = MIN(FechaInicioPago),  @fechaFinPeriodo = MAX(FechaFinPago) from @periodo  

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */ 
	 
	if  @fechaIniPeriodo is not null
		begin
			insert into @empleadosTemp            
			exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina
			--,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo, @dtFiltros = @dtFiltros
			, @IDUsuario = @IDUsuario         
		end


		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(cc.Descripcion		,e.CentroCosto	)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(d.Descripcion		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(p.Descripcion		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(c.NombreComercial	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(a.Descripcion		,e.Area			)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(div.Descripcion	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(r.Descripcion		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)

		from @empleadosTemp e
			join ( select hep.*
					from Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)
						join @periodo p on hep.IDPeriodo = p.IDPeriodo
				) historiales on e.IDEmpleado = historiales.IDEmpleado
			left join RH.tblCatCentroCosto cc		with(nolock) on cc.IDCentroCosto = historiales.IDCentroCosto
		 	left join RH.tblCatDepartamentos d		with(nolock) on d.IDDepartamento = historiales.IDDepartamento
			left join RH.tblCatSucursales s			with(nolock) on s.IDSucursal		= historiales.IDSucursal
			left join RH.tblCatPuestos p			with(nolock) on p.IDPuesto			= historiales.IDPuesto
			left join RH.tblCatRegPatronal rp		with(nolock) on rp.IDRegPatronal	= historiales.IDRegPatronal
			left join RH.tblCatClientes c			with(nolock) on c.IDCliente		= historiales.IDCliente
			left join RH.tblEmpresa emp				with(nolock) on emp.IDEmpresa	= historiales.IDEmpresa
			left join RH.tblCatArea a				with(nolock) on a.IDArea		= historiales.IDArea
			left join RH.tblCatDivisiones div		with(nolock) on div.IDDivision	= historiales.IDDivision
			left join RH.tblCatRegiones r			with(nolock) on r.IDRegion		= historiales.IDRegion
			left join RH.tblCatRazonesSociales rs	with(nolock) on rs.IDRazonSocial = historiales.IDRazonSocial
			left join RH.tblCatClasificacionesCorporativas clasificacionC with(nolock)	on clasificacionC.IDClasificacionCorporativa = historiales.IDClasificacionCorporativa

		
		insert into @empleados
		exec [RH].[spFiltrarEmpleadosDesdeLista] @dtEmpleados=	@empleadosTemp, @dtFiltros= @dtFiltros, @IDTipoNomina =  @IDTipoNomina, @IDUsuario = @IDUsuario

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
					c.Codigo
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
					left join Nomina.tblHistorialesEmpleadosPeriodos hep
						on hep.IDPeriodo = dp.IDPeriodo and hep.IDEmpleado = dp.IDEmpleado
					inner join Facturacion.TblTimbrado timbrado 
						on timbrado.IDHistorialEmpleadoPeriodo = hep.IDHistorialEmpleadoPeriodo and timbrado.IDEstatusTimbrado = 2 and timbrado.actual = 1
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
					inner join @empleados e on dp.IDEmpleado = e.IDEmpleado
				Group by c.Codigo,c.IDTipoConcepto,c.DESCRIPCION,m.Nombre, c.Orden,c.TipoConcepto
            ) x
            pivot 
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p order by ordenshow,OrdenCalculo asc
GO

USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReportePolizadeTequilaSanMatias](
  @dtFiltros Nomina.dtFiltrosRH readonly    
 ,@IDUsuario int    
) as    
    
declare @empleados [RH].[dtEmpleados]        
 ,@IDPeriodoSeleccionado int=0        
 ,@periodo [Nomina].[dtPeriodos]        
 ,@configs [Nomina].[dtConfiguracionNomina]        
 ,@Conceptos [Nomina].[dtConceptos]        
 ,@IDTipoNomina int     
 ,@fechaIniPeriodo  date        
 ,@fechaFinPeriodo  date 
 ,@Cerrado bit = 0
 ,@General bit = 0
 --,@Especial bit = 0
 ;    
  
 set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
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
  from Nomina.tblCatPeriodos  
 where   
   ((IDPeriodo in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))                   
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'IDPeriodoInicial' and isnull(Value,'')<>''))))                  
    
  select top 1 @fechaIniPeriodo = FechaInicioPago,  @fechaFinPeriodo = FechaFinPago, @Cerrado = Cerrado,@General = ISNULL(general,0) from @periodo  
  

  
  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */     
  IF(@General = 1 )
  BEGIN
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario  
	--@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     
	
  END
  ELSE
  BEGIN
	 insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   
  END
	
	
	
	if (@Cerrado = 1)
	begin
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

		from @empleados e
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

	end;
	

	
  
select * from (
	Select  
			--PERCEPCIONES
			-------CARGO SUMA IMPORTE GRAVADO
            -------EXCLUYE CODIGO 323
            -------SOLO PERCEPCIONES
            
            EMPRESA = 'SANMATIAS'
			,FOLIO = ''
			,PARTIDA = ''
			,C.CuentaCargo as CUENTACONTABLE
		   ,CASE WHEN SUM(isnull(dp.ImporteGravado,0)) > 0 THEN SUM(dp.ImporteGravado) 
				else 
					case when c.Codigo = '164'	THEN 	SUM(dp.ImporteTotal1) 
				end
			END as CARGO 
		   ,0 as ABONO
		   ,'' as UNIDADNEGOCIO
		   ,'' AS AREA
		   ,cd.CuentaContable   as CENTROCOSTO
		   ,C.Descripcion as CONCEPTO
		   ,EMPRESADOC = ''
		   ,OPERACIONDOC = ''
		   ,FOLIODOC = ''
		   ,MODIFICABLE = 'S'
		   ,NOTA = ''
		   --,e.ClaveEmpleado
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaCargo <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '323') --PRESTAMO PERSONAL
			and c.IDTipoConcepto in (1)
			and isnull(dp.ImporteTotal1,0) > 0
			and ( isnull(dp.ImporteGravado,0) > 0 or c.Codigo = '164' )
 			group by C.CuentaCargo,
			cd.CuentaContable
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		--   ,e.ClaveEmpleado

    	UNION ALL

		Select  
			--PERCEPCIONES excentas
			EMPRESA = 'SANMATIAS'
			,FOLIO = ''
			,PARTIDA = ''
			,C.CuentaCargo as CUENTACONTABLE
		   --,CASE WHEN SUM(isnull(dp.ImporteExcento,0)) > 0 and c.Codigo not in ( '121','123','130','131','132','133','134') THEN SUM(dp.ImporteExcento) else 0 END as CARGO
           ,CASE WHEN SUM(isnull(dp.ImporteExcento,0)) > 0 and c.Codigo not in ( '121','123','130','131','132','133','134') THEN SUM(dp.ImporteExcento) else 0 END as CARGO --Comentar, quitar 131
		   --and c.Codigo not in ( '121','123','130','131','132','133','134') THEN SUM(dp.ImporteExcento) else 0 END as CARGO 
		   ,0 as ABONO
		   ,'' as UNIDADNEGOCIO
		   ,'' AS AREA
		   ,cd.CuentaContable   as CENTROCOSTO
		   ,C.Descripcion as CONCEPTO
		   ,EMPRESADOC = ''
		   ,OPERACIONDOC = ''
		   ,FOLIODOC = ''
		   ,MODIFICABLE = 'S'
		   ,NOTA = ''
		   --,e.ClaveEmpleado
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaCargo <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '323') --PRESTAMO PERSONAL
			and c.IDTipoConcepto in (1)
			and isnull(dp.ImporteTotal1,0) > 0
			and isnull(dp.ImporteTotal1,0) = isnull(dp.ImporteExcento,0) --Comentar
			
 			group by C.CuentaCargo,
			cd.CuentaContable
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		--   ,e.ClaveEmpleado

	UNION ALL


		Select  
			--OTROS TIPOS PAGO
			EMPRESA = 'SANMATIAS'
			,FOLIO = ''
			,PARTIDA = ''
			,C.CuentaCargo as CUENTACONTABLE
		   ,SUM(dp.ImporteTotal1) as CARGO 
		   ,0 as ABONO
		   ,'' as UNIDADNEGOCIO
		   ,'' AS AREA
		   ,cd.CuentaContable   as CENTROCOSTO
		   ,C.Descripcion as CONCEPTO
		   ,EMPRESADOC = ''
		   ,OPERACIONDOC = ''
		   ,FOLIODOC = ''
		   ,MODIFICABLE = 'S'
		   ,NOTA = ''
		   --,e.ClaveEmpleado
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaCargo <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '323') --PRESTAMO PERSONAL
			and isnull(dp.ImporteTotal1,0) > 0
			and c.IDTipoConcepto in (4)
 			group by C.CuentaCargo,
			cd.CuentaContable
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		--   ,e.ClaveEmpleado
	UNION ALL

		Select  
			--INFORMATIVOS
			EMPRESA = 'SANMATIAS'
			,FOLIO = ''
			,PARTIDA = ''
			,C.CuentaCargo as CUENTACONTABLE
		   ,SUM(dp.ImporteTotal1) as CARGO 
		   ,0 as ABONO
		   ,'' as UNIDADNEGOCIO
		   ,'' AS AREA
		   ,cd.CuentaContable   as CENTROCOSTO
		   ,C.Descripcion as CONCEPTO
		   ,EMPRESADOC = ''
		   ,OPERACIONDOC = ''
		   ,FOLIODOC = ''
		   ,MODIFICABLE = 'S'
		   ,NOTA = ''
		   --,e.ClaveEmpleado
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaCargo <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '323') --PRESTAMO PERSONAL
			and isnull(dp.ImporteTotal1,0) > 0
			and c.IDTipoConcepto in (3)
 			group by C.CuentaCargo,
			cd.CuentaContable
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		--   ,e.ClaveEmpleado

	UNION ALL



		Select  
			--PERCEPCIONES
			EMPRESA = 'SANMATIAS'
			,FOLIO = ''
			,PARTIDA = ''
			,C.CuentaAbono as CUENTACONTABLE
		    ,0 as CARGO
		    ,SUM(dp.ImporteTotal1) as ABONO
		  ,'' as UNIDADNEGOCIO
		   ,'' AS AREA
		   ,cd.CuentaContable   as CENTROCOSTO
		   ,C.Descripcion as CONCEPTO
		   ,EMPRESADOC = ''
		   ,OPERACIONDOC = ''
		   ,FOLIODOC = ''
		   ,MODIFICABLE = 'S'
		   ,NOTA = ''
		  -- ,e.ClaveEmpleado
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto and C.CuentaAbono <> ''  
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo not in ( '323') --PRESTAMO PERSONAL
			and c.IDTipoConcepto not in (1,4)
			and isnull(dp.ImporteTotal1 ,0) <> 0
			group by C.CuentaCargo,
			cd.CuentaContable
		   ,cd.Descripcion
		   ,C.CuentaAbono
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,cd.CuentaContable
		  -- ,e.ClaveEmpleado

		UNION ALL
				Select  
			--PERCEPCIONES
			EMPRESA = 'SANMATIAS'
			,FOLIO = ''
			,PARTIDA = ''
			,e.CuentaContable as CUENTACONTABLE
		    ,0 as CARGO
		    ,SUM(dp.ImporteTotal1) as ABONO
			  ,'' as UNIDADNEGOCIO
		   ,'' AS AREA
		   ,cd.CuentaContable   as CENTROCOSTO
		   ,C.Descripcion as CONCEPTO
		   ,EMPRESADOC = ''
		   ,OPERACIONDOC = ''
		   ,FOLIODOC = ''
		   ,MODIFICABLE = 'S'
		   ,NOTA = ''
		   --,e.ClaveEmpleado
	from @periodo P  
			inner join Nomina.tblDetallePeriodo dp with (nolock) 
				on p.IDPeriodo = dp.IDPeriodo and dp.ImporteTotal1 <> 0
			inner join Nomina.tblCatConceptos c  with (nolock)
				on C.IDConcepto = dp.IDConcepto 
			inner join Nomina.tblCatTipoConcepto tc  with (nolock)
				on tc.IDTipoConcepto = c.IDTipoConcepto  
			inner join @empleados e
				on dp.IDEmpleado = e.IDEmpleado  
			inner join RH.tblCatDepartamentos cd on e.IDDepartamento = cd.IDDepartamento
			where c.Codigo in ( '323') --PRESTAMO PERSONAL
			group by 
            C.CuentaCargo,
			cd.CuentaContable
		   ,cd.Descripcion
		   ,C.CuentaCargo
		   ,cd.Descripcion
		   ,c.Codigo
		   ,c.Descripcion
		   ,P.Descripcion
		   ,e.CuentaContable
			--,e.ClaveEmpleado
) tbl order by CENTROCOSTO;
GO

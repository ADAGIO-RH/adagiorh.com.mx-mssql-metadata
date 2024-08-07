USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [p_adagioRHPoliAcero]
--GO
--/****** Object:  StoredProcedure [Reportes].[spReporteBasicoDeNominaPeriodoIndividual]    Script Date: 05/11/2020 12:10:40 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE proc [Reportes].[spReportePorConceptosDepartamentos](
	@TipoNomina int = ''
	,@IDPeriodoInicial int = ''
	,@CatalogoConceptos varchar(max)
	,@RazonesSociales varchar(max) = ''
	,@Departamentos varchar(max) = ''
	,@Clientes varchar(max) = ''
 	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	--declare -- Params
	--	@TipoNomina int = '7'
	--	,@IDPeriodoInicial int = '99'
	--	,@CatalogoConceptos varchar(max) = '29,10,91,17,5,6,9'
	--	,@RazonesSociales varchar(max) = ''
	--	,@Departamentos varchar(max) = '17,30'
	--	,@Clientes varchar(max) = '1'
 --		,@IDUsuario int = 1

	declare	
		@dtFiltros Nomina.dtFiltrosRH

	insert into @dtFiltros(Catalogo,Value)
	values
		('Departamentos',@Departamentos)
		,('RazonesSociales',@RazonesSociales)

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@IDTipoNomina int   
		,@IDCliente int
		,@Cerrado bit = 1
	;  
	set @IDTipoNomina = cast(@TipoNomina as int)
	
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
	where IDTipoNomina = @IDTipoNomina and IDPeriodo = @IDPeriodoInicial

	select top 1 @Cerrado = isnull(Cerrado,0) from @periodo
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
	order by IDEmpleado

	--select * from @empleadosTemp

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

	end;
	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario

	--select * from @Empleados

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData
	if object_id('tempdb..#tempEmpleadosConceptos') is not null drop table #tempEmpleadosConceptos



	select distinct 
		c.IDConcepto,
		c.Codigo,
		replace(replace(replace(replace(replace(substring(c.Descripcion,1,11),' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		c.Orden as OrdenCalculo,
		case when c.IDTipoConcepto in (1,4) then 1
			 when c.IDTipoConcepto = 2 then 2
			 when c.IDTipoConcepto = 3 then 3
			 when c.IDTipoConcepto = 6 then 4
			 when c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn
	into #tempConceptos
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			left join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where (ccc.IDConcepto in (select cast(Item as int) from App.Split(@CatalogoConceptos,',')) or @CatalogoConceptos is null)
		) c 


	select e.IDEmpleado, e.ClaveEmpleado, e.NOMBRECOMPLETO, isnull(d.Codigo,'000')+' - '+isnull(e.Departamento,'SIN DEPARTAMENTO') as DEPARTAMENTO, c.*
	INTO #tempEmpleadosConceptos
	from @Empleados e
		left join RH.tblCatDepartamentos d on d.IDDepartamento = e.IDDepartamento
		, #tempConceptos c
	--select * from #tempConceptos
	--select * from @empleados
	--select * from @periodo
	
	--select * from #tempEmpleadosConceptos order by ClaveEmpleado, OrdenCalculo
	
	select 
		c.ClaveEmpleado as CLAVE
		, c.Codigo
		, c.Concepto
		, c.DEPARTAMENTO
		, isnull(dp.ImporteTotal1,0) as ImporteTotal1
		, c.NOMBRECOMPLETO as NOMBRE
		, c.OrdenCalculo
		, dp.Periodo
	from #tempEmpleadosConceptos c
		left join ( select dp.IDEmpleado, dp.IDConcepto,dp.ImporteTotal1, p.Descripcion as Periodo
						from Nomina.tblDetallePeriodo dp with (nolock) 
						join @periodo P on p.IDPeriodo = dp.IDPeriodo
				) dp on dp.IDConcepto = c.IDConcepto and dp.IDEmpleado = c.IDEmpleado
	--where c.ClaveEmpleado = '00001'
	--where c.IDConcepto in (2,29,10,91,17,5,6,9)
--	group by  dp.ClaveEmpleado,c.Codigo, c.Concepto, dp.IDConcepto
	
	--return
	--select * from #tempConceptos
	--Select
	--	t.ClaveEmpleado		as CLAVE
	--	,t.NOMBRECOMPLETO	as NOMBRE
	--	,t.Departamento		as DEPARTAMENTO
	--	,c.Codigo
	--	,c.Concepto
	--	,c.OrdenCalculo
	----	,SUM(isnull(t.ImporteTotal1,0)) as ImporteTotal1
	--	,isnull(t.ImporteTotal1,0) as ImporteTotal1
	----into #tempData

	--from #tempConceptos c
	--	left join (
	--		select e.ClaveEmpleado, e.NOMBRECOMPLETO, e.Departamento,dp.IDConcepto,dp.ImporteTotal1
	--		from Nomina.tblDetallePeriodo dp with (nolock) 
	--			join @periodo P on p.IDPeriodo = dp.IDPeriodo
	--			join @empleados e on dp.IDEmpleado = e.IDEmpleado
	--	) as t on c.IDConcepto = t.IDConcepto

	--from @periodo P
	--	inner join Nomina.tblDetallePeriodo dp with (nolock) 
	--		on p.IDPeriodo = dp.IDPeriodo
	--	left join #tempConceptos c
	--		on C.IDConcepto = dp.IDConcepto
	--	inner join @empleados e
	--		on dp.IDEmpleado = e.IDEmpleado
	--Group by 
	--	t.ClaveEmpleado
	--	,t.NOMBRECOMPLETO
	--	,c.Codigo
	--	,c.Concepto
	--	,c.OrdenCalculo
	--	,t.Departamento
	--ORDER BY t.Departamento, t.ClaveEmpleado, c.OrdenCalculo ASC


	--select e.ClaveEmpleado, e.NOMBRECOMPLETO, e.Departamento,dp.IDConcepto,dp.ImporteTotal1
	--INTO #tempData
	--		from Nomina.tblDetallePeriodo dp with (nolock) 
	--			join @periodo P on p.IDPeriodo = dp.IDPeriodo
	--			join @empleados e on dp.IDEmpleado = e.IDEmpleado



	--Select
	--	t.ClaveEmpleado		as CLAVE
	--	,t.NOMBRECOMPLETO	as NOMBRE
	--	,t.Departamento		as DEPARTAMENTO
	--	,t.IDConcepto
	--	,c.IDConcepto
	--	,c.Codigo
	--	,c.Concepto
	--	,c.OrdenCalculo
	----	,SUM(isnull(t.ImporteTotal1,0)) as ImporteTotal1
	--	,isnull(t.ImporteTotal1,0) as ImporteTotal1
	----into #tempData
	--from  #tempData t 
	--	left join #tempConceptos c on c.IDConcepto = t.IDConcepto
	--where t.ClaveEmpleado ='00001'
	--ORDER BY t.Departamento, t.ClaveEmpleado, c.OrdenCalculo ASC

	--Select *
	--from  #tempData t 
	--where t.ClaveEmpleado ='00001'

























	--select * from #tempData

	--DECLARE @cols AS NVARCHAR(MAX),
	--	@query1  AS NVARCHAR(MAX),
	--	@query2  AS NVARCHAR(MAX),
	--	@colsAlone AS VARCHAR(MAX)
	--;

	--SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
	--			FROM #tempConceptos c
	--			GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
	--			ORDER BY c.OrdenCalculo,c.OrdenColumn
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'VARCHAR(MAX)') 
	--		,1,1,'');

	--SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
	--			FROM #tempConceptos c
	--			GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
	--			ORDER BY c.OrdenCalculo,c.OrdenColumn
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'VARCHAR(MAX)') 
	--		,1,1,'');

	--set @query1 = 'SELECT CLAVE,NOMBRE, DEPARTAMENTO, Codigo, ' + @cols + ' from 
	--			(
	--				select CLAVE
	--					,Nombre
	--					, Codigo
	--					, Concepto
	--					, DEPARTAMENTO
	--					, isnull(ImporteTotal1,0) as ImporteTotal1
	--				from #tempData
					
	--		   ) x'

	--set @query2 = '
	--			pivot 
	--			(
	--				 SUM(ImporteTotal1)
	--				for Concepto in (' + @colsAlone + ')
	--			) p 
	--			order by CLAVE
	--			'

	--			--print @query1
	--			--print @query2
	--exec( @query1 + @query2)
GO

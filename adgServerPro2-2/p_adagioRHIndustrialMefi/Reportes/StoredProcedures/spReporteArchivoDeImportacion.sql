USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteArchivoDeImportacion](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
--select * from Nomina.tblCatPeriodos
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('TipoNomina',4)
	--	  ,('IDPeriodoInicial',29)

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDCliente int
		,@Cerrado bit = 1
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
       

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END


	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	
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

	select 
		@fechaIniPeriodo = FechaInicioPago
		,@fechaFinPeriodo = FechaFinPago 
		,@IDTipoNomina = IDTipoNomina 
		,@Cerrado = Cerrado 
	from @periodo
	where IDPeriodo = @IDPeriodoInicial

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo = @IDPeriodoInicial
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
    --insert into @empleados      
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.CentroCosto		)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Departamento	)
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
				,e.Area				= isnull(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Area	)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
				--,e.ClasificacionCorporativa		= isnull(clasificacionC.Descripcion, e.ClasificacionCorporativa)
				,e.ClasificacionCorporativa		= isnull(JSON_VALUE(clasificacionC.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')), e.ClasificacionCorporativa)

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

	insert into @empleados        
    exec [RH].[spBuscarEmpleados]
		@IDTipoNomina	= @IDTipoNomina,
		@dtFiltros		= @dtFiltros,
		@IDUsuario		= @IDUsuario



	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempData') is not null drop table #tempData

	

	select distinct 
		c.IDConcepto,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
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
		from 
		@periodo P
		right join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		right join Nomina.tblCatConceptos ccc with (nolock)
			on ccc.IDConcepto = dp.IDConcepto
		right join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto 
		where ccc.Codigo in ('004','386','003') or dp.ImporteTotal1 = 1 
		) c 
		--**FALTAS JUSTIFICADAS.** Codigo 004
		--**PERMISO SIN GOCE.** Codigo 386
		-- **INCAPACIDADES.** Codigo 003

	Select
		e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,FORMAT(e.FechaAntiguedad, 'dd/MM/yy') as FECHA_ANTIGUEDAD
		,e.SalarioDiario    as SUELDO_ACTUAL
		,c.Concepto
		,UPPER(isnull(Timbrado.UUID,'')) as UUID
		,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		right join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = p.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Concepto
		,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
		,e.FechaAntiguedad
		,e.SalarioDiario 
		,e.Division
		,e.CentroCosto
		,Timbrado.UUID
		,Estatustimbrado.Descripcion
		,Timbrado.Fecha
	ORDER BY e.ClaveEmpleado ASC

	DECLARE @cols AS NVARCHAR(MAX),
		@query1  AS NVARCHAR(MAX),
		@query2  AS NVARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenColumn,c.OrdenCalculo
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenColumn,c.OrdenCalculo
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT CLAVE,NOMBRE,PUESTO,DEPARTAMENTO, SUCURSAL,FECHA_ANTIGUEDAD,(SUELDO_ACTUAL*30) AS SUELDO_ACTUAL, ' + @cols + ' from 
				(
					select CLAVE
						,Nombre
						,PUESTO
						,Concepto
						,RAZON_SOCIAL
						,SUCURSAL
						,DEPARTAMENTO
						,FECHA_ANTIGUEDAD
						,SUELDO_ACTUAL
						,DIVISION
						,CENTRO_COSTO
						,UUID
						,Estatus_Timbrado
						,Fecha_Timbrado
						,isnull(ImporteTotal1,0) as ImporteTotal1
					from #tempData
					
			   ) x'

	set @query2 = '
				pivot 
				(
					 SUM(ImporteTotal1)
					for Concepto in (' + @colsAlone + ')
				) p 
				order by CLAVE
				'

	exec( @query1 + @query2)
GO

USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	NO MOVER
		SP IMPORTANTE
	NO MOVER
	ARTURO
*/
CREATE proc [Reportes].[spReporteBasicoDeNominaPeriodoIndividualThangos](
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
	;  

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
order by IDEmpleado


	--		select e.*
	--from RH.tblEmpleadosMaster e with (nolock)
	--	join ( select distinct dp.IDEmpleado
	--			from Nomina.tblDetallePeriodo dp with (nolock)
	--			where dp.IDPeriodo = @IDPeriodoInicial
	--	) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
		
    --insert into @empleados      
    --exec [RH].[spBuscarEmpleadosMaster] @IDTipoNomina = @IDTipoNomina,@FechaIni=@fechaIniPeriodo, @Fechafin = @fechaFinPeriodo ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= case when isnull(cc.IDCentroCosto,0)	<> 0 then cc.IDCentroCosto	else e.IDCentroCosto	end
				,e.CentroCosto		= case when isnull(cc.Descripcion,'')	<> '' then cc.Descripcion	else e.CentroCosto		end
				,e.IDDepartamento	= case when isnull(d.IDDepartamento,0)	<> 0 then d.IDDepartamento	else e.IDDepartamento	end
				,e.Departamento		= case when isnull(d.Descripcion,'')		<> '' then d.Descripcion		else e.Departamento		end
				,e.IDSucursal		= case when isnull(s.IDSucursal,0)		<> 0 then s.IDSucursal		else e.IDSucursal		end
				,e.Sucursal			= case when isnull(s.Descripcion,'')		<> '' then s.Descripcion		else e.Sucursal			end
				,e.IDPuesto			= case when isnull(p.IDPuesto,0)		<> 0 then p.IDPuesto		else e.IDPuesto			end
				,e.Puesto			= case when isnull(p.Descripcion,'')		<> '' then p.Descripcion		else e.Puesto			end
				,e.IDRegPatronal	= case when isnull(rp.IDRegPatronal,0)	<> 0 then rp.IDRegPatronal	else e.IDRegPatronal	end
				,e.RegPatronal		= case when isnull(rp.RazonSocial,'')	<> '' then rp.RazonSocial	else e.RegPatronal		end
				,e.IDCliente		= case when isnull(c.IDCliente,0)		<> 0 then c.IDCliente		else e.IDCliente		end
				,e.Cliente			= case when isnull(c.NombreComercial,'')		<> '' then c.NombreComercial	else e.Cliente			end
				,e.IDEmpresa		= case when isnull(emp.IdEmpresa,0)		<> 0 then emp.IdEmpresa		else e.IdEmpresa		end
				,e.Empresa			= case when isnull(emp.NombreComercial,'')		<> '' then left(emp.NombreComercial,50) else e.Empresa		end
				,e.IDArea			= case when isnull(a.IDArea,0)			<> 0 then a.IDArea			else e.IDArea			end
				,e.Area				= case when isnull(a.Descripcion,'')			<> '' then a.Descripcion		else e.Area				end
				,e.IDDivision		= case when isnull(div.IDDivision,0)	<> 0 then div.IDDivision	else e.IDDivision		end
				,e.Division			= case when isnull(div.Descripcion,'')	<> '' then div.Descripcion	else e.Division			end
				,e.IDRegion			= case when isnull(r.IDRegion,0)		<> 0 then r.IDRegion		else e.IDRegion			end
				,e.Region			= case when isnull(r.Descripcion,'')		<> '' then r.Descripcion		else e.Region			end
				,e.IDRazonSocial	= case when isnull(rs.IDRazonSocial,0)	<> 0 then rs.IDRazonSocial	else e.IDRazonSocial	end
				,e.RazonSocial		= case when isnull(rs.RazonSocial,'')	<> '' then rs.RazonSocial	else e.RazonSocial		end

				,e.IDClasificacionCorporativa	= case when isnull(clasificacionC.IDClasificacionCorporativa,0)	<> 0 then clasificacionC.IDClasificacionCorporativa	else e.IDClasificacionCorporativa	end
				,e.ClasificacionCorporativa		= case when isnull(clasificacionC.Descripcion,'')	<> '' then clasificacionC.Descripcion				else e.ClasificacionCorporativa		end

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

	if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
	if object_id('tempdb..#tempConceptos2') is not null drop table #tempConceptos2 
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
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		) c 
	
	Select
		 p.descripcion as [PERIODO]
		,e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.salariodiarioreal      as SALARIO_REAL
		,e.vigente          as VIGENTE
	--	,e.Empresa			as RAZON_SOCIAL
        ,e.RFC
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
	--	,e.Division			as DIVISION
	--	,e.CentroCosto		as CENTRO_COSTO
		,c.Concepto
		,c.OrdenCalculo
		,pago.Cuenta		as CUENTA_BANCO
		,pago.Interbancaria as INTERBANCARIA
		,banco.Descripcion	as BANCO
	--	,UPPER(isnull(Timbrado.UUID,'')) as UUID
	--	,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
	--	,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = p.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
		LEFT JOIN RH.tblPagoEmpleado pago with (nolock)
			on e.IDEmpleado = pago.IDEmpleado
		LEFT JOIN Sat.tblCatBancos banco
			on pago.IDBanco = banco.IDBanco
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Concepto
		,c.OrdenCalculo
        ,e.RFC
		,e.Vigente
		,e.salariodiarioreal
	--	,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
	--	,e.Division
	--	,e.CentroCosto
	--	,Timbrado.UUID
	--	,Estatustimbrado.Descripcion
	--	,Timbrado.Fecha
		,pago.Cuenta
		,pago.INTERBANCARIA
		,banco.Descripcion
		,p.descripcion
	ORDER BY e.ClaveEmpleado ASC

		delete #tempData where ImporteTotal1=0
	

	select tc.* into #Tempconceptos2 from #tempConceptos tc
	inner join #tempData t on t.Concepto=tc.Concepto


	DECLARE @cols AS NVARCHAR(MAX),
		@query1  AS NVARCHAR(MAX),
		@query2  AS NVARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
				FROM #Tempconceptos2 c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenCalculo,c.OrdenColumn
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
				FROM #Tempconceptos2 c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenCalculo,c.OrdenColumn
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	--
/*set @query1 = 'SELECT CLAVE,NOMBRE,SALARIO_REAL,BANCO, CUENTA_BANCO, INTERBANCARIA,  RAZON_SOCIAL, SUCURSAL, DEPARTAMENTO, PUESTO, DIVISION, CENTRO_COSTO,  UUID, Estatus_Timbrado, Fecha_Timbrado, ' + @cols + ' from 
				(
					select CLAVE
						,Nombre
						,SALARIO_REAL
						,BANCO
						,CUENTA_BANCO
						,INTERBANCARIA
						, Concepto
						,RAZON_SOCIAL
						, SUCURSAL
						, DEPARTAMENTO
						, PUESTO
						, DIVISION
						, CENTRO_COSTO
						, UUID
						, Estatus_Timbrado
						, Fecha_Timbrado
						, isnull(ImporteTotal1,0) as ImporteTotal1
					from #tempData
					
			   ) x'*/
set @query1 = 'SELECT PERIODO,CLAVE,NOMBRE,RFC AS [RFC_],VIGENTE,SALARIO_REAL,BANCO, CUENTA_BANCO, INTERBANCARIA, SUCURSAL, DEPARTAMENTO, PUESTO, ' + @cols + ' from 
				(
					select
						 PERIODO
						,CLAVE
						,Nombre
                        ,RFC
						,VIGENTE
						,SALARIO_REAL
						,BANCO
						,CUENTA_BANCO
						,INTERBANCARIA
						, Concepto
						, SUCURSAL
						, DEPARTAMENTO
						, PUESTO
						, isnull(ImporteTotal1,0) as ImporteTotal1
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

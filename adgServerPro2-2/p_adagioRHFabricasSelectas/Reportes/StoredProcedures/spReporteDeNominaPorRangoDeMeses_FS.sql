USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar Reporte spReporteBasicoDeNominaPeriodoIndividual
** Autor			: Jose Rafael Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-07-23
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2024-07-23			JOSE ROMAN		Se elimina la filtración por tipo de nomina, ya que este reporte
									funciona por periodo de nomina. De esta forma se mostraran todas las 
									personas que estan en este periodo, no importando que se hayan cambiado
									de nomina. 
***************************************************************************************************/

CREATE proc [Reportes].[spReporteDeNominaPorRangoDeMeses_FS](

	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int

) as


	declare 
		 @empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@IDPais int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDCliente int
		,@Cerrado bit = 1
		,@IDIdioma varchar(20)
		,@dtFiltrosFinal Nomina.dtFiltrosRH
		,@Ejercicio INT
		,@MesIni INT
		,@MesFin INT
	;


	insert into @dtFiltrosFinal
	select * from  @dtFiltros where Catalogo <> 'TipoNomina'


	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END


	SELECT @Ejercicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
	SELECT @MesIni = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)
	SELECT @MesFin = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMesFin'),',')),0)


	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	
	select @IDPais = isnull(IDPais,0) from Nomina.tblCatTipoNomina where IDTipoNomina = @IDTipoNomina


	insert into @periodo
	select *
	from Nomina.tblCatPeriodos with (nolock)
	where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio
	AND IDMes >= @MesIni AND IDMes <= @MesFin

	 
	SELECT @fechaIniPeriodo = MIN(FechaInicioPago) FROM @periodo
	SELECT @fechaFinPeriodo = MAX(FechaFinPago) FROM @periodo
	SELECT @Cerrado         = (CASE WHEN EXISTS (SELECT TOP 1 1 FROM @Periodo WHERE Cerrado = 0) THEN 0 ELSE 1 END)
	 

	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */      
	--insert into @empleadosTemp       
	--select e.*
	--from RH.tblEmpleadosMaster e with (nolock)
	--	join ( select distinct dp.IDEmpleado
	--			from Nomina.tblDetallePeriodo dp with (nolock)
	--			where dp.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)
	--	) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
	--order by IDEmpleado

		insert into @empleados
		select distinct
						e.*  
		from rh.tblEmpleadosMaster e with(nolock) 
			CROSS APPLY @periodo p  
			inner join Nomina.tblHistorialesEmpleadosPeriodos dp with(nolock) 
			on dp.IDPeriodo=p.idperiodo 
			JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with(nolock) 
			on dfe.IDEmpleado = E.IDEmpleado and dfe.IDUsuario = @IDUsuario 
		WHERE e.idempleado = dp.idempleado and p.IDPeriodo = dp.idperiodo

	/*
	if (@Cerrado = 1)
	begin
		update e
			set 
				e.IDCentroCosto		= isnull(cc.IDCentroCosto	,e.IDCentroCosto)
				,e.CentroCosto		= isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.CentroCosto		)
				,e.IDDepartamento	= isnull(d.IDDepartamento	,e.IDDepartamento)
				,e.Departamento		= isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Departamento	)
				,e.IDSucursal		= isnull(s.IDSucursal		,e.IDSucursal	)
				,e.Sucursal			= isnull(s.Descripcion		,e.Sucursal		)
				,e.IDPuesto			= isnull(p.IDPuesto			,e.IDPuesto		)
				,e.Puesto			= isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))	,e.Cliente		)
				,e.IDEmpresa		= isnull(emp.IdEmpresa		,e.IdEmpresa	)
				,e.Empresa			= isnull(substring(emp.NombreComercial,1,50),substring(e.Empresa,1,50))
				,e.IDArea			= isnull(a.IDArea			,e.IDArea		)
				,e.Area				= isnull(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Area	)
				,e.IDDivision		= isnull(div.IDDivision		,e.IDDivision	)
				,e.Division			= isnull(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Division		)
				,e.IDRegion			= isnull(r.IDRegion			,e.IDRegion		)
				,e.Region			= isnull(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))	,e.Region		)
				,e.IDRazonSocial	= isnull(rs.IDRazonSocial	,e.IDRazonSocial)
				,e.RazonSocial		= isnull(rs.RazonSocial		,e.RazonSocial	)

				,e.IDClasificacionCorporativa	= isnull(clasificacionC.IDClasificacionCorporativa,e.IDClasificacionCorporativa)
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

	end;*/
	
	insert @Empleados
	exec [RH].[spFiltrarEmpleadosDesdeLista]              
		@dtEmpleados	= @empleadosTemp,
		@dtFiltros		= @dtFiltrosFinal,
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
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where ccc.IDPais = isnull(@IDPais,0) OR ISNULL(@IDPais,0) = 0
		) c 
	
	Select
		e.ClaveEmpleado		as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,c.Concepto
		,c.OrdenCalculo
		,P.Descripcion		AS Periodo
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
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		INNER join Nomina.tblHistorialesEmpleadosPeriodos hep with (nolock)   
			on hep.IDPeriodo = p.IDPeriodo and hep.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on hep.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
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
	Group by 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Concepto
		,c.OrdenCalculo
		,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
		,e.Division
		,e.CentroCosto
		,Timbrado.UUID
		,Estatustimbrado.Descripcion
		,Timbrado.Fecha
		,P.Descripcion
	ORDER BY e.ClaveEmpleado ASC

	DECLARE @cols AS NVARCHAR(MAX),
		@query1  AS NVARCHAR(MAX),
		@query2  AS NVARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenCalculo,c.OrdenColumn
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
				FROM #tempConceptos c
				GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo
				ORDER BY c.OrdenCalculo,c.OrdenColumn
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT CLAVE,NOMBRE, RAZON_SOCIAL, SUCURSAL, DEPARTAMENTO, PUESTO, DIVISION, CENTRO_COSTO, PERIODO,  UUID, Estatus_Timbrado, Fecha_Timbrado, ' + @cols + ' from 
				(
					select CLAVE
						,Nombre
						, Concepto
						,RAZON_SOCIAL
						, SUCURSAL
						, DEPARTAMENTO
						, PUESTO
						, DIVISION
						, CENTRO_COSTO
						, UUID
						, Estatus_Timbrado
						, Periodo
						, Fecha_Timbrado
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

USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoDeNominaPeriodoIndividualDusgem_Mensual](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as

SET NOCOUNT ON;

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
		,@IDMes INT
		,@IDCliente int
		,@Cerrado bit = 1
		,@IDIdioma varchar(20)
		,@ConceptosIMSS varchar(max) = '500,501,502,505,504,506,503,508,507,510,509,512'
		,@MaxOC INT
		,@IDPeriodos varchar(max)
		,@Ejercicio INT
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END


	SELECT @IDMes = ISNULL((SELECT CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')
	Select @Ejercicio	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')


	
	select @IDPais = isnull(IDPais,0) from Nomina.tblCatTipoNomina where IDTipoNomina = @IDTipoNomina


	insert into @periodo
	select 
		 *
	from Nomina.tblCatPeriodos with (nolock)
	where IDPeriodo IN (SELECT IDPeriodo FROM Nomina.tblCatPeriodos WHERE Ejercicio = @Ejercicio AND IDTipoNomina = @IDTipoNomina AND IDMes = @IDMes and General = 1) 

	select @IDPeriodos = STRING_AGG(IDPeriodo,',') from @periodo

	select 
		 @fechaIniPeriodo = min(FechaInicioPago)
		,@fechaFinPeriodo = max(FechaFinPago)
		,@IDTipoNomina = MAX(IDTipoNomina )
	from @periodo


	SELECT @Cerrado = CASE WHEN EXISTS (SELECT TOP 1 1 FROM @periodo WHERE Cerrado = 0) THEN 0 ELSE 1 END

	IF (@Cerrado = 0)
	BEGIN
		RAISERROR('LOS PERIODOS DEL MES SELECCIONADO DEBEN ESTAR CERRADOS',16,1)
		RETURN
	END

    
	insert into @empleadosTemp       
	select e.*
	from RH.tblEmpleadosMaster e with (nolock)
		join ( select distinct dp.IDEmpleado
				from Nomina.tblDetallePeriodo dp with (nolock)
				where dp.IDPeriodo IN (SELECT IDPeriodo FROM @periodo)
		) detallePeriodo on e.IDEmpleado = detallePeriodo.IDEmpleado
	order by IDEmpleado


	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil;

	select 
        IDEmpleado, 
		IDMovAfiliatorio
	into #tempMovAfil            
	from (
        SELECT 
        DISTINCT tm.IDEmpleado, 
	            (
                                                        Select top 1 mSalario.IDMovAfiliatorio 
                                                               from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
	    		                                               join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
                                                                    on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
	    		                                        	   where mSalario.IDEmpleado=tm.IDEmpleado 
                                                                     and c.Codigo in ('A','M','R')      
	    		                                        	         and mSalario.Fecha <= @fechaFinPeriodo          
	    		                                        	  order by mSalario.Fecha desc 
                )  IDMovAfiliatorio                                             
	    FROM [IMSS].[tblMovAfiliatorios]  tm 
    ) mm    
	where IDEmpleado in (select IDEmpleado from @empleadosTemp)
 

	 UPDATE lp
		SET SalarioDiario=MOV.SalarioDiario
		   ,SalarioIntegrado=MOV.SalarioIntegrado
		FROM @empleadosTemp LP
			LEFT JOIN #tempMovAfil TMA
				ON TMA.IDEmpleado=LP.IDEmpleado
			LEFT JOIN IMSS.tblMovAfiliatorios MOV
				ON MOV.IDMovAfiliatorio=TMA.IDMovAfiliatorio
		WHERE TMA.IDEmpleado IS NOT NULL


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
				,e.Puesto			= isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))		,e.Puesto		)
				,e.IDRegPatronal	= isnull(rp.IDRegPatronal	,e.IDRegPatronal)
				,e.RegPatronal		= isnull(rp.RazonSocial		,e.RegPatronal	)
				,e.IDCliente		= isnull(c.IDCliente		,e.IDCliente	)
				,e.Cliente			= isnull(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))	,e.Cliente		)
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

	select @MaxOC = MAX(OrdenCalculo) from #tempConceptos
		
	insert into #tempConceptos
	select distinct 
		c.IDConcepto,
		case when c.codigo = '500' then 'EN ESPECIE'
			 when c.codigo = '501' then 'CUOTA ADICIONAL'
			 when c.codigo = '502' then 'EN DINERO'
			 when c.codigo = '503' then 'GUARDERIA Y PREST. SOC.'
			 when c.codigo = '504' then 'RIESGO DE TRABAJO'
			 when c.codigo = '505' then 'PENSIONADOS'
			 when c.codigo = '506' then 'INVALIDEZ Y VIDA'
			 when c.codigo = '507' then 'SUBTOTAL I.M.M.S.'
			 when c.codigo = '508' then 'CESANTIA Y VEJEZ'
			 when c.codigo = '509' then 'RETIRO'
			 when c.codigo = '510' then 'I.N.F.O.N.A.V.I.T.'
			 when c.codigo = '512' then 'TOTAL I.M.S.S. SAR INFONA'
		else replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') end, 
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		case when c.codigo = '500' then @MaxOC + 1
			 when c.codigo = '501' then @MaxOC + 2
			 when c.codigo = '502' then @MaxOC + 3
			 when c.codigo = '503' then @MaxOC + 7
			 when c.codigo = '504' then @MaxOC + 5
			 when c.codigo = '505' then @MaxOC + 4
			 when c.codigo = '506' then @MaxOC + 6
			 when c.codigo = '507' then @MaxOC + 9
			 when c.codigo = '508' then @MaxOC + 8
			 when c.codigo = '509' then @MaxOC + 11
			 when c.codigo = '510' then @MaxOC + 10
			 when c.codigo = '512' then @MaxOC + 12
		else c.Orden end,
		case when c.IDTipoConcepto in (1,4) then 1
			 when c.IDTipoConcepto = 2 then 2
			 when c.IDTipoConcepto = 3 then 3
			 when c.IDTipoConcepto = 6 then 4
			 when c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto
		where ccc.Codigo in (select item from app.Split(@ConceptosIMSS,','))
		) c
	

	DECLARE @SubTotal as table (Clave varchar(20), [512] decimal(18,2), [509] decimal(18,2), [510] decimal(18,2), [SUBTOTAL I.M.M.S.] as ([512] - ([509] + [510])))
	insert into @SubTotal (Clave,[512],[509],[510])
	select 
		 e.ClaveEmpleado
		,isnull((select importetotal1 from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos](e.IDEmpleado,'512',@IDPeriodos)),0)
		,isnull((select importetotal1 from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos](e.IDEmpleado,'509',@IDPeriodos)),0)
		,isnull((select importetotal1 from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos](e.IDEmpleado,'510',@IDPeriodos)),0)
	from @empleados e

	DECLARE @TE AS TABLE (Clave VARCHAR(20), IDEmpleado INT,/* IDPeriodo INT,*/ IDConcepto INT, CantidadVeces DECIMAL(18,2), Descripcion VARCHAR(50))
	INSERT INTO @TE
	SELECT 
		 M.ClaveEmpleado
		,DP.IDEmpleado
		--,DP.IDPeriodo
		,DP.IDConcepto
		,SUM(DP.CantidadVeces) AS CantidadVeces
		,DP.Descripcion
	FROM Nomina.tblDetallePeriodo DP WITH (NOLOCK)
		INNER JOIN @periodo P 
			ON DP.IDPeriodo = P.IDPeriodo
		INNER JOIN RH.tblEmpleadosMaster M WITH (NOLOCK)
			ON DP.IDEmpleado = M.IDEmpleado
	WHERE DP.IDConcepto IN (SELECT IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo IN ('110','111'))
	GROUP BY 
		 M.ClaveEmpleado
		,DP.IDEmpleado
		--,DP.IDPeriodo
		,DP.IDConcepto
		,DP.Descripcion


	Select
		 dtClaveDusgem.Valor	as CLAVE_DUSGEM
		,e.ClaveEmpleado	as CLAVE
		,e.NOMBRECOMPLETO	as NOMBRE
		,e.RFC				as [RFC ]
		,e.IMSS				as IMSS
		,e.CURP				as CURP
		,format(e.FechaAntiguedad,'dd/MM/yyyy')	as [FECHA INGRESO]
		,RHEmpleados.DomicilioFiscal [CODIGO POSTAL FISCAL]
		,'PERIODO DEL MES DE '+(SELECT Descripcion FROM Nomina.tblCatMeses WHERE IDMes = @IDMes)+' '+(SELECT TOP 1 Item FROM App.Split((SELECT TOP 1 VALUE from @dtFiltros where Catalogo = 'Ejercicio'),','))+
		' '+(SELECT Descripcion FROM Nomina.tblCatTipoNomina where IDTipoNomina = @IDTipoNomina) AS Periodo
		--,RIGHT(P.ClavePeriodo,2)+' '+p.DESCRIPCION AS Periodo
		,e.SalarioDiario as [SALARIO DIARIO]
		,e.SalarioIntegrado as [SALARIO DIARIO INTEGRADO]
		,e.Empresa			as RAZON_SOCIAL
		,e.Sucursal			as SUCURSAL
		,e.Departamento		as DEPARTAMENTO
		,e.Puesto			as PUESTO
		,e.Division			as DIVISION
		,e.CentroCosto		as CENTRO_COSTO
		,c.Concepto
		,c.OrdenCalculo
		--,UPPER(isnull(Timbrado.UUID,'')) as UUID
		--,isnull(Estatustimbrado.Descripcion,'Sin estatus') AS Estatus_Timbrado
		--,isnull(format(Timbrado.Fecha,'dd/MM/yyyy hh:mm'),'') as Fecha_Timbrado
		,SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
		,CAST(0 AS DECIMAL(18,2)) AS [HORAS_TIEMPO_EXTRA_DOBLE_110]
		,CAST(0 AS DECIMAL(18,2)) AS [HORAS_TIEMPOS_EXTRAS_TRIPLES_111]
	into #tempData
	from @periodo P
		inner join Nomina.tblDetallePeriodo dp with (nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
		inner join @empleados e
			on dp.IDEmpleado = e.IDEmpleado
		inner join RH.tblEmpleados RHEmpleados with (nolock)
			on RHEmpleados.IDEmpleado = e.IDempleado
		left join Nomina.tblHistorialesEmpleadosPeriodos Historial with (nolock)   
			on Historial.IDPeriodo = p.IDPeriodo and Historial.IDEmpleado = dp.IDEmpleado
		LEFT JOIN Facturacion.tblTimbrado Timbrado with (nolock)        
			on Historial.IDHistorialEmpleadoPeriodo = Timbrado.IDHistorialEmpleadoPeriodo and timbrado.Actual = 1      
		LEFT JOIN Facturacion.tblCatEstatusTimbrado Estatustimbrado  with (nolock)       
			on Timbrado.IDEstatusTimbrado = Estatustimbrado.IDEstatusTimbrado  
		LEFT join RH.tblDatosExtraEmpleados dtClaveDusgem
			on dtClaveDusgem.IDEmpleado = e. idempleado
				and dtClaveDusgem.IDDatoExtra = 1
	Group by 
		 e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.RFC				
		,e.IMSS				
		,e.CURP	
		,e.FechaAntiguedad
		,RHEmpleados.DomicilioFiscal
		,SalarioDiario
		,e.SalarioIntegrado
		,c.Concepto
		,c.OrdenCalculo
		,e.Empresa
		,e.Sucursal 
		,e.Departamento
		,e.Puesto
		,e.Division
		,e.CentroCosto
		--,Timbrado.UUID
		--,Estatustimbrado.Descripcion
		--,Timbrado.Fecha
		,dtClaveDusgem.Valor
		--,p.DESCRIPCION
		--,P.ClavePeriodo
	ORDER BY e.ClaveEmpleado ASC


	update t 
		set t.importetotal1 = s.[SUBTOTAL I.M.M.S.]
	from #tempData t
		inner join @SubTotal s
			on s.Clave = t.CLAVE 
	where t.CLAVE = s.Clave and t.Concepto = 'SUBTOTAL I.M.M.S.'

	UPDATE T
		SET T.HORAS_TIEMPO_EXTRA_DOBLE_110 = EX.CantidadVeces
	FROM #tempData T
		INNER JOIN @TE EX
			ON T.CLAVE = EX.Clave
	WHERE EX.IDConcepto IN (SELECT IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo = '110')

	UPDATE T
		SET T.HORAS_TIEMPOS_EXTRAS_TRIPLES_111 = EX.CantidadVeces
	FROM #tempData T
		INNER JOIN @TE EX
			ON T.CLAVE = EX.Clave
	WHERE EX.IDConcepto IN (SELECT IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo = '111')


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

	set @query1 = 'SELECT CLAVE_DUSGEM,CLAVE,NOMBRE,[RFC ],IMSS,CURP,Periodo,[SALARIO DIARIO],[SALARIO DIARIO INTEGRADO] AS [S.D.I.], [FECHA INGRESO], RAZON_SOCIAL, SUCURSAL, DEPARTAMENTO, PUESTO, DIVISION, CENTRO_COSTO, [CODIGO POSTAL FISCAL],  /*UUID, Estatus_Timbrado, Fecha_Timbrado,*/ ' + @cols + ', [HORAS_TIEMPO_EXTRA_DOBLE_110], [HORAS_TIEMPOS_EXTRAS_TRIPLES_111] from 
				(
					select CLAVE_DUSGEM 
					    , CLAVE
						, Nombre
						, [RFC ]
						, IMSS
						, CURP
						, [SALARIO DIARIO]
						, [SALARIO DIARIO INTEGRADO]
						, [FECHA INGRESO]
						, Concepto
						, RAZON_SOCIAL
						, SUCURSAL
						, DEPARTAMENTO
						, PUESTO
						, DIVISION
						, CENTRO_COSTO
						, [CODIGO POSTAL FISCAL]
						/*, UUID
						, Estatus_Timbrado
						, Fecha_Timbrado*/
						, isnull(ImporteTotal1,0) as ImporteTotal1
						, [HORAS_TIEMPO_EXTRA_DOBLE_110]
						, [HORAS_TIEMPOS_EXTRAS_TRIPLES_111]
						, Periodo
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

USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE proc [Reportes].[spReporteAcumuladosPorTrabajadoresXN_Bimestral](        
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	declare 
			--@empleados [RH].[dtEmpleados]  
			--,@empleadosTemp [RH].[dtEmpleados]  
			--,@IDPeriodoSeleccionado int=0            
			@periodo [Nomina].[dtPeriodos]            
			,@configs [Nomina].[dtConfiguracionNomina]            
			--,@Conceptos [Nomina].[dtConceptos]            
			--,@IDTipoNomina int                 
			--,@IDCliente int
			--,@fechaIniPeriodo date
			--,@fechaFinPeriodo date
			,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
       
    if object_id('tempdb..#Tempuser') is not null drop table #Tempuser;
	if object_id('tempdb..#TempEmpresa') is not null drop table #TempEmpresa;
	if object_id('tempdb..#TempRegPatronal') is not null drop table #TempRegPatronal;
	if object_id('tempdb..#TempTipoNomina') is not null drop table #TempTipoNomina;

		   --se creo esta parte para poder filtrar a la empresa o al tipo de nomina cuando no se le aplica filtro

	create table #TempTipoNomina
	(idtiponomina int  )

	create table #TempEmpresa
	(idempresa int  )

	create table #TempRegPatronal
	(idregpatronal int  )

	
	if(isnull((Select Value from @dtFiltros where Catalogo = 'TipoNomina'),'')<>'')      
	BEGIN      
		insert into #TempTipoNomina(idtiponomina)      
		(select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))      
	END
	else insert into #TempTipoNomina(idtiponomina)
		 select IDTipoNomina from Nomina.tblCatTipoNomina; 

	 
	 if(isnull((Select Value from @dtFiltros where Catalogo = 'RazonesSociales'),'')<>'')      
	BEGIN      
		insert into #TempEmpresa(idempresa)      
		(select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),','))      
	END
	else insert into #TempEmpresa(idempresa)
		 select idempresa from rh.tblempresa; 

	if(isnull((Select Value from @dtFiltros where Catalogo = 'RegPatronales'),'')<>'')      
	BEGIN      
		insert into #TempRegPatronal(idregpatronal)      
		(select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),','))      
	END
	else insert into #TempRegPatronal(idregpatronal) 
		 select idregpatronal from rh.tblCatRegPatronal; 



		insert into @periodo      
	select    *   
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
		((                     
		 (IDMes between (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMes'),','))
			and (Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDMesFin'),','))
		)   
		and Ejercicio in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))   
		))   
		and isnull(Cerrado,0) = 1
		and Finiquito=0

      
			select distinct m.IDEmpleado
			,m.ClaveEmpleado,m.RFC,m.CURP,m.IMSS,m.NOMBRECOMPLETO,m.FechaAntiguedad,m.SalarioDiario,m.SalarioDiarioReal,m.SalarioIntegrado,m.Vigente,m.IDTipoContrato,m.TipoContrato,m.idtipoprestacion,m.empresa,m.sucursal,m.departamento,m.puesto
			,hp.IDPeriodo,hp.IDSucursal,hp.IDPuesto,hp.IDRegPatronal,hp.IDCliente,hp.IDEmpresa,hp.IDArea,hp.IDDivision, m.RegPatronal
			,p.IDMes,p.IDTipoNomina,p.Ejercicio,p.ClavePeriodo,p.Descripcion,p.MesInicio,p.MesFin,ts.Descripcion as Salario
		 into #Tempuser
			from rh.tblempleadosmaster m
					inner join [Nomina].[tblHistorialesEmpleadosPeriodos] hp on hp.idempleado=m.idempleado
					inner join @periodo p on p.IDPeriodo=hp.IDPeriodo
					left join Facturacion.TblTimbrado t on hp.IDHistorialEmpleadoPeriodo =t.IDHistorialEmpleadoPeriodo
					left join rh.tblTipoTrabajadorEmpleado tte on tte.IDEmpleado = m.IDEmpleado
					left join imss.tblCatTipoSalario ts on ts.IDTipoSalario = tte.IDTipoSalario
			where  hp.IDEmpresa in (select idempresa from #TempEmpresa) 
				and p.IDTipoNomina in (select idtiponomina from #TempTipoNomina) 
				and isnull(hp.idregpatronal,'') in (case when isnull(hp.IDRegPatronal,'')<>'' then (select IDRegPatronal from #TempRegPatronal where idregpatronal=hp.IDRegPatronal) else '' end)
				
	
	
	
		if object_id('tempdb..#tempConceptos')	is not null drop table #tempConceptos 
		if object_id('tempdb..#tempData')		is not null drop table #tempData

	select distinct 
		c.IdConcepto,
		c.Descripcion,
		c.Codigo,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		tc.IDTipoConcepto as IDTipoConcepto,
		tc.Descripcion as TipoConcepto,
		c.OrdenCalculo as OrdenCalculo,
		case when  tc.IDTipoConcepto in (1,4) then 1
			 when  tc.IDTipoConcepto = 2 then 2
			 when  tc.IDTipoConcepto = 3 then 3
			 when  tc.IDTipoConcepto = 6 then 4
			 when  tc.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn,
		1 as Origen
	into #tempConceptos
	from Reportes.tblConfigReporteRayas dp
			inner join Nomina.tblCatConceptos c with(nolock)
			on C.IDConcepto = dp.IDConcepto
			Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
			where dp.Impresion = 1
				order by OrdenColumn,OrdenCalculo asc

		
-----exento abre

	insert into #tempConceptos
	select distinct 
		c.IdConcepto,
		c.Descripcion,
		c.Codigo,
		replace(replace(replace(replace(replace('EX'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto as TipoConcepto,
		c.OrdenCalculo as OrdenCalculo,
		case when  c.IDTipoConcepto in (1,4) then 1
			 when  c.IDTipoConcepto = 2 then 2
			 when  c.IDTipoConcepto = 3 then 3
			 when  c.IDTipoConcepto = 6 then 4
			 when  c.IDTipoConcepto = 5 then 5
			 else 0
			 end as OrdenColumn,
		2 as Origen
	from (select 
			ccc.*
			,tc.Descripcion as TipoConcepto
			,crr.Orden
		from Nomina.tblCatConceptos ccc with (nolock) 
			inner join Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
			inner join Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
		where CCC.IDConcepto in (select distinct IDConcepto from Nomina.tblDetallePeriodo with (nolock) where IDPeriodo IN ( select idperiodo from  @periodo ) and isnull(ImporteExcento,0)>0  )
		and tc.IDTipoConcepto = 1
		) c 


	


-----exento cierra



--------------------------------
	Select
		e.ClaveEmpleado as [NO.EMPLEADO],
		e.RegPatronal as REG_PATRONAL,
		e.RFC as RFC,
		e.IMSS as [NUM.SEG.SOC.], 
		e.Salario as [TIPO SALARIO],
		e.NOMBRECOMPLETO as TRABAJADOR,
		E.CURP AS CURP,
		--e.idbimestre AS BIMESTRE,
		tp.Descripcion as TIPO_PRESTACION,
		e.Departamento as DEPARTAMENTO,
		E.PUESTO as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN E.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		e.Sucursal as SUCURSAL,
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteTotal1,0)) as ImporteTotal1
	into #tempData
	from Nomina.tblDetallePeriodo dp with (nolock)
		inner join #Tempuser e on dp.IDEmpleado = e.IDEmpleado and dp.IDPeriodo=e.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 1
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
Group by    e.ClaveEmpleado,
			e.RegPatronal,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			e.Salario,
			E.CURP,
			--e.idbimestre,
			tp.Descripcion,
			e.TipoContrato,
			e.FechaAntiguedad,
			e.Vigente,
			e.Sucursal,
			e.SalarioDiario,
			e.SalarioIntegrado,
			c.Descripcion,
			c.Codigo,
			e.Empresa,
			e.Sucursal,
			e.Departamento,
			e.Puesto
	ORDER BY e.ClaveEmpleado ASC
--------------------------------
	   --select * from   #tempData
	   --return;	-------------------------------------------------------------aqui----------------------

--ex inicia--------------------------------
	
	insert into #tempData
	Select
		e.ClaveEmpleado as [NO.EMPLEADO],
		e.RegPatronal as REG_PATRONAL,
		e.RFC as RFC,
		e.IMSS as [NUM.SEG.SOC.], 
		e.Salario as [TIPO SALARIO],
		e.NOMBRECOMPLETO as TRABAJADOR,
		e.CURP AS CURP,
		--e.idbimestre AS BIMESTRE,
		tp.Descripcion as TIPO_PRESTACION,
		e.Departamento as DEPARTAMENTO,
		e.Puesto as PUESTO,
		FORMAT(e.FechaAntiguedad,'dd/MM/yyyy') as ANTIGUEDAD,
		CASE WHEN E.Vigente = 1 THEN 'Vigente' ELSE 'Baja'
			 END AS ESTATUS,
		e.Sucursal as SUCURSAL,
		
		e.SalarioDiario as SALARIO_DIARIO,
		e.SalarioIntegrado AS SALARIO_INTEGRADO,
		replace(replace(replace(replace(replace('EX'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		SUM(isnull(dp.ImporteExcento,0)) as ImporteTotal1
	from Nomina.tblDetallePeriodo dp with (nolock)
		inner join #Tempuser e on dp.IDEmpleado = e.IDEmpleado and dp.IDPeriodo=e.IDPeriodo
		inner join #tempConceptos c
			on C.IDConcepto = dp.IDConcepto
				and c.Origen = 2
		Inner join Nomina.tblCatTipoConcepto tc with(nolock)
			on tc.IDTipoConcepto = c.IDTipoConcepto
		left join RH.tblCatTiposPrestaciones tp
			on tp.IDTipoPrestacion = e.IDTipoPrestacion
Group by    e.ClaveEmpleado,
			e.RegPatronal,
			e.RFC,
			e.IMSS,
			e.NOMBRECOMPLETO,
			e.Salario,
			e.CURP,
			--e.idbimestre,
			tp.Descripcion,
			e.TipoContrato,
			e.FechaAntiguedad,
			e.Vigente,
			e.Sucursal,
			e.SalarioDiario,
			e.SalarioIntegrado,
			c.Descripcion,
			c.Codigo,
			e.Empresa,
			e.Sucursal,
			E.departamento,
			E.puesto
	ORDER BY e.ClaveEmpleado ASC
--ex final--------------------------------

		

	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
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



	set @query1 = 'SELECT 
					[NO.EMPLEADO],
					TRABAJADOR,
					[NUM.SEG.SOC.],
					RFC as [RFC ],
					CURP,
					REG_PATRONAL,
					SALARIO_DIARIO,
					[TIPO SALARIO],
					PUESTO,
					TIPO_PRESTACION,
					ANTIGUEDAD,
					ESTATUS,
					SUCURSAL,
					DEPARTAMENTO,
					SALARIO_INTEGRADO,
					 ' + @cols + ' from 

				(select 
					[NO.EMPLEADO],
					REG_PATRONAL,
					RFC,
					[NUM.SEG.SOC.],
					[TIPO SALARIO],
					TRABAJADOR, 
					CURP,
					TIPO_PRESTACION, 
					ANTIGUEDAD,
					ESTATUS,
					SUCURSAL,
					DEPARTAMENTO,
					PUESTO,
					SALARIO_DIARIO,
					SALARIO_INTEGRADO,
					Concepto,
					isnull(ImporteTotal1,0) as ImporteTotal1
				from #tempData
					
			   ) x'

	set @query2 = '
				pivot 
				(
					 SUM(ImporteTotal1)
					for Concepto in (' + @colsAlone + ')
				) p 
				order by [NO.EMPLEADO]
				'
 
	exec( @query1 + @query2)
GO

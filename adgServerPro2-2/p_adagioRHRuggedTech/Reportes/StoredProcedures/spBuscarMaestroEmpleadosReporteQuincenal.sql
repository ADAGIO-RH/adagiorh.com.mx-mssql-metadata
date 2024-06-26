USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reportes].[spBuscarMaestroEmpleadosReporteQuincenal] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	;   

	select 
		top 1 @IDIdioma = dp.Valor        
	from Seguridad.tblUsuarios u with (nolock)       
		Inner join App.tblPreferencias p with (nolock)        
			on u.IDPreferencia = p.IDPreferencia        
		Inner join App.tblDetallePreferencias dp with (nolock)        
			on dp.IDPreferencia = p.IDPreferencia        
		Inner join App.tblCatTiposPreferencias tp with (nolock)        
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
			,@ClaveEmpleadoInicial varchar(255)
			,@ClaveEmpleadoFinal varchar(255)
			,@TipoNomina Varchar(max)
	--insert into @dtFiltros(Catalogo,Value)
	--values('Departamentos',@Departamentos)
	--	,('Sucursales',@Sucursales)
	--	,('Puestos',@Puestos)
	--	,('RazonesSociales',@RazonesSociales)
	--	,('RegPatronales',@RegPatronales)
	--	,('Divisiones',@Divisiones)
	--	,('Prestaciones',@Prestaciones)
	--	,('Clientes',@Cliente)

	
	select @TipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'

	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END
		from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'

	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)


	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')		is not null drop table ##tempDatosExtraEmpleados

	select distinct 
		c.IDDatoExtra,
		C.Nombre,
		C.Descripcion
	into #tempDatosExtra
	from (select 
			*
		from RH.tblCatDatosExtra
		) c 

	Select
		M.IDEmpleado
		,CDE.IDDatoExtra
		,CDE.Nombre
		,CDE.Descripcion
		,DE.Valor
	into #tempData
	from RH.tblEmpleadosMaster M
		inner join RH.tblDatosExtraEmpleados DE
			on M.IDEmpleado = DE.IDEmpleado
		inner join RH.tblCatDatosExtra CDE
			on DE.IDDatoExtra = CDE.IDDatoExtra
	


	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Nombre)+',0) AS '+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Nombre)
				FROM #tempDatosExtra c
				ORDER BY c.IDDatoExtra
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');


	set @query1 = 'SELECT IDEmpleado, ' + @cols + ' 
					into ##tempDatosExtraEmpleados
					from 
				(
					select IDEmpleado
						,Nombre
						,Valor
					from #tempData
			   ) x'

	set @query2 = '
				pivot 
				(
					 MAX(Valor)
					for Nombre in (' + @colsAlone + ')
				) p 
				order by IDEmpleado
				'

	--select len(@query1) +len( @query2) 
	exec( @query1 + @query2) 

	
	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select m.ClaveEmpleado as [CLAVE]
			,deex.SUCCESSFACTORID as [HRID]
			,Mast.Paterno as [LAST_NAME]
			,'X' AS [COMMON]
            ,m.Nombre AS [FIRST_NAME]
			,JobBand.Valor AS [BAND]
			,m.Puesto AS [TITLE]
			,'X' AS [STATUS_CODE]
			,'X' AS [MX_SAL]
			,FORMAT(Mast.FechaAntiguedad,'dd/MM/yyyy') AS [DOH_]
			,'X' AS [CAR_GL1]
			,'X' AS [CAR_GL2]
			,'X' AS [CAR_GL3]
			,'X' AS [UBICACION_PAGO]
			,Mast.CentroCosto AS [CAR_GL4]
			,'35' AS  [STATE]
			,'1' AS [JAN_1]
			,'1' AS [FEB_1]
			,'1' AS [MAR_1]
			,'1' AS [APR_1]
			,'1' AS [MAY_1]
			,'1' AS [JUN_1]
			,'1' AS [JUL_1]
			,'1' AS [AUG_1]
			,'1' AS [SEP_1]
			,'1' AS [OCT_1]
			,'1' AS [NOV_1]
			,'1' AS [DEC_1]
			,cast((m.SalarioDiario * 365) as decimal(18,2)) AS [AN_WAGE]
			,'X' AS [LUMP_SUM]
			,1 AS [PRORATED]
			,TPD.DiasVacaciones AS [VACATION_DAYS]
			,TPD.DiasAguinaldo AS [CHRISTMAS_BONUS]
			,2 AS [PAYROLL_TYPE]
			,'X' AS [X___]
			,(DATEDIFF(day,Mast.FechaAntiguedad,GETDATE())/365.0) AS [Seniority]
			,Mast.Sexo as [SEXO]
			,m.IMSS AS [IMSS]
			,m.RFC AS [RFC_]
			,m.CURP AS [CURP]
			,Mast.SalarioDiario [SUELDO_DIA]
			,Mast.SalarioIntegrado AS [SUELDO_INT]
    --        ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				--inner join RH.tblEmpleadosMaster emp with(nolock)
				--	on je.IDJefe = emp.IDEmpleado
				--where je.IDEmpleado = m.IDEmpleado
				--) as Supervisor
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK)
			on  TPD.IDTipoPrestacion = Mast.IDTipoPrestacion
			--AND TPD.Antiguedad =  DATEDIFF(YEAR,[IMSS].[fnObtenerFechaAntiguedad](M.IDEmpleado, M.IDMovAfiliatorio), M.Fecha) + 1
            --AND TPD.Antiguedad =  DATEDIFF(YEAR,E.FechaAntiguedad, GETDATE()) + 1
           and (tpd.Antiguedad = FLOOR(DATEDIFF(day,Mast.FechaAntiguedad,GETDATE())/365.0)+1) 
		   inner join rh.tblCatPuestos p
				on Mast.IDPuesto = p.IDPuesto
			inner join App.tblValoresDatosExtras JobBand
				on p.IDPuesto= JobBand.IDReferencia and IDDatoExtra=1
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
				order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		
			select m.ClaveEmpleado as CLAVE
			,CONCAT(m.Nombre, ' ', m.SegundoNombre) AS NOMBRE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]
            ,m.Region AS REGION
            ,m.Sucursal AS SUCURSAL
	        ,m.CentroCosto AS [CENTRO COSTO]
            ,m.Departamento AS DEPARTAMENTO
    	    ,m.Puesto AS PUESTO
            ,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
            ,tp.Descripcion as [TIPO PRESTACION]
            ,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,m.Area AS AREA
	        ,m.Division AS DIVISION
            ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as Supervisor
            ,cte.[Value] as [Email Empresarial]
            ,m.Sexo AS SEXO
            ,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
            ,deex.NACIONALIDAD
            ,ct.[Value] as Email
			,CASE 
			      WHEN m.IDCliente = 6 THEN cast((m.SalarioDiario * 24) as decimal(18,2))
				  WHEN m.IDCliente = 5 THEN cast((m.SalarioDiario * 26) as decimal(18,2))
				  ELSE cast((m.SalarioDiario * 30) as decimal(18,2))
			  END as [SALARIO MENSUAL]
            ,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioDiarioReal AS [SALARIO DIARIO REAL]
            ,deex.MONEDA
			,deex.INCENTIVO_MENSUAL	AS [INCENTIVO MENSUAL]
			,deex.INCENTIVO_TRIMESTRAL AS [INCENTIVO TRIMESTRAL]	
            ,deex.INCENTIVO_ANUAL AS [INCENTIVO ANUAL]
			,deex.BONO_IDIOMA AS [BONO IDIOMA]
			,deex.BONO_MENSUAL AS [BONO MENSUAL]
			,deex.MOTIVO_BONO_MENSUAL AS [MOTIVO_BONO_MENSUAL]
			,deex.BONO_ANUAL AS [BONO_ANUAL]
			,deex.ACTING_AS_INCENTIVE AS [ACTING_AS_INCENTIVE]
			,deex.VIGENCIA_ACTING_AS_INCENTIVE AS [VIGENCIA_ACTING_AS_INCENTIVE]
			,m.Empresa AS EMPRESA
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
            ,m.EstadoCivil AS [ESTADO CIVIL]
            ,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,isnull(c.NombreAsentamiento, direccion.Colonia) as [DIRECCION COLONIA]
			,localidades.Descripcion as [DIRECCION LOCALIDAD]
			,Muni.Descripcion as [DIRECCION MUNICIPIO]
			,est.NombreEstado as [DIRECCION ESTADO]
			,CP.CodigoPostal as [DIRECCION POSTAL]
			,em.DomicilioFiscal as [CÓDIGO POSTAL FISCAL]
			,rf.Descripcion as [RÉGIMEN FISCAL RECEPTOR]
            ,(Select top 1 LP.Descripcion from RH.tblpagoempleado PE 
			inner join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
			 where PE.IDEmpleado = m.IDEmpleado
			 )  AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
            ,m.TipoNomina AS [TIPO NOMINA]
            ,TT.Descripcion as [TIPO TRABAJADOR SUA]
			,TC.Descripcion as [TIPO CONTRATO SAT]
            ,m.PaisNacimiento AS [PAIS NACIMIENTO]
            ,deex.TIPO_DE_RESIDENCIA
            ,deex.VENCIMIENTO_PERMISO
            ,deex.MERCURY
            ,deex.GALENIA
            ,deex.AJUSTE_GALENIA
            ,m.ClaveEmpleado as CLAVECOLABORADOR
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
			left join RH.tblContactoEmpleado ct 
				on m.IDEmpleado = ct.IDEmpleado and ct.IDTipoContactoEmpleado = 1
			left join RH.tblContactoEmpleado cte
				on m.IDEmpleado = cte.IDEmpleado and cte.IDTipoContactoEmpleado = 5
			inner join rh.tblempleados em 
				on em.IDEmpleado=m.IDEmpleado
			left join [Sat].[tblCatRegimenesFiscales] rf
				on em.IDRegimenFiscal=rf.IDRegimenFiscal
		Where 
		M.Vigente =0 and
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))   
		and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
			select m.ClaveEmpleado as CLAVE
			,CONCAT(m.Nombre, ' ', m.SegundoNombre) AS NOMBRE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]
            ,m.Region AS REGION
            ,m.Sucursal AS SUCURSAL
	        ,m.CentroCosto AS [CENTRO COSTO]
            ,m.Departamento AS DEPARTAMENTO
    	    ,m.Puesto AS PUESTO
            ,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
            ,tp.Descripcion as [TIPO PRESTACION]
            ,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
            ,m.Area AS AREA
	        ,m.Division AS DIVISION
            ,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as Supervisor
            ,cte.[Value] as [Email Empresarial]
            ,m.Sexo AS SEXO
            ,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
            ,deex.NACIONALIDAD
            ,ct.[Value] as Email
			,CASE 
			      WHEN m.IDCliente = 6 THEN cast((m.SalarioDiario * 24) as decimal(18,2))
				  WHEN m.IDCliente = 5 THEN cast((m.SalarioDiario * 26) as decimal(18,2))
				  ELSE cast((m.SalarioDiario * 30) as decimal(18,2))
			  END as [SALARIO MENSUAL]
            ,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioDiarioReal AS [SALARIO DIARIO REAL]
            ,deex.MONEDA
			,deex.INCENTIVO_MENSUAL	AS [INCENTIVO MENSUAL]
			,deex.INCENTIVO_TRIMESTRAL AS [INCENTIVO TRIMESTRAL]	
            ,deex.INCENTIVO_ANUAL AS [INCENTIVO ANUAL]
			,deex.BONO_IDIOMA AS [BONO IDIOMA]
			,deex.BONO_MENSUAL AS [BONO MENSUAL]
			,deex.MOTIVO_BONO_MENSUAL AS [MOTIVO_BONO_MENSUAL]
			,deex.BONO_ANUAL AS [BONO_ANUAL]
			,deex.ACTING_AS_INCENTIVE AS [ACTING_AS_INCENTIVE]
			,deex.VIGENCIA_ACTING_AS_INCENTIVE AS [VIGENCIA_ACTING_AS_INCENTIVE]
            ,m.Empresa AS EMPRESA
			,m.RFC AS [RFC ]
			,m.CURP AS CURP
			,m.IMSS AS IMSS
            ,m.EstadoCivil AS [ESTADO CIVIL]
            ,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,isnull(c.NombreAsentamiento, direccion.Colonia) as [DIRECCION COLONIA]
			,isnull(localidades.Descripcion, direccion.Localidad) as [DIRECCION LOCALIDAD]
			,isnull(Muni.Descripcion, direccion.Municipio) as [DIRECCION MUNICIPIO]
			,isnull(est.NombreEstado, direccion.Estado) as [DIRECCION ESTADO]
			,isnull(CP.CodigoPostal,direccion.CodigoPostal) as [DIRECCION POSTAL]
			,em.DomicilioFiscal as [CÓDIGO POSTAL FISCAL]
			,rf.Descripcion as [RÉGIMEN FISCAL RECEPTOR]
            ,(Select top 1 LP.Descripcion from RH.tblpagoempleado PE 
			inner join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
			where PE.IDEmpleado = m.IDEmpleado
			)  AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
            ,m.TipoNomina AS [TIPO NOMINA]
            ,TT.Descripcion as [TIPO TRABAJADOR SUA]
			,TC.Descripcion as [TIPO CONTRATO SAT]
            ,m.PaisNacimiento AS [PAIS NACIMIENTO]
            ,deex.TIPO_DE_RESIDENCIA
            ,deex.VENCIMIENTO_PERMISO
            ,deex.MERCURY
            ,deex.GALENIA
            ,deex.AJUSTE_GALENIA
            ,m.ClaveEmpleado as CLAVECOLABORADOR
		from RH.tblEmpleadosMaster M with (nolock) 
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) 
				on M.IDTipoPrestacion = TP.IDTipoPrestacion
			left join [RH].[tblEmpleadoPTU] PTU with (nolock) 
				on m.IDEmpleado = PTU.IDEmpleado
			left join RH.tblSaludEmpleado SE with (nolock) 
				on SE.IDEmpleado = M.IDEmpleado
			left join RH.tblDireccionEmpleado direccion with (nolock) 
				on direccion.IDEmpleado = M.IDEmpleado
				AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
			left join SAT.tblCatColonias c with (nolock) 
				on direccion.IDColonia = c.IDColonia
			left join SAT.tblCatMunicipios Muni with (nolock) 
				on muni.IDMunicipio = direccion.IDMunicipio
			left join SAT.tblCatEstados EST with (nolock) 
				on EST.IDEstado = direccion.IDEstado 
			left join SAT.tblCatLocalidades localidades with (nolock) 
				on localidades.IDLocalidad = direccion.IDLocalidad 
			left join SAT.tblCatCodigosPostales CP with (nolock) 
				on CP.IDCodigoPostal = direccion.IDCodigoPostal
			left join RH.tblCatRutasTransporte rutas with (nolock) 
				on direccion.IDRuta = rutas.IDRuta
			left join RH.tblInfonavitEmpleado Infonavit with (nolock) 
				on Infonavit.IDEmpleado = m.IDEmpleado
					and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
			left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) 
				on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
			left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) 
				on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
			left join RH.tblPagoEmpleado PE with (nolock) 
				on PE.IDEmpleado = M.IDEmpleado
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
			left join Nomina.tblLayoutPago LP with (nolock) 
				on LP.IDLayoutPago = PE.IDLayoutPago
					and LP.IDConcepto = PE.IDConcepto
			left join SAT.tblCatBancos bancos with (nolock) 
				on bancos.IDBanco = PE.IDBanco
			--left join RH.tblTipoTrabajadorEmpleado TTE
			--	on TTE.IDEmpleado = m.IDEmpleado
			left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
						from RH.tblTipoTrabajadorEmpleado with (nolock)  
					) as TTE
				on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
			left join IMSS.tblCatTipoTrabajador TT with (nolock) 
				on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
			left join SAT.tblCatTiposContrato TC with (nolock) 
				on TC.IDTipoContrato = TTE.IDTipoContrato
			left join ##tempDatosExtraEmpleados deex
				on deex.idempleado = m.IDEmpleado
			left join RH.tblContactoEmpleado ct 
				on m.IDEmpleado = ct.IDEmpleado and ct.IDTipoContactoEmpleado = 1
			left join RH.tblContactoEmpleado cte
				on m.IDEmpleado = cte.IDEmpleado and cte.IDTipoContactoEmpleado = 5
			inner join rh.tblempleados em 
				on em.IDEmpleado=m.IDEmpleado
			left join [Sat].[tblCatRegimenesFiscales] rf
				on em.IDRegimenFiscal=rf.IDRegimenFiscal
		Where 
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>''))) 
		 and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END
END
GO

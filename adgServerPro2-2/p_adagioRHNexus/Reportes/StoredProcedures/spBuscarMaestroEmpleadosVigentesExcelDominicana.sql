USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcelDominicana] (
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	   ,@dtFiltros2 [Nomina].[dtFiltrosRH]
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')    
        
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

	set @Titulo = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DOMINICANA DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	insert into @dtFiltros2
	select * from @dtFiltros

	insert into @dtFiltros2 values(N'Clientes',N'7')
	insert into @dtFiltros2 values(N'Cliente',N'7')



	--select @IDTipoVigente
	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)


	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')is not null drop table ##tempDatosExtraEmpleados
	if object_id('tempdb..#tempEmailEmpresarial')is not null drop table #tempEmailEmpresarial
	if object_id('tempdb..#tempEmailPersonal')is not null drop table #tempEmailPersonal

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
		left join RH.tblDatosExtraEmpleados DE
			on M.IDEmpleado = DE.IDEmpleado
		left join RH.tblCatDatosExtra CDE
			on DE.IDDatoExtra = CDE.IDDatoExtra
	
   
   --select * from #tempData order by IDEmpleado, Descripcion return
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

	set @query1 = 'SELECT IDEmpleado ' + coalesce(','+@cols, '') + ' 
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
					for Nombre in (' + coalesce(@colsAlone, 'NO_INFO')  + ')
				) p 
				order by IDEmpleado
				'



	exec( @query1 + @query2) 

	select  ROW_NUMBER() over (PARTition by IDEmpleado order by idempleado) as [ROW], * into #tempEmailEmpresarial from rh.tblContactoEmpleado where value like '%nexustours.com'

	select  ROW_NUMBER() over (PARTition by IDEmpleado order by idempleado) as [ROW], * into #tempEmailPersonal from rh.tblContactoEmpleado where IDContactoEmpleado not in (select IDContactoEmpleado from #tempEmailEmpresarial)

	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros2,@IDUsuario=@IDUsuario

		--select * from @dtEmpleados return

		select m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO as NOMBRE
			,m.Region AS REGION
			,m.Sucursal AS SUCURSAL
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,tp.Descripcion as [TIPO PRESTACION]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
	       -- ,m.TipoNomina as [TIPO DE NOMINA]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,isnull(deex.CONCESION,'') as [CONCESION]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as SUPERVISOR
			,emailEmpresarial.Value as [EMAIL EMPRESARIAL]
			,m.Sexo AS SEXO
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			,nacionalidad.Valor as [NACIONALIDAD]
			,emailPersonal.Value as [EMAIL]
			,CASE 
			      WHEN m.IDCliente = 6 THEN cast((m.SalarioDiario * 24) as decimal(18,2))
				  WHEN m.IDCliente = 5 THEN cast((m.SalarioDiario * 26) as decimal(18,2))
				  WHEN m.IDCliente = 2 THEN cast((m.SalarioDiario * 20) as decimal(18,2))
				  ELSE cast((m.SalarioDiario * 30) as decimal(18,2))
			  END as [SALARIO MENSUAL]
			,m.SalarioDiario AS [SALARIO DIARIO]
			,moneda.Valor as [MONEDA]
			,isnull(deex.INCENTIVO_MENSUAL,'')	as [INCENTIVO MENSUAL]
			,isnull(deex.INCENTIVO_TRIMESTRAL,'')	as [INCENTIVO TRIMESTRAL]
			,isnull(deex.INCENTIVO_ANUAL,'')	as [INCENTIVO ANUAL]
			,isnull(deex.MONEDA_INCENTIVO,'')	as [MONEDA INCENTIVO]
			,isnull(deex.BONO_IDIOMA,'')	as [BONO_IDIOMA]
			,isnull(deex.BONO_ANUAL,'')	as [BONO ANUAL]
			,isnull(deex.MONEDA_BONO,'')	as [MONEDA BONO]
			,isnull(deex.ACTING_AS_INCENTIVE,'')	as [ACTING AS INCENTIVE]
			,isnull(deex.VIGENCIA_ACTING_AS_INCENTIVE,'')	as [VIGENCIA ACTING AS INCENTIVE]
			,isnull(deex.PLAN_SEGURO,'') as [PLAN SEGURO]
			,isnull(deex.SEGUROCOMPLEMENTARIO,'') as [SEGURO COMPLEMENTARIO]
			--,m.Empresa AS EMPRESA
			,m.RFC AS CEDULA
			,m.EstadoCivil AS [ESTADO CIVIL]
			,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			--,c.NombreAsentamiento as [DIRECCION COLONIA]
			--,localidades.Descripcion as [DIRECCION LOCALIDAD]
			--,Muni.Descripcion as [DIRECCION MUNICIPIO]
			--,est.NombreEstado as [DIRECCION ESTADO]
			--,CP.CodigoPostal as [DIRECCION POSTAL]
			,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			--,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,isnull(deex.TIPO_DE_RESIDENCIA,'') as [TIPO DE RESIDENCIA]
			,isnull(deex.VENCIMIENTO_PERMISO,'') as [VENCIMIENTO PERMISO]
			,mercury.Valor as [MERCURY]
			,ISNULL (ft.ClaveEmpleado,'NO TIENE FOTO') AS [FOTO]
			,Usuario.cuenta as [USER]
		from @dtEmpleados m
		inner join RH.tblEmpleadosMaster Mast with (nolock) 
			on m.IDEmpleado = mast.IDEmpleado
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
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = 'RD601')
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
			left join #tempEmailEmpresarial emailEmpresarial
				on emailEmpresarial.IDEmpleado = m.IDEmpleado and emailEmpresarial.[ROW] = 1
			left join #tempEmailPersonal emailPersonal
				on emailPersonal.IDEmpleado = m.IDEmpleado and emailPersonal.[ROW] = 1
			left join #tempData nacionalidad
				on nacionalidad.IDEmpleado = m.IDEmpleado and nacionalidad.IDDatoExtra = 7
			left join #tempData moneda
				on moneda.IDEmpleado = m.IDEmpleado and moneda.IDDatoExtra = 11
			left join #tempData mercury
				on mercury.IDEmpleado = m.IDEmpleado and mercury.IDDatoExtra = 1
			left join rh.tblFotosEmpleados ft
				on m.idempleado = ft.idempleado
			left join Seguridad.tblusuarios usuario  with (nolock)
				on usuario.idempleado = m.idempleado
			order by M.ClaveEmpleado asc

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros2,@IDUsuario=@IDUsuario

		
		select m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO as NOMBRE
			,m.Region AS REGION
			,m.Sucursal AS SUCURSAL
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,tp.Descripcion as [TIPO PRESTACION]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
	       -- ,m.TipoNomina as [TIPO DE NOMINA]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,isnull(deex.CONCESION,'') as [CONCESION]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as SUPERVISOR
			,emailEmpresarial.Value as [EMAIL EMPRESARIAL]
			,m.Sexo AS SEXO
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			,nacionalidad.Valor as [NACIONALIDAD]
			,emailPersonal.Value as [EMAIL]
			,CASE 
			      WHEN m.IDCliente = 6 THEN cast((m.SalarioDiario * 24) as decimal(18,2))
				  WHEN m.IDCliente = 5 THEN cast((m.SalarioDiario * 26) as decimal(18,2))
				  WHEN m.IDCliente = 2 THEN cast((m.SalarioDiario * 20) as decimal(18,2))
				  ELSE cast((m.SalarioDiario * 30) as decimal(18,2))
			  END as [SALARIO MENSUAL]
			,m.SalarioDiario AS [SALARIO DIARIO]
			,moneda.Valor as [MONEDA]
			,isnull(deex.INCENTIVO_MENSUAL,'')	as [INCENTIVO MENSUAL]
			,isnull(deex.INCENTIVO_TRIMESTRAL,'')	as [INCENTIVO TRIMESTRAL]
			,isnull(deex.INCENTIVO_ANUAL,'')	as [INCENTIVO ANUAL]
			,isnull(deex.MONEDA_INCENTIVO,'')	as [MONEDA INCENTIVO]
			,isnull(deex.BONO_IDIOMA,'')	as [BONO_IDIOMA]
			,isnull(deex.BONO_ANUAL,'')	as [BONO ANUAL]
			,isnull(deex.MONEDA_BONO,'')	as [MONEDA BONO]
			,isnull(deex.ACTING_AS_INCENTIVE,'')	as [ACTING AS INCENTIVE]
			,isnull(deex.VIGENCIA_ACTING_AS_INCENTIVE,'')	as [VIGENCIA ACTING AS INCENTIVE]
			,isnull(deex.PLAN_SEGURO,'') as [PLAN SEGURO]
			,isnull(deex.SEGUROCOMPLEMENTARIO,'') as [SEGURO COMPLEMENTARIO]
			--,m.Empresa AS EMPRESA
			,m.RFC AS CEDULA
			,m.EstadoCivil AS [ESTADO CIVIL]
			,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			--,c.NombreAsentamiento as [DIRECCION COLONIA]
			--,localidades.Descripcion as [DIRECCION LOCALIDAD]
			--,Muni.Descripcion as [DIRECCION MUNICIPIO]
			--,est.NombreEstado as [DIRECCION ESTADO]
			--,CP.CodigoPostal as [DIRECCION POSTAL]
			,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			--,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,isnull(deex.TIPO_DE_RESIDENCIA,'') as [TIPO DE RESIDENCIA]
			,isnull(deex.VENCIMIENTO_PERMISO,'') as [VENCIMIENTO PERMISO]
			,mercury.Valor as [MERCURY]
			,ISNULL (ft.ClaveEmpleado,'NO TIENE FOTO') AS [FOTO]
			,Usuario.cuenta as [USER]
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
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = 'RD601')
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
			left join #tempEmailEmpresarial emailEmpresarial
				on emailEmpresarial.IDEmpleado = m.IDEmpleado and emailEmpresarial.[ROW] = 1
			left join #tempEmailPersonal emailPersonal
				on emailPersonal.IDEmpleado = m.IDEmpleado and emailPersonal.[ROW] = 1
			left join #tempData nacionalidad
				on nacionalidad.IDEmpleado = m.IDEmpleado and nacionalidad.IDDatoExtra = 7
			left join #tempData moneda
				on moneda.IDEmpleado = m.IDEmpleado and moneda.IDDatoExtra = 11
			left join #tempData mercury
				on mercury.IDEmpleado = m.IDEmpleado and mercury.IDDatoExtra = 1
			left join rh.tblFotosEmpleados ft
				on m.idempleado = ft.idempleado
			left join Seguridad.tblusuarios usuario  with (nolock)
				on usuario.idempleado = m.idempleado
		Where 
		M.Vigente =0 and
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))   
		and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros2 where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		
				select m.ClaveEmpleado as CLAVE
			,m.NOMBRECOMPLETO as NOMBRE
			,m.Region AS REGION
			,m.Sucursal AS SUCURSAL
			,m.CentroCosto AS [CENTRO COSTO]
			,m.Departamento AS DEPARTAMENTO
			,m.Puesto AS PUESTO
			,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
			,tp.Descripcion as [TIPO PRESTACION]
			,FORMAT(m.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
	       -- ,m.TipoNomina as [TIPO DE NOMINA]
			,m.Area AS AREA
			,m.Division AS DIVISION
			,isnull(deex.CONCESION,'') as [CONCESION]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as SUPERVISOR
			,emailEmpresarial.Value as [EMAIL EMPRESARIAL]
			,m.Sexo AS SEXO
			,FORMAT(m.FechaNacimiento,'dd/MM/yyyy')  as [FECHA NACIMIENTO]
			,nacionalidad.Valor as [NACIONALIDAD]
			,emailPersonal.Value as [EMAIL]
			,CASE 
			      WHEN m.IDCliente = 6 THEN cast((m.SalarioDiario * 24) as decimal(18,2))
				  WHEN m.IDCliente = 5 THEN cast((m.SalarioDiario * 26) as decimal(18,2))
				  WHEN m.IDCliente = 2 THEN cast((m.SalarioDiario * 20) as decimal(18,2))
				  ELSE cast((m.SalarioDiario * 30) as decimal(18,2))
			  END as [SALARIO MENSUAL]
			,m.SalarioDiario AS [SALARIO DIARIO]
			,moneda.Valor as [MONEDA]
			,isnull(deex.INCENTIVO_MENSUAL,'')	as [INCENTIVO MENSUAL]
			,isnull(deex.INCENTIVO_TRIMESTRAL,'')	as [INCENTIVO TRIMESTRAL]
			,isnull(deex.INCENTIVO_ANUAL,'')	as [INCENTIVO ANUAL]
			,isnull(deex.MONEDA_INCENTIVO,'')	as [MONEDA INCENTIVO]
			,isnull(deex.BONO_IDIOMA,'')	as [BONO_IDIOMA]
			,isnull(deex.BONO_ANUAL,'')	as [BONO ANUAL]
			,isnull(deex.MONEDA_BONO,'')	as [MONEDA BONO]
			,isnull(deex.ACTING_AS_INCENTIVE,'')	as [ACTING AS INCENTIVE]
			,isnull(deex.VIGENCIA_ACTING_AS_INCENTIVE,'')	as [VIGENCIA ACTING AS INCENTIVE]
			,isnull(deex.PLAN_SEGURO,'') as [PLAN SEGURO]
			,isnull(deex.SEGUROCOMPLEMENTARIO,'') as [SEGURO COMPLEMENTARIO]
			--,m.Empresa AS EMPRESA
			,m.RFC AS CEDULA
			,m.EstadoCivil AS [ESTADO CIVIL]
			,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			--,c.NombreAsentamiento as [DIRECCION COLONIA]
			--,localidades.Descripcion as [DIRECCION LOCALIDAD]
			--,Muni.Descripcion as [DIRECCION MUNICIPIO]
			--,est.NombreEstado as [DIRECCION ESTADO]
			--,CP.CodigoPostal as [DIRECCION POSTAL]
			,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion as BANCO
			--,PE.Interbancaria as [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,isnull(deex.TIPO_DE_RESIDENCIA,'') as [TIPO DE RESIDENCIA]
			,isnull(deex.VENCIMIENTO_PERMISO,'') as [VENCIMIENTO PERMISO]
			,mercury.Valor as [MERCURY]
			,ISNULL (ft.ClaveEmpleado,'NO TIENE FOTO') AS [FOTO]
			,Usuario.cuenta as [USER]
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
					and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = 'RD601')
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
			left join #tempEmailEmpresarial emailEmpresarial
				on emailEmpresarial.IDEmpleado = m.IDEmpleado and emailEmpresarial.[ROW] = 1
			left join #tempEmailPersonal emailPersonal
				on emailPersonal.IDEmpleado = m.IDEmpleado and emailPersonal.[ROW] = 1
			left join #tempData nacionalidad
				on nacionalidad.IDEmpleado = m.IDEmpleado and nacionalidad.IDDatoExtra = 7
			left join #tempData moneda
				on moneda.IDEmpleado = m.IDEmpleado and moneda.IDDatoExtra = 11
			left join #tempData mercury
				on mercury.IDEmpleado = m.IDEmpleado and mercury.IDDatoExtra = 1
			left join rh.tblFotosEmpleados ft
				on m.idempleado = ft.idempleado
			left join Seguridad.tblusuarios usuario  with (nolock)
				on usuario.idempleado = m.idempleado
		Where 
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'RegPatronales' and isnull(Value,'')<>''))) 
		 and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'ClasificacionesCorporativas'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros2 where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros2 where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros2 where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
				order by M.ClaveEmpleado asc
	END
END
GO

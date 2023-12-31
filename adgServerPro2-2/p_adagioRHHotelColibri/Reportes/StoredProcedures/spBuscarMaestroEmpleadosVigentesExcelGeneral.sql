USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE procedure [Reportes].[spBuscarMaestroEmpleadosVigentesExcelGeneral] (
	--@FechaIni date, 
	--@FechaFin date, 
	--@TipoVigente varchar(max) = '1',  
	--@TipoNomina varchar(max) = '0', 
	--@ClaveEmpleadoInicial Varchar(20) = '0',    
	--@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
	--@Cliente Varchar(max) = '',
	--@Departamentos Varchar(max) = '',
	--@Sucursales Varchar(max) = '',
	--@Puestos Varchar(max) = '',
	--@RazonesSociales Varchar(max) = '',
	--@RegPatronales Varchar(max) = '',
	--@Divisiones Varchar(max) = '',
	--@Prestaciones Varchar(max) = '',
	--@IDUsuario int
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
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

	--Declare --@dtFiltros [Nomina].[dtFiltrosRH]
	--		  @dtEmpleados [RH].[dtEmpleados]
	--		 ,@IDTipoNomina int
	--		 ,@IDTipoVigente int
	--		 ,@Titulo VARCHAR(MAX) = UPPER( 'REPORTE MAESTRO DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

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

	--SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	--SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	--SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	--SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))

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


	if object_id('tempdb..#tempDatosExtra')	is not null drop table #tempDatosExtra 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida
	if object_id('tempdb..##tempDatosExtraEmpleados')is not null drop table ##tempDatosExtraEmpleados

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

	--select len(@query1) +len( @query2) 

	exec( @query1 + @query2) 

	-- select * from ##tempDatosExtraEmpleados
    -- RETURN



	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
			 m.ClaveEmpleado as CLAVE
			,m.Paterno AS PATERNO
			,m.Materno AS MATERNO
			,CONCAT(m.Nombre, ' ') AS NOMBRE
			,CONCAT(m.SegundoNombre,'') AS [SEGUNDO NOMBRE]
			,CONCAT(m.paterno,'',m.materno,'',m.nombre,'',m.SegundoNombre,'') AS [NOMBRE COMPLETO 1]
			,m.NOMBRECOMPLETO as [NOMBRE COMPLETO]
			,m.RFC AS RFC
			,m.CURP AS CURP
			,m.IMSS AS IMSS
			,m.FechaIngreso AS [FECHA INGRESO]
			,m.FechaAntiguedad AS [FECHA ANTIGUEDAD]
			,m.Cliente AS CLIENTE
			,m.Empresa AS EMPRESA
			,m.RegPatronal AS [REGISTRO PATRONAL]
            ,m.CentroCosto AS [CENTRO DE COSTO]
			,m.Departamento AS DEPARTAMENTO
            ,m.Sucursal AS SUCURSAL
	        ,m.CentroCosto AS [CENTRO COSTO]
            ,m.Area AS AREA
    	    ,m.Puesto AS PUESTO
			,tp.Descripcion as [TIPO PRESTACION]
			,m.Sucursal AS SUCURSAL
	        ,m.Division AS DIVISION
			,m.Region AS REGION
            ,m.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
            ,m.TipoNomina AS [TIPO NOMINA]
            ,LP.Descripcion AS [LAYOUT PAGO]
			,Bancos.Descripcion AS BANCO
			,PE.Interbancaria AS [CLABE INTERBANCARIA]
			,PE.Cuenta as [NUMERO CUENTA]
			,PE.Tarjeta AS [NUMERO TARJETA]
			,m.SalarioDiario AS [SALARIO DIARIO]
			,m.SalarioIntegrado AS [SALARIO INTEGRADO]
			,m.SalarioVariable AS [SALARIO VARIABLE]
			,m.SalarioDiarioReal AS [SALARIO DIARIO REAL]
			,cte.[Value] as [Email Empresarial]
			,PTU.PTU AS PTU
			,m.Afore AS AFORE
			,TT.Descripcion as [TIPO TRABAJADOR SUA]
			,TC.Descripcion as [TIPO CONTRATO SAT]
			,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = m.IDEmpleado
				) as Supervisor

			--,CONCAT(Infonavit.NumeroCredito,'') AS [NUM CREDITO INFONAVIT]
			--,CONCAT(InfonavitTipoDescuento.Descripcion,'') AS [TIPO DESCUENTO INFONAVIT]
			--,CONCAT(Infonavit.ValorDescuento,'') AS [VALOR DESCUENTO INFONAVIT]
			--,CONCAT(Infonavit.Fecha,'') AS [FECHA OTORGAMIENTO INFONAVIT]
			,m.EstadoCivil AS [ESTADO CIVIL]
			,m.Sexo AS SEXO
			,m.FechaNacimiento AS [FECHA NACIMIENTO]
			,m.PaisNacimiento AS [PAIS NACIMIENTO]
			,m.EstadoNacimiento AS [ESTADO NACIMIENTO]
			,m.MunicipioNacimiento AS [MUNICIPIO NACIMIENTO]
			,m.LocalidadNacimiento AS [LOCALIDAD NACIMIENTO]
			,substring(UPPER(COALESCE(direccion.calle,'')+' '+COALESCE(direccion.Exterior,'')+' '+COALESCE(direccion.Interior,'')),1,49) as DIRECCION
			,est.NombreEstado as [DIRECCION ESTADO]
			--,CONCAT(CP.CodigoPostal,'') as [DIRECCION POSTAL]
			--,CONCAT(c.NombreAsentamiento,'') as [DIRECCION COLONIA]
			--,CONCAT(localidades.Descripcion,'') as [DIRECCION LOCALIDAD]
			--,CONCAT(Muni.Descripcion,'') as [DIRECCION MUNICIPIO]
			--,CONCAT(m.Escolaridad,'') AS ESCOLARIDAD
			,m.DescripcionEscolaridad AS [DESCRIPCION ESCOLARIDAD]
			,m.Institucion AS INSTITUCION
			,m.Probatorio AS PROBATORIO
			--,CONCAT(rutas.Descripcion,'') AS [RUTA TRANSPORTE]
			,m.Vigente AS [VIGENTE HOY]
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
			left join RH.tblContactoEmpleado ct 
				on m.IDEmpleado = ct.IDEmpleado and ct.IDTipoContactoEmpleado = 1
			left join RH.tblContactoEmpleado cte
				on m.IDEmpleado = cte.IDEmpleado and cte.IDTipoContactoEmpleado = 5
			order by M.ClaveEmpleado asc

	END
	
END
GO

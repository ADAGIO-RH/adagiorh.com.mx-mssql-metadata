USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoIncapacidades] (
	@dtFiltros Nomina.dtFiltrosRH readonly            
	,@IDUsuario int = 1
) as
	declare 
		@empleados [RH].[dtEmpleados]   
		,@FechaIni date 
		,@FechaFin date 
		,@ClaveEmpleadoInicial varchar(20) = '0'
		,@ClaveEmpleadoFinal varchar(20) ='zzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
	;

	SET @ClaveEmpleadoInicial = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')  
	SET @ClaveEmpleadoFinal = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')  
	SET @FechaIni = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
	SET @FechaFin = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  

	--Cliente, 
	--Razón Social, 
	--División, 
	--Región, 
	--Centro de Costo, 
	--Departamento,
	--Área, 
	--Sucursal, 
	--Puesto, 
	--Clasificación Corporativa, 
	--Prestación

	IF OBJECT_ID('tempdb..#tempEmpleados') IS NOT NULL DROP TABLE #tempEmpleados   

  	create table #tempEmpleados   (
		[IDEmpleado] [int] NULL,
        [ClaveEmpleado] [varchar](20) NULL,
        [RFC] [varchar](20) NULL,
        [CURP] [varchar](20) NULL,
        [IMSS] [varchar](20) NULL,
        [Nombre] [varchar](50) NULL,
        [SegundoNombre] [varchar](50) NULL,
        [Paterno] [varchar](50) NULL,
        [Materno] [varchar](50) NULL,
        [NOMBRECOMPLETO] [varchar](50) NULL,
        [IDLocalidadNacimiento] [int] NULL,
        [LocalidadNacimiento] [varchar](100) NULL,
        [IDMunicipioNacimiento] [int] NULL,
        [MunicipioNacimiento] [varchar](100) NULL,
        [IDEstadoNacimiento] [int] NULL,
        [EstadoNacimiento] [varchar](100) NULL,
        [IDPaisNacimiento] [int] NULL,
        [PaisNacimiento] [varchar](100) NULL,
        [FechaNacimiento] [date] NULL,
        [IDEstadoCiviL] [int] NULL,
        [EstadoCivil] [varchar](100) NULL,
        [Sexo] [varchar](15) NULL,
        [IDEscolaridad] [int] NULL,
        [Escolaridad] [varchar](100) NULL,
        [DescripcionEscolaridad] [varchar](100) NULL,
        [IDInstitucion] [int] NULL,
        [Institucion] [varchar](100) NULL,
        [IDProbatorio] [int] NULL,
        [Probatorio] [varchar](100) NULL,
        [FechaPrimerIngreso] [date] NULL,
        [FechaIngreso] [date] NULL,
        [FechaAntiguedad] [date] NULL,
        [Sindicalizado] [bit] NULL,
        [IDJornadaLaboral] [int] NULL,
        [JornadaLaboral] [varchar](100) NULL,
        [UMF] [varchar](10) NULL,
        [CuentaContable] [varchar](50) NULL,
        [IDTipoRegimen] [int] NULL,
        [TipoRegimen] [varchar](200) NULL,
        [IDPreferencia] [int] NULL,
        [IDDepartamento] [int] NULL,
        [Departamento] [varchar](max) NULL,
        [IDSucursal] [int] NULL,
        [Sucursal] [varchar](max) NULL,
        [IDPuesto] [int] NULL,
        [Puesto] [varchar](max) NULL,
        [IDCliente] [int] NULL,
        [Cliente] [varchar](max) NULL,
        [IDEmpresa] [int] NULL,
        [Empresa] [varchar](max) NULL,
        [IDCentroCosto] [int] NULL,
        [CentroCosto] [varchar](max) NULL,
        [IDArea] [int] NULL,
        [Area] [varchar](max) NULL,
        [IDDivision] [int] NULL,
        [Division] [varchar](max) NULL,
        [IDRegion] [int] NULL,
        [Region] [varchar](max) NULL,
        [IDClasificacionCorporativa] [int] NULL,
        [ClasificacionCorporativa] [varchar](max) NULL,
        [IDRegPatronal] [int] NULL,
        [RegPatronal] [varchar](max) NULL,
        [IDTipoNomina] [int] NULL,
        [TipoNomina] [varchar](max) NULL,
        [SalarioDiario] [decimal](18, 2) NULL,
        [SalarioDiarioReal] [decimal](18, 2) NULL,
        [SalarioIntegrado] [decimal](18, 2) NULL,
        [SalarioVariable] [decimal](18, 2) NULL,
        [IDTipoPrestacion] [int] NULL,
        [IDRazonSocial] [int] NULL,
        [RazonSocial] [varchar](max) NULL,
        [IDAfore] [int] NULL,
        [Afore] [varchar](max) NULL,
        [Vigente] [bit] NULL,
        [RowNumber] [int] NULL,
        [ClaveNombreCompleto] [varchar](500) NULL,
        [PermiteChecar] [bit] NULL,
        [RequiereChecar] [bit] NULL,
        [PagarTiempoExtra] [bit] NULL,
        [PagarPrimaDominical] [bit] NULL,
        [PagarDescansoLaborado] [bit] NULL,
        [PagarFestivoLaborado] [bit] NULL,
        [IDDocumento] [int] NULL,
        [Documento] [varchar](max) NULL,
        [IDTipoContrato] [int] NULL,
        [TipoContrato] [varchar](max) NULL,
        [FechaIniContrato] [date] NULL,
        [FechaFinContrato] [date] NULL,
        [TiposPrestacion] [varchar](max) NULL,
        [tipoTrabajadorEmpleado] [varchar](max) NULL
	)


    --insert into @empleados    
    insert into #tempEmpleados            
	exec [RH].[spBuscarEmpleados] --@FechaIni=@FechaIni, @Fechafin = @FechaIni, 
	@dtFiltros = @dtFiltros,@EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal, @IDUsuario = @IDUsuario    



	select 
	   E.RegPatronal  as [REGISTRO PATRONAL]
	   ,E.ClaveEmpleado AS CLAVE
	   ,E.NOMBRECOMPLETO AS NOMBRE
	   ,E.IMSS AS IMSS
	   ,UPPER(IE.Numero) as NUMERO
	   ,isnull(IE.Duracion,0) as DURACION
	   ,FORMAT(IE.Fecha,'dd/MM/yyyy')  as [FECHA INICIO]
	   ,FORMAT(DATEADD(DAY,case when IE.Duracion > 0 THEN IE.Duracion - 1 else 0 end,IE.Fecha),'dd/MM/yyyy') as [FECHA FIN]
	   ,UPPER(TI.Descripcion) as [TIPO INCAPACIDAD]
	   ,UPPER(TRI.Nombre) as [TIPO RIESGO]
	   ,CI.Nombre as [CLASIFICACION INCAPCIDAD]
	   ,(Select count(*) from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'I' and IDIncapacidadEmpleado = IE.IDIncapacidadEmpleado and Fecha Between @FechaIni and @FechaFin) as [DIAS PERIODO]
		,E.RazonSocial AS [RAZON SOCIAL]
		,E.Division AS DIVISION
		,E.ClasificacionCorporativa AS [CLASIFICACION CORPORATIVA]
		,E.CentroCosto AS [CENTRO COSTO]
		,E.Departamento AS DEPARTAMENTO
		,E.Sucursal AS SUCURSAL
		,E.Puesto AS PUESTO
		,E.TiposPrestacion AS [TIPO PRESTACION]
		,FORMAT(GETDATE(),'dd/MM/yyyy')  as [FECHA HOY]
		,case when E.Vigente=1 then 'Si' else 'No' end as [VIGENTE HOY]

	from Asistencia.tblIncapacidadEmpleado IE
		--INNER JOIN @empleados E --with (nolock)  
		INNER JOIN #tempEmpleados E --with (nolock)  
			on IE.IDEmpleado = E.IDEmpleado
		Left join SAT.tblCatTiposIncapacidad TI
			on TI.IDTIpoIncapacidad = IE.IDTipoIncapacidad
		Left join IMSS.tblCatClasificacionesIncapacidad CI
			on CI.IDClasificacionIncapacidad = IE.IDClasificacionIncapacidad
		Left join IMSS.tblCatTipoRiesgoIncapacidad TRI
			on IE.IDTipoRiesgoIncapacidad = TRI.IDTipoRiesgoIncapacidad 

	WHERE IE.IDIncapacidadEmpleado in (
		SELECT Distinct IDIncapacidadEmpleado
		FROM Asistencia.tblIncidenciaEmpleado 
		where IDIncidencia = 'I' 
			and Fecha Between @FechaIni and @FechaFin
		)
		 and ((IE.IDTipoIncapacidad in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TipoIncapacidad' and isnull(Value,'')<>''))) 
	ORDER BY  E.RegPatronal ASC
	   ,E.ClaveEmpleado ASC
GO

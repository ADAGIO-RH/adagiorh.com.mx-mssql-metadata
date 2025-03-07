USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spAsistenciaDiaria_SURFAX] (
	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario			int  
) as
	SET NOCOUNT ON;
    IF 1=0 
	BEGIN
		SET FMTONLY OFF
    END

	declare
		 @FechaInicio		date
		,@FechaFin			date
		,@IDTipoNomina		int = 0
		,@Fechas [App].[dtFechas] 
		,@dtEmpleados RH.dtEmpleados
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20)  
		
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@TiempoEntreChecadas int
	;

	select @TiempoEntreChecadas = Valor from app.tblConfiguracionesGenerales where IDConfiguracion = 'TiempoEntreChecadas'

	SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoNomina'),',')),0)

	SET @FechaInicio	= (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin		= (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	
	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias;  
	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;  
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;    
	
	select
		IDIncidencia
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,EsAusentismo
		,GoceSueldo
		,PermiteChecar
		,AfectaSUA
		,TiempoIncidencia
		,Color
		,Autorizar
		,GenerarIncidencias
		,Intranet
		,AdministrarSaldos
	INTO #tempCatIncidencias
	from Asistencia.tblCatIncidencias

	create table #tempDiasVigencias (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);


	insert @Fechas
	exec App.spListaFechas @FechaIni = @FechaInicio, @FechaFin = @FechaFin

	insert @dtEmpleados
	exec [RH].[spBuscarEmpleadosMaster] 
		@FechaIni	= @FechaInicio         
		,@Fechafin	= @FechaFin           
		,@IDUsuario		= @IDUsuario              
		,@IDTipoNomina	= @IDTipoNomina
		,@dtFiltros		= @dtFiltros
		,@EmpleadoIni = @EmpleadoIni  
		,@EmpleadoFin = @EmpleadoFin  

	insert #tempDiasVigencias
	exec RH.spBuscarListaFechasVigenciaEmpleado  
		@dtEmpleados = @dtEmpleados 
		,@Fechas = @Fechas
		,@IDUsuario = @IDUsuario 

	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join #tempDiasVigencias tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and c.FechaOrigen = tempEmp.Fecha and tempEmp.Vigente = 1

	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join #tempDiasVigencias tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1

	SELECT 
		Results.IDEmpleado
		,Results.Fecha
		,STUFF((
		SELECT distinct ', ' + ci.Descripcion+'('+ci.IDIncidencia+')'
		FROM #tempAusentismosIncidencias tai
			join #tempCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R') and isnull(ci.EsAusentismo,0) = 1
		where tai.IDEmpleado = Results.IDEmpleado and tai.Fecha = Results.Fecha
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		,1,2,'') AS Ausentismos
	INTO #tempAusentismosFinal
	FROM #tempAusentismosIncidencias Results
		join #tempCatIncidencias ci with (nolock) on Results.IDIncidencia = ci.IDIncidencia and isnull(ci.EsAusentismo,0) = 1
	where Results.IDIncidencia not in ('EX','R')
	GROUP BY Results.IDEmpleado,Results.Fecha

	--select * from #tempAusentismosIncidencias

	SELECT 
		Results.IDEmpleado
		,Results.Fecha
		,STUFF((
		SELECT distinct ', ' + ci.Descripcion+'('+ci.IDIncidencia+')'
		FROM #tempAusentismosIncidencias tai
			join #tempCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R') and isnull(ci.EsAusentismo,0) = 0
		where tai.IDEmpleado = Results.IDEmpleado and tai.Fecha = Results.Fecha
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		,1,2,'') AS Incidencias
	INTO #tempIncidenciasFinal
	FROM #tempAusentismosIncidencias Results
		join #tempCatIncidencias ci with (nolock) on Results.IDIncidencia = ci.IDIncidencia and isnull(ci.EsAusentismo,0) = 0
	where Results.IDIncidencia not in ('EX','R')
	GROUP BY Results.IDEmpleado,Results.Fecha

	if OBJECT_ID('tempdb..#resp') is not null drop table #resp;

	create table #resp (
		IDEmpleado          int
		,ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Division			varchar(500)
		,Requiere_Checar    bit
		,FechasAsDate	    date
		,Fecha				date
		,Dia				varchar(3)
		,Horario			varchar(50)
		,EntradaTrabajo		datetime
		,EntradaComida		datetime
		,SalidaComida		datetime
		,SalidaTrabajo		datetime
		,Ausentismos		varchar(max)
		,Incidencias		varchar(max)
		,Tiempo_Extra		time
		,Retardo			time
		,TiempoTrabajado	 AS CONVERT(VARCHAR,SalidaTrabajo - EntradaTrabajo,8)
		
	)

	insert #resp(
		IDEmpleado
		,ClaveEmpleado	
		,NOMBRECOMPLETO	
		,Departamento	
		,Sucursal	
		,Puesto			
		,Division
		,Requiere_Checar
		,FechasAsDate
		,Fecha			
		,Dia			
		,Horario
		,Ausentismos	
		,Incidencias	
		,Tiempo_Extra
		,Retardo		
	)
	select 
		em.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.Departamento
		,em.Sucursal 
		,em.Puesto
		,em.Division
		,em.RequiereChecar
		,e.Fecha As FechaAsDate
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,isnull(catHorarios.Codigo,'SIN HORARIO') Horario
		,ausentismos.Ausentismos
		,incidencias.Incidencias
		,(select top 1 TiempoAutorizado 
			from #tempAusentismosIncidencias 
			where IDIncidencia = 'EX' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Tiempo_Extra
		,(select top 1 TiempoAutorizado 
			from #tempAusentismosIncidencias 
			where IDIncidencia = 'R' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Retardo
	from #tempDiasVigencias e
		join RH.tblEmpleadosMaster em with(nolock) on e.IDEmpleado = em.IDEmpleado
		left join Asistencia.tblHorariosEmpleados he with(nolock) on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios catHorarios with(nolock) on he.IDHorario = catHorarios.IDHorario
		left join #tempAusentismosFinal ausentismos with(nolock) on ausentismos.IDEmpleado = e.IDEmpleado and ausentismos.Fecha = e.Fecha
		left join #tempIncidenciasFinal incidencias with(nolock) on incidencias.IDEmpleado = e.IDEmpleado and incidencias.Fecha = e.Fecha
		 
	where e.Vigente  = 1
	order by em.ClaveEmpleado, e.Fecha

	update r
		set r.EntradaTrabajo = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha asc)
    from #resp r

	update r
		set r.SalidaTrabajo = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha desc)
    from #resp r

	
	update r
		set r.EntradaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaTrabajo) order by fecha asc)
    from #resp r

	
	update r
		set r.SalidaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaComida) order by fecha asc)
    from #resp r

	select 
	ClaveEmpleado	 as [Clave]
	,NOMBRECOMPLETO	as [NOMBRE COMPLETO]
	,Departamento AS [DEPTO]
	,Sucursal AS [SUCURSAL]
	,Puesto		AS [PUESTO]
	,Division	AS [DIVISION]
	,Requiere_Checar
	--,FechasAsDate
	,FORMAT(Fecha,'dd/MM/yyyy') as [FECHA_]	
	--,Fecha AS OrderDate
	,Dia AS [DIA ]	
	,Horario AS [HORARIO]	
	,case when EntradaTrabajo is not null then FORMAT(EntradaTrabajo,'HH:mm:ss') else null end [Entrada Trabajo]
	,case when EntradaComida is not null then FORMAT(EntradaComida,  'HH:mm:ss') else null end  [Entrada Comida]	
	,case when SalidaComida	 is not null then FORMAT(SalidaComida ,  'HH:mm:ss') else null end  [Salida Comida]	
	,case when SalidaTrabajo is not null then FORMAT(SalidaTrabajo,  'HH:mm:ss') else null end  [Salida Trabajo]	
	,Ausentismos		
	,Incidencias	
	,Tiempo_Extra AS [TIEMPO EXTRA]
	,Retardo		
	from #resp
	order by ClaveEmpleado, Fecha
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias;  
	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;  
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;
GO

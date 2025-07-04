USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spAsistenciaDiaria_ARCOS_COMEDOR] (
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
	;

	SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)

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
		 ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Division			varchar(500)
		,Requiere_Checar	bit
		,FechaAsDate				date
		,Fecha				date
		,Dia				varchar(3)
		,Horario			varchar(50)
		,Entrada			datetime
		,Salida				datetime
		,TiempoTrabajado	 AS CONVERT(VARCHAR,Salida - Entrada,8)
		,Ausentismos		varchar(max)
		,Incidencias		varchar(max)
		,Tiempo_Extra		time
		,Retardo			time
		,Entrada_SH			datetime
		,Salida_SH			datetime
		,Entrada_Comida		datetime
		,Salida_Comida		datetime
		,TiempoTrabajado_SH AS CONVERT(VARCHAR,Salida_SH - Entrada_SH,8)
	)

	insert #resp(
		 ClaveEmpleado	
		,NOMBRECOMPLETO	
		,Departamento	
		,Division		
		,Puesto			
		,Sucursal	
		,Requiere_Checar
		,FechaAsDate			
		,Fecha			
		,Dia			
		,Horario		
		,Entrada		
		,Salida			
		,Entrada_SH		
		,Salida_SH		
		,Entrada_Comida
		,Salida_Comida
		,Ausentismos	
		,Incidencias	
		,Tiempo_Extra	
		,Retardo		
	)
	select 
		--em.IDEmpleado
		--,
		em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.Departamento
		,em.Division
		,em.Puesto
		,em.Sucursal
		,em.RequiereChecar
		,e.Fecha as FechaAsDate
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,isnull(catHorarios.Codigo,'SIN HORARIO') Horario
		,(select top 1 cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('ET') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha asc) Entrada
		,(select top 1  cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('ST') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Salida
		,(select top 1  cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha asc) Entrada_SH
		,(select top 1  cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Salida_SH
		,(select top 1 cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('EC') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha asc) Entrada_Comida
		,(select top 1 cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('SC') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Salida_Comida
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

	select  ClaveEmpleado as [CLAVE EMPLEADO]		
			,NOMBRECOMPLETO as NOMBRE		
			,Departamento as DEPARTAMENTO		
			,Sucursal as SUCURSAL			
			,Puesto as PUESTO				
			,Division as DIVISION		
			--,Fecha AS FechaAsDate
			,CASE WHEN Requiere_Checar = 1 THEN 'SI' ELSE 'NO' END [REQ. CHECAR]
			,FORMAT(Fecha,'dd/MM/yyyy') as FECHA			
			,Dia as [DIA ]				
			,Horario as HORARIO			
			,cast(cast(Entrada as time) as varchar(8)) as ENTRADA
			,cast(cast(Salida as time)  as varchar(8)) as SALIDA
			,cast(cast(TiempoTrabajado as time)  as varchar(8))	as [TIEMPO TRABAJADO] 	
			,Ausentismos	as AUSENTISMOS	
			,Incidencias	as INCIDENCIAS	
			,cast(cast(Tiempo_Extra as time)  as varchar(8))	as [TIEMPO EXTRA] 			
			,cast(cast(Retardo as time)  as varchar(8))	as RETARDO 		
			,cast(cast(Entrada_SH as time) as varchar(8))	as [ENTRADA SH]
			,cast(cast(Salida_SH as time)  as varchar(8))	as [SALIDA SH]
			,cast(cast(Entrada_Comida as time)  as varchar(8))	as [ENTRADA COMIDA]
			,cast(cast(Salida_Comida as time)  as varchar(8))	as [SALIDA COMIDA]
			,cast(cast(TiempoTrabajado_SH as time)  as varchar(8))	as [TIEMPO TRABAJADA SH] 	 
	from #resp
	order by ClaveEmpleado,FechaAsDate
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias;  
	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;  
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;
GO

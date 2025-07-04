USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Asistencia].[spBuscarAsistenciaPorDiaBarChart]( 
	@PageNumber	int = 1
	,@PageSize		int = 5
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int
) as

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

		,@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00

		,@label varchar(250)
		,@labelTemplateJSON varchar(max) = '{
			"esmx": "Últimos 30 días del %s al %s",
			"enus": "Last 30 days from %s to %s"
		}'
	;

	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias;  
	if object_id('tempdb..#tempEmpleadosPag')	is not null drop table #tempEmpleadosPag;  
	if object_id('tempdb..#tempEmpleados')		is not null drop table #tempEmpleados;  
	if object_id('tempdb..#tempDiasVigencias')	is not null drop table #tempDiasVigencias;  
	if object_id('tempdb..#tempChecadas')	is not null drop table #tempChecadas;  
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if OBJECT_ID('tempdb..#resp')			is not null drop table #resp;

	create table #tempDiasVigencias (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);

	create table #resp (
		 IDEmpleado			int
		,Fecha				date
		,Dia				varchar(3)
		,Horario			varchar(50)
		,Entrada			time
		,Salida				time
		,TiempoTrabajado	AS CONVERT(VARCHAR,cast(Salida as datetime) - cast(Entrada as datetime),8)
		,Ausentismos		varchar(max)
		,Incidencias		varchar(max)
		,Tiempo_Extra		time
		,Retardo			time
		,Entrada_SH			datetime
		,Salida_SH			datetime
		,TiempoTrabajado_SH AS CONVERT(VARCHAR,Salida_SH - Entrada_SH,8)
	)

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end

	select 
		@FechaInicio = dateadd(day, -30, getdate()),
		@FechaFin = getdate()

	select @label = FORMATMESSAGE(JSON_VALUE(@labelTemplateJSON, FORMATMESSAGE('$.%s', lower(replace(@IDIdioma, '-','')))),FORMAT(@FechaInicio, 'dd/MM/yyyy'), FORMAT(@FechaFin, 'dd/MM/yyyy'))	

	SET DATEFIRST 7;

	select
		IDIncidencia
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,EsAusentismo
		,GoceSueldo
		--,PermiteChecar
		--,AfectaSUA
		--,TiempoIncidencia
		--,Color
		--,Autorizar
		--,GenerarIncidencias
		--,Intranet
		--,AdministrarSaldos
	INTO #tempCatIncidencias
	from Asistencia.tblCatIncidencias

	insert @Fechas
	exec App.spListaFechas @FechaIni = @FechaInicio, @FechaFin = @FechaFin

	select
		e.IDEmpleado, 
		e.ClaveEmpleado, 
		e.NOMBRECOMPLETO as Colaborador,
		e.Nombre,
		e.Paterno,
		SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1) as Iniciales,
		case when e.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
	INTO #tempEmpleadosPag
	from  RH.tblEmpleadosMaster e
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfeu on dfeu.IDEmpleado = e.IDEmpleado and dfeu.IDUsuario = @IDUsuario
		left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = e.IDEmpleado  
	where e.Vigente = 1	

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempEmpleadosPag

	select @TotalRegistros = cast(COUNT(IDEmpleado) as decimal(18,2)) from #tempEmpleadosPag		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	INTO #tempEmpleados
	from #tempEmpleadosPag
	order by ClaveEmpleado
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

	insert @dtEmpleados(IDEmpleado)
	select IDEmpleado
	from #tempEmpleados

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
		distinct
		Results.IDEmpleado
		,Results.Fecha
		,(
			SELECT distinct ci.Descripcion+'('+ci.IDIncidencia+')' as Incidencia, ci.EsAusentismo, ci.GoceSueldo
			FROM #tempAusentismosIncidencias tai
				join #tempCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R')-- and isnull(ci.EsAusentismo,0) = 1
			where tai.IDEmpleado = Results.IDEmpleado and tai.Fecha = Results.Fecha
			order by  ci.EsAusentismo desc
			for json auto
		) as Ausentismos
		--,STUFF((
		--SELECT distinct ', ' + ci.Descripcion+'('+ci.IDIncidencia+')'
		--FROM #tempAusentismosIncidencias tai
		--	join #tempCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R') and isnull(ci.EsAusentismo,0) = 1
		--where tai.IDEmpleado = Results.IDEmpleado and tai.Fecha = Results.Fecha
		--FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		--,1,2,'') AS Ausentismos
	INTO #tempAusentismosFinal
	FROM #tempAusentismosIncidencias Results
		--join #tempCatIncidencias ci with (nolock) on Results.IDIncidencia = ci.IDIncidencia --and isnull(ci.EsAusentismo,0) = 1
	--where Results.IDIncidencia not in ('EX','R')
	--GROUP BY Results.IDEmpleado,Results.Fecha

	insert #resp(
		 IDEmpleado	
		,Fecha			
		,Dia			
		,Horario		
		,Entrada		
		,Salida			
		,Entrada_SH		
		,Salida_SH		
		,Ausentismos	
		--,Incidencias	
		--,Tiempo_Extra	
		--,Retardo		
	)
	select 
		em.IDEmpleado
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
		,ausentismos.Ausentismos
		--,incidencias.Incidencias
		--,(select top 1 TiempoAutorizado 
		--	from #tempAusentismosIncidencias 
		--	where IDIncidencia = 'EX' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha desc) Tiempo_Extra
		--,(select top 1 TiempoAutorizado 
		--	from #tempAusentismosIncidencias 
		--	where IDIncidencia = 'R' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha desc) Retardo
	from #tempDiasVigencias e
		join RH.tblEmpleadosMaster em with(nolock) on e.IDEmpleado = em.IDEmpleado
		left join Asistencia.tblHorariosEmpleados he with(nolock) on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios catHorarios with(nolock) on he.IDHorario = catHorarios.IDHorario
		left join #tempAusentismosFinal ausentismos with(nolock) on ausentismos.IDEmpleado = e.IDEmpleado and ausentismos.Fecha = e.Fecha
		--left join #tempIncidenciasFinal incidencias with(nolock) on incidencias.IDEmpleado = e.IDEmpleado and incidencias.Fecha = e.Fecha

	--select * from #resp

	select *, @label as [label],
	(
		select *
		from #resp
		where IDEmpleado = #tempEmpleados.IDEmpleado
		order by Fecha
		for json auto
	) as [data]
	from #tempEmpleados
GO

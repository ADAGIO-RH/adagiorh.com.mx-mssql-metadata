USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spAsistenciaDiariaAfosa] (
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

		select c.*,
	ROW_NUMBER() OVER(partition by c.idempleado,c.fechaorigen order BY c.fecha asc ) AS [Cantidad]
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join #tempDiasVigencias tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and c.FechaOrigen = tempEmp.Fecha and tempEmp.Vigente = 1

			select 
		count (c.IDChecada)as Suma,
		c.IDEmpleado,
		c.FechaOrigen
	into #tempChecadasconteo
	from #tempChecadas c
	group by c.IDEmpleado,c.FechaOrigen

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
		 IDEmpleado int,
		 ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,Fecha				date
		,Dia				varchar(3)
		--,Horario			varchar(50)
		,checada1		datetime
		,checada2		datetime
		,checada3 datetime 
		,checada4	datetime
		,TiempoTrabajado	 AS CONVERT(VARCHAR,(case when conteo = 3 then checada3 
													 when conteo = 4 then checada4
													 else checada2 end) - checada1,8)
		,Ausentismos		varchar(max)
		,Incidencias		varchar(max)
		,conteo				int
	)

	insert #resp(
		 IDEmpleado
		,ClaveEmpleado	
		,NOMBRECOMPLETO			
		,Fecha			
		,Dia			
		--,Horario		
		,checada1		
		,checada2	
		,Conteo
		,Ausentismos	
		,Incidencias
	)
	select 
		em.IDEmpleado
		,
		em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		--,isnull(catHorarios.Codigo,'SIN HORARIO') Horario
		,(select top 1 case when isnull(Fecha,'')>0 then cast(cast(Fecha as time) as varchar(8)) else '' end
			from #tempChecadas 
			where cantidad =1 and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha asc) EntradaTrabajo
		,(select top 1  case when isnull(fecha,'')>0 then cast(cast(Fecha as time) as varchar(8)) else '' end
			from #tempChecadas 
			where cantidad=2 and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) checada2
		,(select top 1  cast(cast(suma as int) as varchar(8))
			from #tempChecadasconteo c
			where c.FechaOrigen = e.Fecha and c.IDEmpleado = e.IDEmpleado
			order by e.Fecha desc) as Conteo
		,ausentismos.Ausentismos
		,incidencias.Incidencias
	from #tempDiasVigencias e
		join RH.tblEmpleadosMaster em with(nolock) on e.IDEmpleado = em.IDEmpleado
		left join Asistencia.tblHorariosEmpleados he with(nolock) on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios catHorarios with(nolock) on he.IDHorario = catHorarios.IDHorario
		left join #tempAusentismosFinal ausentismos with(nolock) on ausentismos.IDEmpleado = e.IDEmpleado and ausentismos.Fecha = e.Fecha
		left join #tempIncidenciasFinal incidencias with(nolock) on incidencias.IDEmpleado = e.IDEmpleado and incidencias.Fecha = e.Fecha
		 
	where e.Vigente  = 1
	order by em.ClaveEmpleado, e.Fecha

	update r
		set r.checada2 = 
		case when r.conteo>2 then (select isnull(Fecha,'') from #tempChecadas where Cantidad=2 and IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha )
		else (select  isnull(Fecha,'') from #tempChecadas where cantidad=2 and IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha )
		end
    from #resp r

	update r
			set r.checada3 = 
				case 
				when r.conteo>2 then (select isnull(Fecha,'') from #tempChecadas where cantidad=3 and FechaOrigen = r.Fecha and IDEmpleado = r.IDEmpleado
				and Fecha>r.checada2) 
				else '' 
				end
		from #resp r

	update r
		set r.checada4 = 
			case 
			when r.conteo>2 then (select isnull(Fecha,'') from #tempChecadas where cantidad=4 and  FechaOrigen = r.Fecha and IDEmpleado = r.IDEmpleado
			and Fecha>r.checada3) 
			else '' 
			end
    from #resp r

	select  ClaveEmpleado as [CLAVE EMPLEADO]		
			,NOMBRECOMPLETO as NOMBRE		
			,FORMAT(Fecha,'dd/MM/yyyy') as FECHA			
			,Dia as [DIA ]				
			--,Horario as HORARIO			
			,case when isnull(checada1,'')>0 then cast(cast(checada1 as time) as varchar(8)) else '' end as [CHECADA 1]
			,case when isnull(checada2,'')>0 then cast(cast(checada2 as time)  as varchar(8)) else '' end as [CHECADA 2]
			,case when isnull(checada3,'')>0 then cast(cast(checada3 as time) as varchar(8)) else '' end as [CHECADA 3]
			,case when isnull(checada4,'')>0 then cast(cast(checada4 as time)  as varchar(8)) else '' end as [CHECADA 4]
			,cast(cast(TiempoTrabajado as time)  as varchar(8))	as [TIEMPO TRABAJADO] 	
			,Ausentismos	as AUSENTISMOS	
			,Incidencias	as INCIDENCIAS	 
	from #resp
	where isnull(conteo,0)>0
	order by ClaveEmpleado,Fecha
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias;  
	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;  
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;
GO

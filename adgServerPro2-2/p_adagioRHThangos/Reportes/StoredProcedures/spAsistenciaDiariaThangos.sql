USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spAsistenciaDiariaThangos] (
	 @FechaIni date 
	,@FechaFin date
	,@Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= ''    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@RazonesSociales varchar(max)  = ''
	,@IDUsuario int
) as


	

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;
		SET FMTONLY OFF    
	declare 
		 @IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechas]   
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		,@Titulo Varchar(max)    
		,@TiempoEntreChecadas int  
	;
	select @TiempoEntreChecadas = Valor from app.tblConfiguracionesGenerales where IDConfiguracion = 'TiempoEntreChecadas'
	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@IDTipoNomina,',')),0)

	insert @dtFiltros(Catalogo,Value)    
	values
		 ('Clientes',@Clientes)    
		,('Divisiones',@Divisiones)    
		,('CentrosCostos',@CentrosCostos)    
		,('Departamentos',@Departamentos)    
		,('Areas',@Areas)    
		,('Sucursales',@Sucursales)    
		,('Prestaciones',@Prestaciones)  
		,('RazonesSociales',@RazonesSociales)  

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    

	SET DATEFIRST 7;  
  
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u  
		Inner join App.tblPreferencias p  
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 

	    
SET @Titulo =  UPPER( 'Lista de Asistencia y puntualidad Entrada del ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' al '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))



	--select *
	--from @Fechas

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		 @FechaIni = @FechaIni           
		,@FechaFin = @FechaFin    
		,@IDTipoNomina = @IDTipoNominaInt         
		,@IDUsuario = @IDUsuario                
		,@dtFiltros = @dtFiltros 
     
	insert @Fechas
	exec App.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin

	select
		IDIncidencia
		--,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,EsAusentismo
		,GoceSueldo
		,PermiteChecar
		,AfectaSUA
		,TiempoIncidencia
		,Color
		,Autorizar
		,GenerarIncidencias
		,Intranet
		--,AdministrarSaldos
	INTO #tempCatIncidencias
	from Asistencia.tblCatIncidencias

	create table #tempDiasVigencias (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);


	
 

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
		SELECT distinct ', ' +'('+ci.IDIncidencia+')'
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
		SELECT distinct ', ' + '('+ci.IDIncidencia+')'
		FROM #tempAusentismosIncidencias tai
			join #tempCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R','SA') and isnull(ci.EsAusentismo,0) = 0
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
		 IDEmpleado			int 
		, ClaveEmpleado		varchar(500)
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
		,Tiempo_Extra		decimal(10,2)
		,Retardo			time
        ,SalidaA            time
		,EntradaComida			datetime
		,SalidaComida			datetime
	)

	insert #resp(
	     IDEmpleado
		 ,ClaveEmpleado	
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
		,EntradaComida	
		,SalidaComida		
		,Ausentismos	
		,Incidencias	
		,Tiempo_Extra	
		,Retardo
        ,SalidaA		
	)
	select 
		em.IDEmpleado
		--,
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.Departamento
		,em.Division
		,em.Puesto
		,em.Sucursal
		,em.RequiereChecar
		,e.Fecha as FechaAsDate
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,isnull(catHorarios.Codigo,'DESCANSO') Horario
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
			where IDTipoChecada in ('EC') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha asc) EntradaComer
		,(select top 1  cast(cast(Fecha as time) as varchar(8))
			from #tempChecadas 
			where IDTipoChecada in ('SC') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) SalidaComer
		,ausentismos.Ausentismos
		,incidencias.Incidencias
		,(select SUM(DATEDIFF(MINUTE, '0:00:00', TiempoAutorizado)) / 60.00 
			from #tempAusentismosIncidencias 
			where IDIncidencia = 'EX' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
            group by IDEmpleado) Tiempo_Extra
		,(select top 1 TiempoAutorizado 
			from #tempAusentismosIncidencias 
			where IDIncidencia = 'R' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Retardo
        ,(select top 1 TiempoAutorizado 
			from #tempAusentismosIncidencias 
			where IDIncidencia = 'SA' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
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
		set r.Entrada = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha asc)
    from #resp r

	update r
		set r.Salida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha desc)
    from #resp r

	
	update r
		set r.EntradaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.Entrada) order by fecha asc)
    from #resp r

	
	update r
		set r.SalidaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaComida) order by fecha asc)
    from #resp r


	select  IDEmpleado
			,ClaveEmpleado as [CLAVE EMPLEADO]		
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
            ,cast(cast(EntradaComida as time) as varchar(8)) as ENTRADACOMIDA
			,cast(cast(SalidaComida as time)  as varchar(8)) as SALIDACOMIDA
			,cast(cast(TiempoTrabajado as time)  as varchar(8))	as [TIEMPO TRABAJADO] 	
			,Ausentismos	as AUSENTISMOS	
			,Incidencias	as INCIDENCIAS	
			,cast(cast(Tiempo_Extra as decimal(10,2)) as varchar(12))  as [TIEMPO EXTRA] 			
			,cast(cast(Retardo as time)  as varchar(8))	as RETARDO
            ,cast(cast(SalidaA as time)  as varchar(8))	as [SALIDA ANTICIPADA] 			 
	from #resp
    --where ClaveEmpleado = '0010021'
	order by ClaveEmpleado,FechaAsDate
	
	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias;  
	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;  
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;
GO

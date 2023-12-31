USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spAsistenciaDiariaNexusRespaldo] (
	 @dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario			int  
) as

	SET NOCOUNT ON;
    IF 1=0 
	BEGIN
		SET FMTONLY OFF
    END

	declare
		 @FechaInicio		date --= '2019-05-01'
		,@FechaFin			date --= '2019-05-29'
		--,@dtDepartamentos	varchar(max) = ''--'1,2,3,4,5,6,7,8,9'
		--,@dtSucursales		varchar(max) = ''--'6,9,10,11,8'
		--,@dtPuestos			varchar(max) = ''--'132,244,72,189,61'
		--,@IDUsuario			int = 1  
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

	select top 1 @IDIdioma = dp.Valor
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p with (nolock)
			on u.IDPreferencia = p.IDPreferencia
		Inner join App.tblDetallePreferencias dp with (nolock)
			on dp.IDPreferencia = p.IDPreferencia
		Inner join App.tblCatTiposPreferencias tp with (nolock)
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario
			and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL

	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;    
	create table #tempDiasVigencias (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;    

	insert @Fechas
	exec App.spListaFechas @FechaIni = @FechaInicio, @FechaFin = @FechaFin

	--insert into @dtFiltros(Catalogo,Value)  
	--values('Departamentos',@dtDepartamentos)  
  
	--insert into @dtFiltros(Catalogo,Value)  
	--values('Sucursales',@dtSucursales)  
   
	--insert into @dtFiltros(Catalogo,Value)  
	--values('Puestos',@dtPuestos)  

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
			join Asistencia.tblCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R') and isnull(ci.EsAusentismo,0) = 1
		where tai.IDEmpleado = Results.IDEmpleado and tai.Fecha = Results.Fecha
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		,1,2,'') AS Ausentismos
	INTO #tempAusentismosFinal
	FROM #tempAusentismosIncidencias Results
		join Asistencia.tblCatIncidencias ci with (nolock) on Results.IDIncidencia = ci.IDIncidencia and isnull(ci.EsAusentismo,0) = 1
	where Results.IDIncidencia not in ('EX','R')
	GROUP BY Results.IDEmpleado,Results.Fecha

	--select * from #tempAusentismosIncidencias

	SELECT 
		Results.IDEmpleado
		,Results.Fecha
		,STUFF((
		SELECT distinct ', ' + ci.Descripcion+'('+ci.IDIncidencia+')'
		FROM #tempAusentismosIncidencias tai
			join Asistencia.tblCatIncidencias ci with (nolock) on tai.IDIncidencia = ci.IDIncidencia and tai.IDIncidencia not in ('EX','R') and isnull(ci.EsAusentismo,0) = 0
		where tai.IDEmpleado = Results.IDEmpleado and tai.Fecha = Results.Fecha
		FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		,1,2,'') AS Incidencias
	INTO #tempIncidenciasFinal
	FROM #tempAusentismosIncidencias Results
		join Asistencia.tblCatIncidencias ci with (nolock) on Results.IDIncidencia = ci.IDIncidencia and isnull(ci.EsAusentismo,0) = 0
	where Results.IDIncidencia not in ('EX','R')
	GROUP BY Results.IDEmpleado,Results.Fecha

	if OBJECT_ID('tempdb..#resp') is not null drop table #resp;

	create table #resp (
		IDEmpleado int
		,ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Division			varchar(500)
		,Fecha				date
		,Dia				varchar(3)
		,Horario			varchar(50)
		,EntradaTrabajo		datetime
		,EntradaComida		datetime
		,SalidaComida		datetime
		,SalidaTrabajo		 datetime
		,Ausentismos		varchar(max)
		,Incidencias		varchar(max)
		,Tiempo_Extra		time
		,Retardo			time
		
	)

	insert #resp(
		IDEmpleado
		,ClaveEmpleado	
		,NOMBRECOMPLETO	
		,Departamento	
		,Division		
		,Puesto			
		,Sucursal		
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
		--,
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.Departamento
		,em.Division
		,em.Puesto
		,em.Sucursal
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,isnull(catHorarios.Codigo,'SIN HORARIO') Horario
		--,(select top 1 cast(cast(Fecha as time) as varchar(8))
		--	from #tempChecadas 
		--	where IDTipoChecada in ('ET','SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha asc) Entrada
		
		--,(select top 1  cast(cast(Fecha as time) as varchar(8))
		--	from #tempChecadas 
		--	where IDTipoChecada in ('EC','SH') 
		--		and FechaOrigen = e.Fecha 
		--		and IDEmpleado = e.IDEmpleado
		--		and Fecha >= (select top 1 DATEADD(MINUTE,@TiempoEntreChecadas,Fecha)
		--					from #tempChecadas 
		--					where IDTipoChecada in ('ET','SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
		--					order by Fecha asc)
		--	order by Fecha asc) EntradaComida
		--,(select top 1  cast(cast(Fecha as time) as varchar(8))
		--	from #tempChecadas 
		--	where IDTipoChecada in ('SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha desc) Salida_SH

		--,(select top 1  cast(cast(Fecha as time) as varchar(8))
		--	from #tempChecadas 
		--	where IDTipoChecada in ('ST') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha desc) Salida

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

	
	DECLARE    
   @bitSH bit
  ,@bitET bit
  ,@bitST bit
  ,@bitEC bit
  ,@bitSC bit


SELECT @bitSH = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'SH'
SELECT @bitET = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'ET'
SELECT @bitST = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'ST'
SELECT @bitEC = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'EC'
SELECT @bitSC = isnull(Activo,0) FROM Asistencia.tblCatTiposChecadas where IDTipoChecada = 'SC'

	update r
		set r.EntradaTrabajo = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and IDTipoChecada = 'ET')
    from #resp r

	update r
		set r.SalidaTrabajo = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and IDTipoChecada = 'ST' )
    from #resp r

	
	--update r
	--	set r.EntradaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaTrabajo)  and IDTipoChecada = 'EC' )
 --   from #resp r

	
	--update r
	--	set r.SalidaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaComida) and IDTipoChecada = 'SC' )
 --   from #resp r

 	update r
		set r.EntradaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and IDTipoChecada = 'EC' )
    from #resp r

	
	update r
		set r.SalidaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha  and IDTipoChecada = 'SC' )
    from #resp r

	select 
	ClaveEmpleado	 as [Clave]
	,NOMBRECOMPLETO	as [NOMBRE COMPLETO]
	,Departamento AS [DEPTO]
	,Sucursal AS [SUCURSAL]
	,Puesto		AS [PUESTO]
	,Division	AS [DIVISION]
	,FORMAT(Fecha,'dd/MM/yyyy') as [FECHA]	
	,Dia AS [DIA ]	
	,Horario AS [HORARIO]	
	,case when EntradaTrabajo is not null and @bitET = 1  then FORMAT(EntradaTrabajo,'HH:mm:ss') else null end [Entrada Trabajo]
	,case when EntradaComida is not null and @bitEC = 1 then FORMAT(EntradaComida,  'HH:mm:ss') else null end  [Entrada Comida]	
	,case when SalidaComida	 is not null and @bitSC =1 then FORMAT(SalidaComida ,  'HH:mm:ss') else null end  [Salida Comida]	
	,case when SalidaTrabajo is not null and @bitST=1  then FORMAT(SalidaTrabajo,  'HH:mm:ss') else null end  [Salida Trabajo]	
	,Case when SalidaComida is not null and EntradaComida is not null and (@bitEC =1 and @bitSC =1) THEN convert(varchar, dateadd(second, datediff(second,EntradaComida, SalidaComida), 0), 108) ELSE '' END as [TiempoComida_SH]
	--,Case when EntradaTrabajo is not null and SalidaTrabajo is not null and (@bitET =1 and @bitST =1) THEN convert(varchar, dateadd(second, datediff(second,EntradaTrabajo, SalidaTrabajo), 0), 108) ELSE '' END as [TiempoTrabajado_SH]
	,convert(varchar, dateadd(second, datediff(second,
		(convert(varchar, dateadd(second, datediff(second,EntradaComida, SalidaComida), 0), 108)),
		(convert(varchar, dateadd(second, datediff(second,EntradaTrabajo, SalidaTrabajo), 0), 108))
		), 0), 108) AS [TiempoTrabajado_SH]
	,Ausentismos		
	,Incidencias	
	,Tiempo_Extra AS [TIEMPO EXTRA]
	,Retardo		
	from #resp
	order by ClaveEmpleado, Fecha

	--select  ClaveEmpleado		
	--	   ,NOMBRECOMPLETO		
	--	   ,Departamento		
	--	   ,Sucursal			
	--	   ,Puesto				
	--	   ,Division			
	--	   ,cast(Fecha as varchar) as Fecha			
	--	   ,Dia				
	--	   ,Horario			
	--	   ,cast(cast(Entrada as time) as varchar(8))	as Entrada
	--	   ,cast(cast(Salida as time)  as varchar(8))	as Salida
	--	   ,cast(cast(TiempoTrabajado as time)  as varchar(8))	as TiempoTrabajado 	
	--	   ,Ausentismos		
	--	   ,Incidencias		
	--	   ,cast(cast(Tiempo_Extra as time)  as varchar(8))	as Tiempo_Extra 			
	--	   ,cast(cast(Retardo as time)  as varchar(8))	as Retardo 		
	--	   ,cast(cast(Entrada_SH as time) as varchar(8))	as Entrada_SH
	--	   ,cast(cast(Salida_SH as time)  as varchar(8))	as Salida_SH
	--	   ,cast(cast(TiempoTrabajado_SH as time)  as varchar(8))	as TiempoTrabajado_SH 	 
	--from #resp
	--order by ClaveEmpleado,Fecha
GO

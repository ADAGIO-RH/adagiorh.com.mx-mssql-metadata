USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoListaDeAsistenciaAvilabImpreso](        
	@Clientes varchar(max)	= '', 
	@Divisiones varchar(max)= '',
	@Departamentos varchar(max) = '',   
	@Sucursales varchar(max)= '',  
	@FechaIni date, 
	@FechaFin date,
	@TipoNomina varchar(max)	= ''   ,
	@IDTurno varchar(max)= '', 
	@IDUsuario int      
) as        
	SET FMTONLY OFF     
	declare 
	     @dtempleados [RH].[dtEmpleados]            
		,@IDPeriodoSeleccionado int=0            
		,@periodo [Nomina].[dtPeriodos]            
		,@configs [Nomina].[dtConfiguracionNomina]            
		,@Conceptos [Nomina].[dtConceptos]            
		,@fechaIniPeriodo  date            
		,@fechaFinPeriodo  date         
		,@dtFiltros Nomina.dtFiltrosRH         
    
		,@IDCliente int    
		,@IDTipoNominaInt int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)    
		,@Fecha Datetime
		,@IDTurnoInt int
		
		,@Fechas [App].[dtFechas]
		,@TiempoEntreChecadas int  
		 
		
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null  
	;
	select @TiempoEntreChecadas = Valor from app.tblConfiguracionesGenerales where IDConfiguracion = 'TiempoEntreChecadas'
	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@TipoNomina,',')),0)

	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
	from Seguridad.tblUsuarios u
		Inner join App.tblPreferencias p
			on u.IDPreferencia = p.IDPreferencia
		Inner join App.tblDetallePreferencias dp
			on dp.IDPreferencia = p.IDPreferencia
		Inner join App.tblCatTiposPreferencias tp
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario
			and tp.TipoPreferencia = 'Idioma'

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;



	--SET @Fecha = (Select top 1 cast(item as datetime) from App.Split(@FechaIni,','))    
	SET @IDTurnoInt = (Select top 1 cast(item as int) from App.Split(@IDTurno,','))    
  
	----------------------
	if object_id('tempdb..#tempDiasVigencias') is not null drop table #tempDiasVigencias;    
	create table #tempDiasVigencias (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);
	---------------------------
	
	
	
	 insert into @dtFiltros(Catalogo,Value)      
	 values
		 ('Clientes',@Clientes)  
		,('Sucursales',@Sucursales)      
		,('Departamentos',@Departamentos)      
		,('Divisiones',@Divisiones)      
		,('Divisiones',@Divisiones)   
      
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias; 
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;     
	
	--------------------------------------------

	insert @Fechas  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin 
	
	--------------------------------------------


	/* Se buscan el periodo seleccionado */        
	insert into @dtempleados                  
    exec [RH].[spBuscarEmpleadosMaster] 
		 @FechaIni=@FechaIni, 
		 @Fechafin = @FechaIni, 
		 @IDTipoNomina = @IDTipoNominaInt,
		 @dtFiltros = @dtFiltros, 
		 @EmpleadoIni = @EmpleadoIni, 
		 @EmpleadoFin = @EmpleadoFin,  
		 @IDUsuario = @IDUsuario   

	--------------------------------
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
	-------------------------
		
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
   
   -------------------------------------

   if OBJECT_ID('tempdb..#resp') is not null drop table #resp;

	create table #resp (
		 IDEmpleado			int  
		,ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,IDDepartamento     int
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Division			varchar(500)
		,Empresa            varchar(500)
		,IDTipoNomina	    int
		,Fecha				date
		,Dia				varchar(3)
		,Horario			varchar(50)
		,HEntrada           time
		,HSalida            time 
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
		,IDDepartamento
		,Departamento	
		,Division		
		,Puesto			
		,Sucursal	
		,Empresa
		,IDTipoNomina	
		,Fecha			
		,Dia			
		,Horario
		,HEntrada
		,HSalida
		,Ausentismos	
		,Incidencias	
		,Tiempo_Extra	
		,Retardo		
	)
	select 
		 em.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.IDDepartamento
		,em.Departamento
		,em.Division
		,em.Puesto
		,em.Sucursal
		,em.Empresa
		,em.IDTipoNomina
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,isnull(catHorarios.Codigo,'SIN HORARIO') Horario
		,cathorarios.horaentrada as HEntrada
		,catHorarios.HoraSalida as HSalida
		,ausentismos.Ausentismos
		,incidencias.Incidencias
		,(select 
		 
		DATEADD(ms, SUM(DATEDIFF(ms, '00:00:00.000', TiempoAutorizado)), '00:00:00.000')

			from #tempAusentismosIncidencias 
			where IDIncidencia = 'EX' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
			--and Autorizado = 1
			) Tiempo_Extra
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
		 
	where e.Vigente  = 1 and em.IDTipoNomina = @IDTipoNominaInt
	order by em.ClaveEmpleado, e.Fecha

	update r
		set r.EntradaTrabajo = (case when (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha asc)<>(select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha desc)
		then (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha asc)
		end
		)
    from #resp r

	update r
		set r.SalidaTrabajo = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha order by fecha desc)
    from #resp r

	
	update r
		set r.EntradaComida = (case when  (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaTrabajo) order by fecha asc ) <> r.Salidatrabajo 
									then (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaTrabajo) order by fecha asc )
								end )
    from #resp r

	
	update r
		set r.SalidaComida = (select top 1 Fecha from Asistencia.tblChecadas where IDEmpleado = r.IDEmpleado and FechaOrigen = r.Fecha and fecha >  dateadd(MINUTE,@TiempoEntreChecadas,r.EntradaComida) order by fecha asc)
    from #resp r


	

	--update r 
	--	set r.Tiempo_Extra=(select case when datepart(hour,(Asistencia.fnTimeDiffWithDatetimes(cast (r.EntradaTrabajo as time)  ,  cast (r.HEntrada as time)  ))) >= 1 
	--									then 
	--									--
	--										cast(cast(cast(cast(cast((Asistencia.fnTimeDiffWithDatetimes(cast (r.EntradaTrabajo as time)  ,  cast (r.HEntrada as time)  )) as time)as datetime) as float) + cast(cast(cast( r.Tiempo_Extra as time)as datetime) as float)as datetime) as time)
	--							   else 
	--							  r.Tiempo_Extra
	--							   end
	--						)
	--from #resp r



	select 
	IDEmpleado
	,ClaveEmpleado
	,NOMBRECOMPLETO	
	,IDDepartamento
	,Departamento 
	,Empresa
	,FORMAT(Fecha,'dd/MM/yyyy') as Fecha
	,Fecha as FechaSinFormato	
	,Dia AS Dia	
	,Horario AS Horario	
	,case when EntradaTrabajo is not null then FORMAT(EntradaTrabajo,'HH:mm:ss') else null end as Entrada_Trabajo
	,case when EntradaComida is not null then FORMAT(EntradaComida,  'HH:mm:ss') else null end as Entrada_Comida	
	,case when SalidaComida	 is not null then FORMAT(SalidaComida ,  'HH:mm:ss') else null end as Salida_Comida	
	,case when SalidaTrabajo is not null then FORMAT(SalidaTrabajo,  'HH:mm:ss') else null end as Salida_Trabajo	
	,Ausentismos		
	,Incidencias	
	,Tiempo_Extra as Tiempo_Extra
	,Retardo
	,ROW_NUMBER() OVER(ORDER BY IDEmpleado,Fecha ASC) AS RowNum	
	from #resp
	group by IDEmpleado,ClaveEmpleado,NOMBRECOMPLETO,IDDepartamento,Departamento,Empresa,Fecha,Dia,Horario,EntradaTrabajo,EntradaComida,SalidaComida,SalidaTrabajo,Ausentismos		
	,Incidencias	
	,Tiempo_Extra 
	,Retardo
	order by  Departamento desc,
	ClaveEmpleado desc
  
GO

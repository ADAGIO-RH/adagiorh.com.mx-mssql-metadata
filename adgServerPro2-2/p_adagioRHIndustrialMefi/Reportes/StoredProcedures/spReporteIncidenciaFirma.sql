USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteIncidenciaFirma] (
	@FechaIni date	--= '2020-08-01'
	,@FechaFin date --= '2020-08-15'
	,@ClaveEmpleadoInicial varchar (max) = '0'
	,@ClaveEmpleadoFinal varchar (max) = 'ZZZZZZZZZZZZZZZZZZZZ'
	,@Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= '4'    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@IDUsuario int -- = 1
) as

	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare	
		 @Fechas [App].[dtFechas] 
		,@dtEmpleados RH.dtEmpleados
		--,@EmpleadoIni Varchar(20)  
		--,@EmpleadoFin Varchar(20)  
		
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@dtFiltros Nomina.dtFiltrosRH
		,@fechasUltimaVigencia [App].[dtFechas]              
		,@ListaFechasUltimaVigencia [App].[dtFechasVigenciaEmpleado]
		,@IDTipoNominaInt int
		--,@IDUsuario int = 1
	;

	select 
		@ClaveEmpleadoInicial	= case when @ClaveEmpleadoInicial	= '' then '0' else @ClaveEmpleadoInicial end
		,@ClaveEmpleadoFinal	= case when @ClaveEmpleadoFinal		= '' then 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZ' else @ClaveEmpleadoFinal end

	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@IDTipoNomina,',')),0)

	insert @dtFiltros(Catalogo,Value)    
	values
		('Clientes',@Clientes)    
		,('Divisiones',@Divisiones)    
		,('CentrosCostos',@CentrosCostos)    
		,('Departamentos',@Departamentos)    
		,('Areas',@Areas)    
		,('Sucursales',@Sucursales)    

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

	insert @dtEmpleados
	exec [RH].[spBuscarEmpleados] 
		@FechaIni	= @FechaIni         
		,@FechaFin	= @FechaFin           
		,@IDUsuario		= @IDUsuario              
		,@dtFiltros		= @dtFiltros
		,@EmpleadoIni = @ClaveEmpleadoInicial  
		,@EmpleadoFin = @ClaveEmpleadoFinal
		,@IDTipoNomina = @IDTipoNominaInt

	insert into @fechasUltimaVigencia
	exec [App].[spListaFechas] @FechaIni,@Fechafin
	
	insert @ListaFechasUltimaVigencia
	exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados,@fechasUltimaVigencia,@IDUsuario

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	if object_id('tempdb..#tempDiasTrabajados') is not null drop table #tempDiasTrabajados;    
	if object_id('tempdb..#tempIncidenciasCount') is not null drop table #tempIncidenciasCount;   

	if OBJECT_ID('tempdb..#resp') is not null drop table #resp;

	create table #resp (
		 ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Fecha				varchar(50)
		,Dia				varchar(3)
		,Entrada			datetime
		,Salida				datetime
		,Incidencia			varchar(5)
		,DiasTrabajados		int
		,PrimasDominicales	int
		,DescansosLaborados	int
		,FechaOrden			datetime
		,TiempoTrabajado	AS CONVERT(VARCHAR,Salida - Entrada,8)
	)
	
	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @ListaFechasUltimaVigencia tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and c.FechaOrigen = tempEmp.Fecha and tempEmp.Vigente = 1

	select 
		ie.IDEmpleado
		, ie.IDIncidencia
		, ie.Fecha
		, ROW_NUMBER() OVER(partition by ie.IDEmpleado order by ie.IDEmpleado, ci.EsAusentismo) as [Row]
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @ListaFechasUltimaVigencia tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1
		join Asistencia.tblCatIncidencias ci with (nolock) on ie.IDIncidencia = ci.IDIncidencia --and isnull(ci.EsAusentismo,0) = 1
	order by ci.EsAusentismo

	select IDEmpleado, count(*) as total 
	INTO #tempDiasTrabajados
	from @ListaFechasUltimaVigencia
	where Vigente = 1
	group by IDEmpleado

	select IDEmpleado,IDIncidencia, count(*) as total
	INTO #tempIncidenciasCount
	from #tempAusentismosIncidencias
	where IDIncidencia in ('PD','DL')
	group by IDEmpleado, IDIncidencia

	--select * from #tempIncidenciasCount
	insert #resp (
		 ClaveEmpleado		-- varchar(500)
		,NOMBRECOMPLETO		-- varchar(500)
		,Departamento		-- varchar(500)
		,Sucursal			-- varchar(500)
		,Puesto				-- varchar(500)
		,Fecha				-- varchar(50)
		,Dia				-- varchar(3)
		,Entrada			-- datetime
		,Salida				-- datetime
		,Incidencia			-- varchar(5)
		,DiasTrabajados		-- int
		,PrimasDominicales	-- int
		,DescansosLaborados	-- int
		,FechaOrden
	)
	select
		em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.Departamento
		,em.Sucursal
		,em.Puesto
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3)+'-'+format(e.Fecha,'dd-MM-yyyy') as Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,(select top 1 Fecha
			from #tempChecadas 
			where IDTipoChecada in ('ET', 'SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha asc) Entrada
		,(select top 1  Fecha
			from #tempChecadas 
			where IDTipoChecada in ('ST', 'SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Salida
		--,isnull(incidencia.IDIncidencia,'---') as Incidencia
		,case when e.Vigente = 1 THEN isnull((select top 1 IDIncidencia from  #tempAusentismosIncidencias tai where tai.IDEmpleado = e.IDEmpleado and tai.Fecha = e.Fecha),'---') else 'B' end as Incidencia
		,isnull(diasTrabajados.total,0)	as DiasTrabajados
		,isnull(primasDom.total		,0) as PrimasDominicales
		,isnull(descansosLab.total	,0)	as DescansoTtrabajados
		,e.Fecha
	from @ListaFechasUltimaVigencia e
		join RH.tblEmpleadosMaster em with(nolock) on e.IDEmpleado = em.IDEmpleado
		left join Asistencia.tblHorariosEmpleados he with(nolock) on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios catHorarios with(nolock) on he.IDHorario = catHorarios.IDHorario
		--left join #tempAusentismosIncidencias incidencia with(nolock) on incidencia.IDEmpleado = e.IDEmpleado and incidencia.Fecha = e.Fecha and incidencia.[Row] = 1
		join #tempDiasTrabajados diasTrabajados on e.IDEmpleado = diasTrabajados.IDEmpleado
		left join #tempIncidenciasCount primasDom on e.IDEmpleado = primasDom.IDEmpleado and primasDom.IDIncidencia = 'PD'
		left join #tempIncidenciasCount descansosLab on e.IDEmpleado = descansosLab.IDEmpleado and descansosLab.IDIncidencia = 'DL'
		
--	where e.Vigente  = 1
	order by em.ClaveEmpleado, e.Fecha

	select  ClaveEmpleado		
		,NOMBRECOMPLETO		
		,Departamento		
		,Sucursal			
		,Puesto				
		,Fecha				
		,Dia				
		,isnull(cast(cast(Entrada as time) as varchar(5)),'--:--') as Entrada			
		,isnull(cast(cast(Salida as time) as varchar(5)) ,'--:--')as Salida			
		,Incidencia			
		,DiasTrabajados		
		,PrimasDominicales	
		,DescansosLaborados	
		,isnull(cast(TiempoTrabajado as varchar(5)),'--:--') as TiempoTrabajado
		,'Fechas: '+format(@FechaIni,'dd-MM-yyyy')+' al '+format(@FechaFin,'dd-MM-yyyy') as FechasReportes
		,FechaOrden
	from #resp
GO

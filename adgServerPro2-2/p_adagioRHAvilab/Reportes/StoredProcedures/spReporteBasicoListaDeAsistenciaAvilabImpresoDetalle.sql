USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoListaDeAsistenciaAvilabImpresoDetalle](        
	@Clientes varchar(max)	= '', 
	@Divisiones varchar(max)= '',
	@Departamentos varchar(max) = '',   
	@Sucursales varchar(max)= '',  
	@FechaIni date, 
	@FechaFin date,
	@IDTipoNomina varchar(max)	= ''   ,
	@IDTurno varchar(max)= '', 
	@IDEmpleado int,
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
	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@IDTipoNomina,',')),0)

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

/*	if OBJECT_ID('tempdb..#tempRespuesta') is not null drop table #tempRespuesta;
	create table #tempRespuesta (
		Titulo			varchar(255)
		,ClaveEmpleado	varchar(20)
		,NombreCompleto	varchar(300)
		,Empresa		varchar(255)
		,Division		varchar(255)
		,Sucursal		varchar(255)
		,Departamento	varchar(255)
		,Puesto	varchar(255)
		,Entrada		datetime
		,Salida			datetime
		,CodigoDepartamento varchar(20)
		,TiempoTrabajado as cast(cast(Salida - Entrada as time) as varchar(5))
	)*/

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
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Division			varchar(500)
		,Empresa            varchar(500)
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
		,Empresa	
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
		,em.Division
		,em.Puesto
		,em.Sucursal
		,em.Empresa
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
	 ClaveEmpleado
	,NOMBRECOMPLETO	
	,Departamento 
	,Sucursal 
	,Empresa
	,Puesto		
	,Division	
	,FORMAT(Fecha,'dd/MM/yyyy') as FECHA	
	,Dia 
	,Horario 	
	,case when EntradaTrabajo is not null then FORMAT(EntradaTrabajo,'HH:mm:ss') else null end as Entrada_Trabajo
	,case when EntradaComida is not null then FORMAT(EntradaComida,  'HH:mm:ss') else null end as Entrada_Comida	
	,case when SalidaComida	 is not null then FORMAT(SalidaComida ,  'HH:mm:ss') else null end as Salida_Comida	
	,case when SalidaTrabajo is not null then FORMAT(SalidaTrabajo,  'HH:mm:ss') else null end as Salida_Trabajo	
	,Ausentismos		
	,Incidencias	
	,Tiempo_Extra
	,Retardo		
	from #resp
	where IDEmpleado = @IDEmpleado
	--group by ClaveEmpleado, Departamento, Fecha 
	order by ClaveEmpleado, Fecha
  
/*	insert #tempRespuesta(
		Titulo			
		,ClaveEmpleado	
		,NombreCompleto	
		,Empresa		
		,Division		
		,Sucursal		
		,Departamento
		,Puesto	
		,Entrada		
		,Salida		
		,CodigoDepartamento	
	)
	select     
		'LISTA DE ASISTENCIA DEL DÍA '
			+App.fnAddString(2,CAST(DATEPART(DAY,@FechaIni) AS VARCHAR(2)),'0',1) 
			+' DE '
			+upper(DateName(month,@FechaIni))
			+' DE '
			+CAST(DATEPART(YEAR,@FechaIni) AS VARCHAR(4))
			+' AL DIA '+ App.fnAddString(2,CAST(DATEPART(DAY,@FechaFin) AS VARCHAR(2)),'0',1) 
			+' DE '
			+upper(DateName(month,@FechaFin))
			+' DE '
			+CAST(DATEPART(YEAR,@FechaFin) AS VARCHAR(4))
			as Titulo
		,E.ClaveEmpleado    
		,E.NOMBRECOMPLETO as NombreCompleto    
		,E.Cliente as Empresa    
		,E.Division    
		,E.Sucursal    
		,E.Departamento    
		,E.Puesto    
		, NULL Entrada
		, NULL Salida
		,d.Codigo
		--,(select top 1 Fecha
		--	from Asistencia.tblChecadas 
		--	where IDTipoChecada in ('ET') and FechaOrigen = @Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha asc) Entrada
		--,(select top 1 Fecha
		--	from Asistencia.tblChecadas 
		--	where IDTipoChecada in ('ST') and FechaOrigen = @Fecha and IDEmpleado = e.IDEmpleado
		--	order by Fecha desc) Salida
    from @empleados E    
		join RH.tblCatDepartamentos d
			on E.IDDepartamento = d.IDDepartamento
		left join Asistencia.tblHorariosEmpleados HE    
			on HE.IDEmpleado = E.IDEmpleado    
			and HE.Fecha = @FechaIni  
		left join Asistencia.tblCatHorarios H    
			on H.IDHorario = he.IDHorario    
		and ((H.IDTurno = @IDTurnoInt) or (isnull(@IDTurno,0) = 0))  
	where isnull(E.RequiereChecar,0) = 1

	select 
		Titulo			
		,ClaveEmpleado	
		,NombreCompleto	
		,Empresa		
		,Division		
		,Sucursal		
		,Departamento
		,Puesto	
		,cast(cast(Entrada as time)	as varchar(5)) as Entrada	
		,cast(cast(Salida  as time)	as varchar(5)) as Salida
		,TiempoTrabajado
		,CodigoDepartamento
	from #tempRespuesta
	order by CodigoDepartamento, ClaveEmpleado

*/
GO

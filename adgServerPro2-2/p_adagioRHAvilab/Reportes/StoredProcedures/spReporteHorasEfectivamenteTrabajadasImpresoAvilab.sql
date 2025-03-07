USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteHorasEfectivamenteTrabajadasImpresoAvilab](        
	@Clientes varchar(max)	= '', 
	@Divisiones varchar(max)= '',
	@Departamentos varchar(max) = '',   
	@Sucursales varchar(max)= '',  
	@FechaIni date, 
	@FechaFin date,
	@IDTipoNomina varchar(max)	= ''   ,
	@IDTurno varchar(max)= '', 
	@RegPatronales varchar(max)= '', 
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
		
		,@Fechas2 [App].[dtFechas]  
		,@Fechas [App].[dtFechasFull]  
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
		,('RegPatronales',@RegPatronales)    
      
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias; 
	if object_id('tempdb..#tempAusentismosFinal') is not null drop table #tempAusentismosFinal;    
	if object_id('tempdb..#tempIncidenciasFinal') is not null drop table #tempIncidenciasFinal;     
	
	--------------------------------------------

	insert @Fechas2  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin 
	
	    insert into @Fechas 
    select * from @Fechas2
	--------------------------------------------


	/* Se buscan el periodo seleccionado */        
	insert into @dtempleados                  
    exec [RH].[spBuscarEmpleados] 
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
		,@Fechas = @Fechas2
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
	--select * from #tempAusentismosFinal

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
	     IDEmpleado          int
		,ClaveEmpleado		varchar(500)
		,NOMBRECOMPLETO		varchar(500)
		,IDDepartamento     int
		,Departamento		varchar(500)
		,Sucursal			varchar(500)
		,Puesto				varchar(500)
		,Division			varchar(500)
		,Requiere_Checar	bit
		,FechaAsDate				date
		,Fecha				date
		,Dia				varchar(3)
		,Semana				int
		,CatHorario         varchar(50)		
		,Horario			varchar(50)
		,Entrada			datetime
		,Salida				datetime
		,TiempoTrabajado	 AS CONVERT(VARCHAR,Salida - Entrada,8)
		,TiempoTrabajadoDecimal decimal(18,2)
		,Ausentismos		varchar(max)
		,Incidencias		varchar(max)
		,Tiempo_Extra		decimal(18,2)
		,Tiempo_Extra_Triple		decimal(18,2)
		,Retardo			time
		,Entrada_SH			datetime
		,Salida_SH			datetime
		,TiempoTrabajado_SH AS CONVERT(VARCHAR,Salida_SH - Entrada_SH,8)
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
		,Requiere_Checar
		,FechaAsDate			
		,Fecha			
		,Dia
		,Semana
		,CatHorario
		,Horario		
		,Entrada		
		,Salida			
		,Entrada_SH		
		,Salida_SH		
		,Ausentismos	
		,Incidencias	
		--,Tiempo_Extra
		--,Tiempo_Extra_Triple
		,Retardo		
	)
	select 
		--em.IDEmpleado
		--,
		em.IDEmpleado
		,em.ClaveEmpleado
		,em.NOMBRECOMPLETO
		,em.IDDepartamento
		,em.Departamento
		,em.Division
		,em.Puesto
		,em.Sucursal
		,em.RequiereChecar
		,e.Fecha as FechaAsDate
		,e.Fecha
		,substring(upper(DATENAME(weekday,e.Fecha)),1,3) as Dia
		,F.Semana
		,catHorarios.Codigo as CatHorario
		,isnull(catHorarios.Codigo,'SIN HORARIO') Horario
		,(select MIN(Fecha)
			from #tempChecadas 
			where IDTipoChecada in ('ET') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			) Entrada
		,(select MAX( Fecha)
			from #tempChecadas 
			where IDTipoChecada in ('ST') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			) Salida
		,(select MIN( Fecha)
			from #tempChecadas 
			where IDTipoChecada in ('SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			) Entrada_SH
		,(select MAX(Fecha)
			from #tempChecadas 
			where IDTipoChecada in ('SH') and FechaOrigen = e.Fecha and IDEmpleado = e.IDEmpleado
			) Salida_SH
		,ausentismos.Ausentismos
		,incidencias.Incidencias
		--,(select SUM( TiempoExtraDecimal )
		--	from #tempAusentismosIncidencias 
		--	where IDIncidencia = 'EX' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
		--	--and Autorizado = 1
		--	) Tiempo_Extra
		,(select top 1 TiempoAutorizado 
			from #tempAusentismosIncidencias 
			where IDIncidencia = 'R' and Fecha = e.Fecha and IDEmpleado = e.IDEmpleado
			order by Fecha desc) Retardo
	from #tempDiasVigencias e
		join @dtempleados em on e.IDEmpleado = em.IDEmpleado
		left join Asistencia.tblHorariosEmpleados he with(nolock) on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios catHorarios with(nolock) on he.IDHorario = catHorarios.IDHorario
		left join #tempAusentismosFinal ausentismos with(nolock) on ausentismos.IDEmpleado = e.IDEmpleado and ausentismos.Fecha = e.Fecha
		left join #tempIncidenciasFinal incidencias with(nolock) on incidencias.IDEmpleado = e.IDEmpleado and incidencias.Fecha = e.Fecha
		join @Fechas f on e.Fecha = f.Fecha
		 
	where e.Vigente  = 1 
	and (em.IDTipoNomina = @IDTipoNomina or isnull(@IDTipoNomina,0) = 0)

	order by em.ClaveEmpleado, e.Fecha


	update #resp
		set TiempoTrabajadoDecimal = CASE WHEN TiempoTrabajado is not null THEN ((datepart(hour,TiempoTrabajado)+datepart(minute,TiempoTrabajado)/(60.00))+datepart(second,TiempoTrabajado)/(3600.00)) ELSE 0 END

	
	  IF object_ID('TEMPDB..#TempExtrasDetalle') IS NOT NULL  
		DROP TABLE #TempExtrasDetalle  
	 IF object_ID('TEMPDB..#TempRespFinal') IS NOT NULL  
		DROP TABLE #TempRespFinal  

	DECLARE @dtTiemposExtras Asistencia.dtDetalleTiemposExtras
	, @dtTiemposExtrasTriples Asistencia.dtDetalleTiemposExtras
	/*AQUI INICIA MODIFICACIÓN EXCLUSIVA PARA AVILAB EN LA QUE LAS CONDICIONES DE HORAS EXTRAS SON: 
	- las primeras 3 horas los primeros tres días son triples y de la 4ta hora en adelante se paga 
	  triple o el 4to día, sea la cantidad de horas que sean se pagan triples
	- los domingos siempre se pagan triples
	*/
	
		select ie.IDEmpleado,ie.IDIncidencia,SUM(ie.TiempoExtraDecimal) HorasExtras, IE.Fecha, DATEPART(WEEKDAY,IE.Fecha) Dia,DATEPART(WEEK,IE.Fecha) Semana, ROW_NUMBER()OVER(Partition by DATEPART(WEEK,IE.Fecha), IE.IDEmpleado order by IE.Fecha ) RN , CAST(0 as decimal(18,4)) as Dobles, CAST(0 as decimal(18,4)) as Triples --0 as Dobles, 0 as Triples
			into #TempExtrasDetalle
		from Asistencia.tblIncidenciaEmpleado ie
			join @dtempleados Empleados on ie.IDEmpleado = Empleados.IDEmpleado
			inner join #tempDiasVigencias fechas on fechas.IDEmpleado = Empleados.IDEmpleado
				and ie.Fecha = fechas.Fecha and Fechas.Vigente = 1
		where ie.IDIncidencia in ('EX')  and ie.Fecha between @FechaIni and @FechaFin  
		  --AND IE.Autorizado = 1
		GROUP BY ie.IDEmpleado, IE.Fecha, ie.IDIncidencia

		
	
		update #TempExtrasDetalle
			set Dobles = CASE WHEN IDIncidencia = 'EX' THEN 
								CASE WHEN Dia not in (1) and RN <= 3 THEN 
									CASE WHEN HorasExtras <= 3.0 THEN HorasExtras
										 WHEN HorasExtras > 3.0 THEN 3.0
										 ELSE 0.0
										 END
										 WHEN Dia in (1) OR RN >= 4 THEN 0.0
										ELSE 0.0
									 END
						 ELSE 0.00
						 END,

			  Triples = CASE WHEN IDIncidencia = 'EX' THEN 
								CASE WHEN Dia not in (1) and RN <= 3 THEN 
									CASE WHEN HorasExtras <= 3.0 THEN 0.0
										 WHEN HorasExtras > 3.0 THEN HorasExtras - 3.0
										 ELSE 0.0 
										 END
							 WHEN RN >= 4 THEN HorasExtras
							 WHEN Dia in (1) THEN HorasExtras
							ELSE 0.0
						 END
						  ELSE HorasExtras
						 END
		
		--select * from #TempExtrasDetalle order by idempleado,semana, dia,rn
		
	
		--select IDEmpleado, sum(TiempoTrabajadoDecimal) from #resp group by IDEmpleado order by IDEmpleado


		SELECT  
			r.IDEmpleado as IDEMPLEADO
			,ClaveEmpleado as [CLAVE EMPLEADO]		
			,NOMBRECOMPLETO as NOMBRE	
			,IDDepartamento as IDDEPARTAMENTO
			,Departamento as DEPARTAMENTO
			
			,isnull((SELECT Top 1 ch.Codigo FROM Asistencia.tblHorariosEmpleados he inner join Asistencia.tblCatHorarios ch on he.IDHorario = ch.IDHorario and he.IDEmpleado = r.IDEmpleado and he.Fecha between @FechaIni and @FechaFin order by Fecha asc),'SIN HORARIO') as HORARIO		
			--,r.Semana
			--,r.Fecha
			,
			 SUM(TiempoTrabajadoDecimal)
			 AS TIEMPOTRABAJADO	
			,(SELECT SUM(cast(Dobles as decimal(18,2))) FROM #TempExtrasDetalle WHERE IDEmpleado = r.IDEmpleado) as TIEMPOEXTRA
			,(SELECT SUM(cast(Triples as decimal(18,2))) FROM #TempExtrasDetalle WHERE IDEmpleado = r.IDEmpleado) as TIEMPOEXTRATRIPLE
			,(SELECT SUM(cast(HorasExtras as decimal(18,2))) FROM #TempExtrasDetalle WHERE IDEmpleado = r.IDEmpleado) as TOTALTIEMPOEXTRA
			
		into #TempRespFinal
	from #resp r 
	
			
	group by r.IDEmpleado,r.ClaveEmpleado,NOMBRECOMPLETO,IDDepartamento,Departamento
	order by Departamento,ClaveEmpleado
	
	select * from #TempRespFinal order by Departamento,[CLAVE EMPLEADO]
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE proc [Reportes].[spReporteBasicoHorariosDescansosRangoDeFecha] (    
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly    
	,@IDUsuario int    
) as    
    
	SET NOCOUNT ON;    
	IF 1=0 BEGIN    
		SET FMTONLY OFF    
	END    
  
	declare     
		@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null      
		,@Fechas [App].[dtFechasFull]       
		,@dtEmpleados RH.dtEmpleados    
		,@IDCliente int    
		,@IDTipoNomina int    
		,@FechaIni Date    
		,@FechaFin Date    
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20)  
		,@IDTurno int    
	;    
    
	SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)    
	SET @FechaIni = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
	SET @FechaFin = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)   
	SET @IDTurno = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),','))    
   
	SET @EmpleadoIni = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
  
	if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;        
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;        
    
	SET DATEFIRST 7;      
      
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')  
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas with (nolock)      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL;     
    
	insert @Fechas      
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin      
    
	insert @dtEmpleados      
	exec [RH].[spBuscarEmpleados]       
		@FechaIni = @FechaIni               
		,@FechaFin = @FechaFin        
		,@IDTipoNomina = @IDTipoNomina             
		,@IDUsuario = @IDUsuario                    
		,@dtFiltros = @dtFiltros     
		,@EmpleadoIni = @EmpleadoIni  
		,@EmpleadoFin = @EmpleadoFin  
    
	select he.IDEmpleado,he.Fecha,h.*    
	INTO #tempHorarios    
	from Asistencia.tblHorariosEmpleados he with (nolock)    
		join @Fechas fecha on he.Fecha = fecha.Fecha     
		join @dtEmpleados tempEmp on he.IDEmpleado = tempEmp.IDEmpleado    
		join Asistencia.tblCatHorarios h with (nolock)  
	on he.IDHorario = h.IDHorario   
  
	select ie.*    
	into #tempAusentismosIncidencias    
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)    
		join @Fechas fecha on ie.Fecha = fecha.Fecha     
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado     
	where IE.IDIncidencia in (select IDIncidencia from Asistencia.tblCatIncidencias where EsAusentismo = 1)    
  
 --select * from @Fechas    
	select    
		empFecha.ClaveEmpleado as [CLAVE EMPLEADO]    
		,empFecha.NOMBRECOMPLETO as NOMBRE    
		,empFecha.Puesto as PUESTO
 
		--,empFecha.Fecha    
		,FECHA = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)    
			+' - '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))    
			+' '+ UPPER(empFecha.NombreDia)    
		,H.Descripcion as HORARIO  
		,cast(case     
			when i.IDIncidencia is null then  
			CASE WHEN EXISTS((select top 1 cast(cast(HoraEntrada as time) as varchar(8))    
								from #tempHorarios   
								where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
								order by Fecha asc)) THEN (select top 1 cast(cast(HoraEntrada as time) as varchar(5))    
															from #tempHorarios   
															where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
															order by Fecha asc)
			ELSE 'SIN HORARIO'
			END
		else i.IDIncidencia end as varchar(max)) [HORA ENTRADA] 
         
		,CAST(case     
		when i.IDIncidencia is null then  
   
			CASE WHEN EXISTS((select top 1 cast(cast( HoraSalida as time) as varchar(8))    
								from #tempHorarios     
								where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
								order by Fecha desc)) THEN (select top 1 cast(cast( HoraSalida as time) as varchar(5))    
															from #tempHorarios     
															where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
		 													order by Fecha desc)
				ELSE 'SIN HORARIO'
				END
		
		else i.IDIncidencia end As varchar(max)) [HORA SALIDA]    
		--,i.IDIncidencia    
		,i.Comentario as COMENTARIO  
		--,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')    
		--,Titulo = 'LISTA DE ASISTENCIA DEL '    
		--   + App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)    
		--   +'/'+UPPER(DATENAME(month,@FechaIni))    
		--   +'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)    
		--   +' AL '    
		--   + App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)    
		--   +'/'+UPPER(DATENAME(month,@FechaFin))    
		--   +'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL     
		from (select *    
			from @Fechas    
			,@dtEmpleados) as empFecha    
			left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha    
			left join #tempHorarios H on H.IDEmpleado = empFecha.IDEmpleado and H.Fecha = empFecha.Fecha    
		order by empFecha.IDEmpleado,empFecha.Fecha
GO

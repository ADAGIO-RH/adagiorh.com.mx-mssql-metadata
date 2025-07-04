USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoHorariosDecansosRangoDeFechaImpreso] (    
	@FechaIni date     
	,@FechaFin date    
	,@Cliente varchar(max)   = ''        
	,@TipoNomina varchar(max)  = ''        
	,@Divisiones varchar(max)   = ''    
	,@CentrosCostos varchar(max) = ''    
	,@Departamentos varchar(max) = ''    
	,@Areas varchar(max)    = ''    
	,@Sucursales varchar(max)  = ''    
	,@Prestaciones varchar(max)  = ''    
	,@IDUsuario int    
) as    
    
	SET NOCOUNT ON;    
	IF 1=0 
	BEGIN    
		SET FMTONLY OFF    
	END    
    
	declare     
		@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null      
		,@Fechas [App].[dtFechasFull]       
		,@dtEmpleados RH.dtEmpleados    
		,@dtFiltros [Nomina].[dtFiltrosRH]      
		,@IDTipoNominaInt int
		,@Titulo Varchar(max)     
	;    

	SET DATEFIRST 7;     
      
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')  
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL; 
    
	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@TipoNomina,',')),0)    
    
	insert @dtFiltros(Catalogo,Value)        
	values    
		('Clientes',@Cliente)        
		,('Divisiones',@Divisiones)        
		,('CentrosCostos',@CentrosCostos)        
		,('Departamentos',@Departamentos)        
		,('Areas',@Areas)        
		,('Sucursales',@Sucursales)        
		,('Prestaciones',@Prestaciones)        
    
	if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;        
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;           	    
    
	insert @Fechas      
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin      
    
	SET @Titulo =  UPPER( 'LISTA DE HORARIOS Y DESCANSOS DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))
 
	insert @dtEmpleados      
	exec [RH].[spBuscarEmpleados]       
	  @FechaIni = @FechaIni               
	  ,@FechaFin = @FechaFin        
	  ,@IDTipoNomina = @IDTipoNominaInt             
	  ,@IDUsuario = @IDUsuario                    
	  ,@dtFiltros = @dtFiltros     
    
	select he.IDEmpleado,he.Fecha,h.*    
	INTO #tempHorarios    
	from Asistencia.tblHorariosEmpleados he with (nolock)    
		join @Fechas fecha on he.Fecha = fecha.Fecha     
		join @dtEmpleados tempEmp on he.IDEmpleado = tempEmp.IDEmpleado    
		join Asistencia.tblCatHorarios h on he.IDHorario = h.IDHorario    

	select ie.*    
	into #tempAusentismosIncidencias    
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)    
		join @Fechas fecha on ie.Fecha = fecha.Fecha     
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado     
	where IE.IDIncidencia in (select IDIncidencia from Asistencia.tblCatIncidencias where EsAusentismo = 1)    
    
	select    
		empFecha.ClaveEmpleado    
		,empFecha.NOMBRECOMPLETO as Nombre    
		,empFecha.Puesto   
		,empFecha.RazonSocial  
		,empFecha.RegPatronal  
		,empFecha.Departamento 
		,empFecha.Fecha    
		,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)    
			+'/'+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))    
			+' '+ UPPER(SUBSTRING(empFecha.NombreDia,1,3))    
		,cast(case     
		when i.IDIncidencia is null then  
			CASE WHEN EXISTS((select top 1 cast(cast(HoraEntrada as time) as varchar(8))    
								from #tempHorarios   
								where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
								order by Fecha asc)) THEN (select top 1 cast(cast(HoraEntrada as time) as varchar(5))    
															from #tempHorarios   
															where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
															order by Fecha asc)
			ELSE 'SH'
			END
		else i.IDIncidencia end as varchar(max)) HoraEntrada 
         
		,CAST(case     
		when i.IDIncidencia is null then  
   
			CASE WHEN EXISTS((select top 1 cast(cast( HoraSalida as time) as varchar(8))    
								from #tempHorarios     
								where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
								order by Fecha desc)) THEN (select top 1 cast(cast( HoraSalida as time) as varchar(5))    
															from #tempHorarios     
															where Fecha = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado    
		 													order by Fecha desc)
				ELSE 'SH'
				END
		
		else i.IDIncidencia end As varchar(max)) HoraSalida     
		,i.Comentario    
		,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')    
		,@Titulo as Titulo
	from (
		select *    
		from @Fechas    
			,@dtEmpleados) as empFecha    
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha    
		left join #tempHorarios H on H.IDEmpleado = empFecha.IDEmpleado and H.Fecha = empFecha.Fecha    
	order by empFecha.ClaveEmpleado,empFecha.Fecha
GO

USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoVacacionesMoti] (
	@dtFiltros Nomina.dtFiltrosRH readonly            
	,@IDUsuario int = 1
) as
	declare 
		 @empleados [RH].[dtEmpleados]   
		,@FechaIni date 
		,@FechaFin date 
		,@ClaveEmpleadoInicial varchar(20) = '0'
		,@ClaveEmpleadoFinal varchar(20) ='zzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
		,@TipoVigente int = 1
	;

	SET @ClaveEmpleadoInicial = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')  
	SET @ClaveEmpleadoFinal   = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')  
	SET @FechaIni             = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
	SET @FechaFin             = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  
	SET @TipoVigente	      = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'),',')),1)
	

	if (@TipoVigente = 1)
	begin
		insert into @empleados                
		exec [RH].[spBuscarEmpleadosMaster] --@FechaIni=@FechaIni, @Fechafin = @FechaIni, 
		@dtFiltros = @dtFiltros
	   ,@EmpleadoIni = @ClaveEmpleadoInicial
	   ,@EmpleadoFin = @ClaveEmpleadoFinal
	   ,@IDUsuario = @IDUsuario    
	end else 	
	if (@TipoVigente in (2,3))
	begin
		insert into @empleados                
		exec [RH].[spBuscarEmpleadosMaster] 
		@dtFiltros = @dtFiltros
	   ,@EmpleadoIni = @ClaveEmpleadoInicial
	   ,@EmpleadoFin = @ClaveEmpleadoFinal
	   ,@IDUsuario = @IDUsuario 

	end;

	if  (@TipoVigente = 1)
	begin
		delete from @empleados where isnull(Vigente,0) = 0
	end
	if (@TipoVigente = 2)
	begin
		delete from @empleados where isnull(Vigente,0) = 1
	end

	if object_id('tempdb..#Vacaciones') is not null
	DROP TABLE #Vacaciones;

	select 
			vacaciones.IDEmpleado as IDEmpleado
		   ,Empleados.ClaveEmpleado as ClaveEmpleado
		   ,Empleados.NOMBRECOMPLETO as Nombre
		   ,min(vacaciones.Fecha) as FechaIni
		   ,MAX(vacaciones.Fecha) as FechaFin
		into #Vacaciones
	from Asistencia.tblIncidenciaEmpleado vacaciones
		inner join @empleados Empleados
			on Empleados.IDEmpleado = vacaciones.IDEmpleado
	where vacaciones.Fecha between @FechaIni and @FechaFin
			and vacaciones.IDIncidencia = 'V' and  vacaciones.Autorizado = 1
	group by vacaciones.IDEmpleado, Empleados.ClaveEmpleado, Empleados.NOMBRECOMPLETO




	if object_id('tempdb..#VacacionesDuracion') is not null
	DROP TABLE #VacacionesDuracion;


	select 
			IDEmpleado as IDEmpleado,
			count(idempleado) as Duración
		into #VacacionesDuracion
	from Asistencia.tblIncidenciaEmpleado
	where Fecha between @FechaIni and @FechaFin
			and IDIncidencia = 'V' and Autorizado = 1
	group by IDEmpleado




	select 
			vacaciones.ClaveEmpleado as [Clave]
		   ,Vacaciones.Nombre as [Nombre]
		   ,duracion.Duración as [Dias]
		   ,Vacaciones.FechaIni as [Fecha Inicial]
		   ,Vacaciones.FechaFin as [Fecha Final]

	from #Vacaciones Vacaciones
		left join #VacacionesDuracion duracion
			on duracion.IDEmpleado = Vacaciones.IDEmpleado

GO

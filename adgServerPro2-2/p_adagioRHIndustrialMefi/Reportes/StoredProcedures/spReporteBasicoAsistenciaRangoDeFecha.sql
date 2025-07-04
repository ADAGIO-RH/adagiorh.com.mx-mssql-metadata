USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
declare @dtFiltros [Nomina].[dtFiltrosRH]
	
insert @dtFiltros(Catalogo,Value)    
	values
		('Clientes','1')   
		,('FechaIni','2019-08-01')   
		,('FechaFin','2019-08-15')   

 exec Reportes.spReporteBasicoAsistenciaRangoDeFecha 
		@dtFiltros= @dtFiltros
		,@IDUsuario = 1 

*/
		  
CREATE proc [Reportes].[spReporteBasicoAsistenciaRangoDeFecha] (
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
		,@IDTurno int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)

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

	SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @IDTurno = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),','))
	SET @EmpleadoIni = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
  
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    

	
	insert @Fechas  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@IDTipoNomina	= @IDTipoNomina         
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros 

	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 
	
	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 

	--select * from @Fechas
	select
		 empFecha.ClaveEmpleado as [CLAVE EMPLEADO]
		,empFecha.NOMBRECOMPLETO as NOMBRE
		,empFecha.Puesto as PUESTO
		--,empFecha.Fecha
		,FECHA = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)
					+' - '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))
					+' '+ UPPER(empFecha.NombreDia)
		,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),'NC')
			else i.IDIncidencia end ENTRADA
		,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha desc),'NC') 
			else i.IDIncidencia end SALIDA
		--,i.IDIncidencia
		,i.Comentario as COMENTARIO
		--,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')
		--,Titulo = 'LISTA DE ASISTENCIA DEL '
		--			+ App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)
		--			+'/'+UPPER(DATENAME(month,@FechaIni))
		--			+'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)
		--			+' AL '
		--			+ App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)
		--			+'/'+UPPER(DATENAME(month,@FechaFin))
		--			+'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL 
	from (select *
			from @Fechas
				,@dtEmpleados) as empFecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
	order by empFecha.IDEmpleado,empFecha.Fecha
GO

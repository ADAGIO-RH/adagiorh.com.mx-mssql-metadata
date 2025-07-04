USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 Reportes.spReporteBasicoAsistenciaRangoDeFechaImpreso 
		@FechaIni	= '2019-08-01'
		,@FechaFin	= '2019-08-15'
		,@Clientes	= '1' 
		,@IDUsuario = 1 

*/
		  
CREATE proc [Reportes].[spReporteBasicoAsistenciaRangoDeFechaNominaRevisionImpreso] (
	@FechaIni date 
	,@FechaFin date
	,@Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= ''    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@RazonesSociales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechas]   
		,@FechasFull [App].[dtFechasFull]   
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
	;

	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@IDTipoNomina,',')),0)

	--select @IDTipoNominaInt

	insert @dtFiltros(Catalogo,Value)    
	values
		--('Clientes',isnull(@Clientes,''))    
		('Divisiones',isnull(@Divisiones,''))    
		,('CentrosCostos',isnull(@CentrosCostos,''))    
		,('Departamentos',isnull(@Departamentos,''))    
		,('Areas',isnull(@Areas,''))    
		,('Sucursales',isnull(@Sucursales,''))    
		,('Prestaciones',isnull(@Prestaciones,''))    
		,('RazonesSociales',isnull(@RazonesSociales,''))

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    

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

	insert @Fechas  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  


	insert @FechasFull
	select Fecha
	from @Fechas

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		@FechaIni = @FechaIni           
		,@FechaFin = @FechaFin    
		,@IDTipoNomina = @IDTipoNomina         
		,@IDUsuario = @IDUsuario                
		,@dtFiltros = @dtFiltros 

	IF OBJECT_ID('tempdb..#tempVigenciaEmpleados') is not null DROP TABLE #tempVigenciaEmpleados

	create Table #tempVigenciaEmpleados(    
		IDEmpleado int null,    
		Fecha Date null,    
		Vigente bit null    
	);    
    
	insert into #tempVigenciaEmpleados    
	Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  
		@dtEmpleados = @dtEmpleados    
		,@Fechas = @Fechas    
		,@IDUsuario = @IDUsuario    

	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 
	WHERE C.IDTipoChecada not in ('EC','SC')

	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 
	WHERE IDIncidencia in ( 'C','D','F','I','P','S','V')

	select
		 empFecha.ClaveEmpleado
		,empFecha.NOMBRECOMPLETO as Nombre
		,empFecha.Puesto
		,empFecha.Departamento
		,empFecha.Sucursal
		,empFecha.Empresa as RazonSocial
		,empFecha.Fecha
		,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)
					--+' '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))
					+' '+ UPPER(SUBSTRING(empFecha.NombreDia,1,3))
		,Valor = CASE WHEN EV.Vigente = 0 THEN 'B'
					  ELSE
							CASE WHEN I.IDIncidencia is not null and exists (select top 1 1 from #tempChecadas where IDEmpleado = empFecha.IDEmpleado and FechaOrigen = empFecha.Fecha) THEN 'XX'
								 WHEN I.IDIncidencia is not null and not exists (select top 1 1 from #tempChecadas where IDEmpleado = empFecha.IDEmpleado and FechaOrigen = empFecha.Fecha) THEN I.IDIncidencia
								 WHEN I.IDIncidencia is null and  (select count(*) from #tempChecadas where IDEmpleado = empFecha.IDEmpleado and FechaOrigen = empFecha.Fecha) >= 2 THEN '-'
								 WHEN I.IDIncidencia is null and  (select count(*) from #tempChecadas where IDEmpleado = empFecha.IDEmpleado and FechaOrigen = empFecha.Fecha) = 1 THEN 'NC'
								 ELSE ''
							END
					  END

		,Titulo = 'LISTA DE ASISTENCIA DEL '
					+ App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)
					+'/'+UPPER(DATENAME(month,@FechaIni))
					+'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)
					+' AL '
					+ App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)
					+'/'+UPPER(DATENAME(month,@FechaFin))
					+'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL 
	from (select *
			from @FechasFull
				,@dtEmpleados) as empFecha
		left join #tempVigenciaEmpleados EV on EV.IDEmpleado = empFecha.IDEmpleado and ev.Fecha = empFecha.Fecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
	order by empFecha.IDEmpleado,empFecha.Fecha
GO

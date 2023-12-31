USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteCorreosEmpleados] (    
-- -- @FechaIni date     
-- --,@FechaFin date    
-- --,@Clientes varchar(max)   = ''        
-- --,@IDTipoNomina varchar(max)  = ''        
-- --,@Divisiones varchar(max)   = ''    
-- --,@CentrosCostos varchar(max) = ''    
-- --,@Departamentos varchar(max) = ''    
-- --,@Areas varchar(max)    = ''    
-- --,@Sucursales varchar(max)  = ''    
-- --,@Prestaciones varchar(max)  = ''    
  
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly    
	,@IDUsuario int    
) as    
    
	SET NOCOUNT ON;    
	IF 1=0 BEGIN    
		SET FMTONLY OFF    
	END    
    
	--declare     
	-- @FechaIni date =  '2019-01-01'    
	-- ,@FechaFin date = '2019-01-02'    
	-- ,@IDUsuario int = 1    
	--;    
  
	declare     
		@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null      
		,@Fechas [App].[dtFechas]       
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
      
	select top 1 @IDIdioma = dp.Valor      
	from Seguridad.tblUsuarios u with (nolock)      
		Inner join App.tblPreferencias p with (nolock)      
			on u.IDPreferencia = p.IDPreferencia      
		Inner join App.tblDetallePreferencias dp with (nolock)      
			on dp.IDPreferencia = p.IDPreferencia      
		Inner join App.tblCatTiposPreferencias tp with (nolock)      
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia      
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'      
      
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
    
	--select *    
	--from @Fechas    
    
	insert @dtEmpleados      
	exec [RH].[spBuscarEmpleados]       
		@FechaIni = @FechaIni               
		,@FechaFin = @FechaFin        
		,@IDTipoNomina = @IDTipoNomina             
		,@IDUsuario = @IDUsuario                    
		,@dtFiltros = @dtFiltros     
		,@EmpleadoIni = @EmpleadoIni  
		,@EmpleadoFin = @EmpleadoFin  
    
	-- select he.IDEmpleado,he.Fecha,h.*    
	-- INTO #tempHorarios    
	-- from Asistencia.tblHorariosEmpleados he with (nolock)    
	-- 	join @Fechas fecha on he.Fecha = fecha.Fecha     
	-- 	join @dtEmpleados tempEmp on he.IDEmpleado = tempEmp.IDEmpleado    
	-- 	join Asistencia.tblCatHorarios h with (nolock)  
	-- on he.IDHorario = h.IDHorario   
  
	-- select ie.*    
	-- into #tempAusentismosIncidencias    
	-- from Asistencia.tblIncidenciaEmpleado ie with (nolock)    
	-- 	join @Fechas fecha on ie.Fecha = fecha.Fecha     
	-- 	join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado     
	-- where IE.IDIncidencia in (select IDIncidencia from Asistencia.tblCatIncidencias where EsAusentismo = 1)    
  
 --select * from @Fechas    
	select
		empFecha.ClaveEmpleado as [NUMERO DE COLABORADOR]    
		,empFecha.NOMBRECOMPLETO as [NOMBRE DEL COLABORADOR]     
		,empFecha.Puesto as PUESTO
		,empFecha.Departamento as DEPARTAMENTO
		,empFecha.ClasificacionCorporativa as [CLASIFICACION CORPORATIVA]
         
		--,i.IDIncidencia    
		--,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')    
		--,Titulo = 'LISTA DE ASISTENCIA DEL '    
		--   + App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)    
		--   +'/'+UPPER(DATENAME(month,@FechaIni))    
		--   +'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)    
		--   +' AL '    
		--   + App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)    
		--   +'/'+UPPER(DATENAME(month,@FechaFin))    
		--   +'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL     
		--,conEMp.Value AS [NUMERO DE CONTACTO]
		,ISNULL(STUFF((SELECT ' , '+conEMp.Value
		FROM RH.tblContactoEmpleado conEMp
		WHERE conEMp.IDEmpleado=empFecha.IDEmpleado and conEMp.IDTipoContactoEmpleado=1
		FOR XML PATH(''), TYPE).value('text()[1]','nvarchar(max)'), 1, LEN(' , '), ''),'SIN CORREO')AS [CORREO]
		from @dtEmpleados as empFecha
            LEFT JOIN RH.tblContactoEmpleado CONTACTO ON CONTACTO.IDEmpleado=empFecha.IDEmpleado AND CONTACTO.IDTipoContactoEmpleado=1
		order by empFecha.IDEmpleado
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	  
CREATE proc [Reportes].[spReporteBasicoIncidenciasDeNominaImpreso] (
	@FechaIni	date 
	,@FechaFin	date
	,@ClaveEmpleadoInicial	varchar (max) = '0'
	,@ClaveEmpleadoFinal	varchar (max) = 'ZZZZZZZZZZZZZZZZZZZZ'
	,@Clientes		varchar(max) = ''    
	,@IDTipoNomina	varchar(max) = ''    
	,@Divisiones	varchar(max) = ''
	,@CentrosCostos varchar(max) = ''
	,@Departamentos varchar(max) = ''
	,@Areas			varchar(max) = ''
	,@Sucursales	varchar(max) = ''
	,@Prestaciones	varchar(max) = ''
	,@SoloIncidencias	bit = 0
	,@TipoVigente		int = 1
	,@IDUsuario			int
) as

	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		,@Titulo Varchar(max)     
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
		,('Prestaciones',@Prestaciones)    

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
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
	    
	SET @Titulo =  UPPER( 'REPORTE DE INCIDENCAS DE NÓMINA ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.','')) 
		+ case when @SoloIncidencias = 1 then ' - (SOLO INCIDENCIAS)' else '' end

	if (@TipoVigente = 1)
	begin
		insert @dtEmpleados  
		exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @ClaveEmpleadoInicial
		,@EmpleadoFin	= @ClaveEmpleadoFinal
		,@IDTipoNomina	= @IDTipoNomina         
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros 
	end else 	
	if (@TipoVigente in (2,3))
	begin
		insert @dtEmpleados  
		exec [RH].[spBuscarEmpleadosMaster]   
			 @FechaIni		= @FechaIni           
			,@FechaFin		= @FechaFin    
			,@EmpleadoIni	= @ClaveEmpleadoInicial
			,@EmpleadoFin	= @ClaveEmpleadoFinal
			,@IDTipoNomina	= @IDTipoNomina         
			,@IDUsuario		= @IDUsuario                
			,@dtFiltros		= @dtFiltros 
	end;

	if (@TipoVigente = 2)
	begin
		delete from @dtEmpleados where isnull(Vigente,0) = 1
	end 

	select 
		e.ClaveEmpleado as Clave
		,e.NOMBRECOMPLETO as Nombre
		,e.Puesto
		,e.Departamento
		,JSON_VALUE(ci.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,TipoIncidencia = case when isnull(ci.EsAusentismo,0) = 1 then 'Ausentismo' else 'Incidencia' end
		,format(ie.Fecha,'dd/MM/yyyy') as Fecha
		,ie.Fecha as FechaAsDate
		,format(isnull(ie.TiempoSugerido  ,'00:00'), N'hh\:mm') as TiempoSugerido
		,format(isnull(ie.TiempoAutorizado,'00:00'),N'hh\:mm') as TiempoAutorizado
		,Autorizado = case when isnull(ie.Autorizado,0) = 1 then 'SI' else 'NO' end
		,upper(ie.Comentario) as Comentario
		,Estatus = case when isnull(em.Vigente,0) = 1 then 'VIGENTE' else 'NO VIGENTE' end
		,@Titulo as Titulo
	from @dtEmpleados e
		join RH.tblEmpleadosMaster em on e.IDEmpleado = em.IDEmpleado
		join Asistencia.tblIncidenciaEmpleado ie with (nolock) on e.IDEmpleado = ie.IDEmpleado
		join Asistencia.tblCatIncidencias ci with (nolock) on ie.IDIncidencia = ci.IDIncidencia
	where ie.Fecha between @FechaIni and @FechaFin 
		and isnull(ci.EsAusentismo,0) = case when @SoloIncidencias = 1 then 0 else isnull(ci.EsAusentismo,0) end
GO

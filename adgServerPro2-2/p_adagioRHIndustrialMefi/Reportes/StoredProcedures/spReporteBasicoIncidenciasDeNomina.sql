USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		  
CREATE proc [Reportes].[spReporteBasicoIncidenciasDeNomina] (
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
		,@dtEmpleados RH.dtEmpleados
		,@IDCliente int
		,@IDTipoNomina int
		,@FechaIni Date
		,@FechaFin Date
		,@IDTurno int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)
		,@SoloIncidencias bit = 0
		,@TipoVigente int = 1
	;

	SET @IDTipoNomina	= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),getdate())
	SET @FechaFin		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),getdate())
	SET @IDTurno		= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),',')),0)
	SET @EmpleadoIni	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	SET @SoloIncidencias= isnull((Select top 1 case when [Value] = 'True' then 1 else 0 end  from @dtFiltros where Catalogo = 'SoloIncidencias'),0)
	SET @TipoVigente	= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'),',')),1)
  
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

	if (@TipoVigente = 1)
	begin
		insert @dtEmpleados  
		exec [RH].[spBuscarEmpleados]   
			@FechaIni		= @FechaIni           
			,@FechaFin		= @FechaFin    
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin
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
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin
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
		,[Tipo Incidencia] = case when isnull(ci.EsAusentismo,0) = 1 then 'Ausentismo' else 'Incidencia' end
		,format(ie.Fecha,'dd/MM/yyyy') as Fecha
		,format(isnull(ie.TiempoSugerido  ,'00:00'), N'hh\:mm') as [Tiempo Sugerido]
		,format(isnull(ie.TiempoAutorizado,'00:00'),N'hh\:mm') as [Tiempo Autorizado]
		,Autorizado = case when isnull(ie.Autorizado,0) = 1 then 'SI' else 'NO' end
		,upper(ie.Comentario) as Comentario
		,Estatus = case when isnull(em.Vigente,0) = 1 then 'VIGENTE' else 'NO VIGENTE' end
	from @dtEmpleados e
		join RH.tblEmpleadosMaster em on e.IDEmpleado = em.IDEmpleado
		join Asistencia.tblIncidenciaEmpleado ie with (nolock) on e.IDEmpleado = ie.IDEmpleado
		join Asistencia.tblCatIncidencias ci with (nolock) on ie.IDIncidencia = ci.IDIncidencia
	where ie.Fecha between @FechaIni and @FechaFin and isnull(ci.EsAusentismo,0) = case when @SoloIncidencias = 1 then 0 else isnull(ci.EsAusentismo,0) end
GO

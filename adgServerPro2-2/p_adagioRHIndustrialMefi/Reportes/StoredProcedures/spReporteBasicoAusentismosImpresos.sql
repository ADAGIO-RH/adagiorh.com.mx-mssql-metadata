USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Empleados
--Departamentos
--Sucursales
--Puestos
--Prestaciones
--Clientes
--TiposContratacion
--RazonesSociales
--RegPatronales
--Divisiones
--ClasificacionesCorporativas
--NombreClaveFilter

--exec  Reportes.spReporteBasicoAusentismosImpresos  @Clientes = '1',@FechaIni = '2019-10-01',@FechaFin = '2019-11-12',@IDUsuario=1
CREATE proc [Reportes].[spReporteBasicoAusentismosImpresos] (
	@FechaIni date 
	,@FechaFin date
	,@ClaveEmpleadoInicial varchar (max) = '0'
	,@ClaveEmpleadoFinal varchar (max) = 'ZZZZZZZZZZZZZZZZZZZZ'
	,@Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= ''    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@TipoVigente int = 1
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;

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
	    
	SET @Titulo =  UPPER( 'REPORTE DE AUSENTISMOS DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))		

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
		,format(ie.Fecha,'dd/MM/yyyy') as Fecha
		,ie.Fecha as FechaAsDate
		,Autorizado = case when isnull(ie.Autorizado,0) = 1 then 'SI' else 'NO' end
		,Estatus = case when isnull(em.Vigente,0) = 1 then 'SI' else 'NO' end
		,@Titulo as Titulo
	from @dtEmpleados e
		join RH.tblEmpleadosMaster em with (nolock) on e.IDEmpleado = em.IDEmpleado
		join Asistencia.tblIncidenciaEmpleado ie with (nolock) on e.IDEmpleado = ie.IDEmpleado
		join Asistencia.tblCatIncidencias ci with (nolock) on ie.IDIncidencia = ci.IDIncidencia
	where ie.Fecha between @FechaIni and @FechaFin and isnull(ci.EsAusentismo,0) = 1
GO

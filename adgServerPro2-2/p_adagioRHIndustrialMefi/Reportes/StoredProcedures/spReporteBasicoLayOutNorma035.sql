USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoLayOutNorma035] (
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
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)
		,@TipoVigente int = 1
	;

	SET @IDTipoNomina	= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),getdate())
	SET @FechaFin		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),getdate())
	SET @EmpleadoIni	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	SET @TipoVigente	= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'),',')),1)
  
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
		--,UPPER(COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) as Nombres
		--,UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')) as Apellidos
		,RTRIM(LTRIM(CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), '') = ''			THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Nombre,''))), '') +' ' END+ 
					 CASE WHEN COALESCE(LTRIM(RTRIM(isnull(e.SegundoNombre,''))), '') = ''	THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(e.SegundoNombre,''))), ' ') +' ' END)) as Nombres
		,RTRIM(LTRIM(CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Paterno,''))), '') = ''		THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Paterno,''))), '')+' ' END+ 
					 CASE WHEN COALESCE(LTRIM(RTRIM(isnull(E.Materno,''))), '') = ''		THEN '' ELSE COALESCE(LTRIM(RTRIM(isnull(E.Materno,''))), '')END)) as Apellidos

		,e.Sucursal as [Centro De Trabajo]
		,e.Departamento
		,e.Puesto as Rol
		,Email = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(case when isnull(u.Email,'') <> '' then LOWER(u.Email) else isnull(emailEmpleado.[Value],'') end, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), CHAR(160), '')))
		--,Email = ltrim(rtrim(case when isnull(u.Email,'') <> '' then LOWER(u.Email) else isnull(emailEmpleado.[Value],'') end))
	from @dtEmpleados e
		left join Seguridad.tblUsuarios u with (nolock) on e.IDEmpleado = u.IDEmpleado
		left join (select ce.IDEmpleado,isnull(lower(ce.[Value]),'') as [Value],ROW_NUMBER()OVER(partition by ce.IDEmpleado order by ce.IDEmpleado) as [Row]
					from RH.tblContactoEmpleado ce with (nolock)
						join RH.tblCatTipoContactoEmpleado ctce with (nolock) on ce.IDTipoContactoEmpleado = ctce.IDTipoContacto
					where ctce.Descripcion like '%mail%') emailEmpleado on e.IDEmpleado = emailEmpleado.IDEmpleado and emailEmpleado.[Row] = 1
GO

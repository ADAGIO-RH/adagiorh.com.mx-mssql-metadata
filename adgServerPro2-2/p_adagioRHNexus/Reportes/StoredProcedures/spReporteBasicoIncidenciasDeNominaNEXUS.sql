USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		  
CREATE proc [Reportes].[spReporteBasicoIncidenciasDeNominaNEXUS] (
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
  
	--if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
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
	

	(
select 
e.ClaveEmpleado as Clave,
e.NOMBRECOMPLETO as Nombre
,e.Region as Region
		,e.Sucursal as Sucursal
		,e.CentroCosto as CECO
		,e.Departamento as Departamento
		,e.Puesto as Puesto
        ,e.Area as Area
		,JSON_VALUE(ci.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoIncidencia
		,format(ie.Fecha,'dd/MM/yyyy') as Fecha
		,'-' as FechaIni
		,'-' as FechaFin
				,Autorizado = case when isnull(ie.Autorizado,0) = 1 then 'SI' else 'NO' end
				,Estatus = case when isnull(ie.Autorizado,0) = 1 then '' else 'AUTORIZACION PENDIENTE' end
				,'Incidencia-Calendario' as Origen
				,UPPER(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		TRANSLATE(ie.Comentario,'ÁáÉéÍíÓóÚú','AaEeIiOoUu'),
		'&aacute;','á'),'&eacute;','é'),'&iacute;','í'),
		'&oacute;','ó'),'&uacute;','ú'),'&Aacute;','Á'),
		'&Eacute;','É'),'&Iacute;','Í'),'&Oacute;','Ó'),
		'&Uacute;','Ú'),'&ntilde;','ñ'),'&Ntilde;','Ñ'),
		'&iquest;','¿'),'&nbsp;',' ')
		) as Comentario
		,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = e.IDEmpleado
				) as Supervisor
			
				    ,isnull(EmpA.ClaveEmpleado,'') [Clave_AutorizadoPor]
		,isnull(EmpA.NOMBRECOMPLETO,'') [Nombre_AutorizadoPor]
        ,isnull(empC.ClaveNombreCompleto,'') CreadoPor
--into #incidencias
from @dtEmpleados m 
		inner join RH.tblEmpleadosMaster e on e.ClaveEmpleado = m.claveempleado
		join Asistencia.tblIncidenciaEmpleado ie with (nolock) on e.IDEmpleado = ie.IDEmpleado
		join Asistencia.tblCatIncidencias ci with (nolock) on ie.IDIncidencia = ci.IDIncidencia
			join RH.tblJefesEmpleados je on e.IDEmpleado = je.IDEmpleado
			        left join Seguridad.tblUsuarios u on ie.AutorizadoPor = u.IDUsuario
			 left join Seguridad.tblUsuarios us on ie.CreadoPorIDUsuario = us.IDUsuario
        left join rh.tblEmpleadosMaster EmpA on EmpA.IDEmpleado = u.IDEmpleado
        left join rh.tblEmpleadosMaster EmpC on EmpC.IDEmpleado = us.IDEmpleado
			where ie.Fecha between @FechaIni and @FechaFin  and isnull(ci.EsAusentismo,0) = case when @SoloIncidencias = 1 then 0 else isnull(ci.EsAusentismo,0) end
			)
			union
			(
select e.ClaveEmpleado as Clave,
		e.NOMBRECOMPLETO as Nombre,
		e.Region as Region
		,e.Sucursal as Sucursal
		,e.CentroCosto as CECO
		,e.Departamento as Departamento
		,e.Puesto as Puesto
        ,e.Area as Area
		,JSON_VALUE(ci.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoIncidencia
		,format(ie.FechaCreacion,'dd/MM/yyyy') as Fecha
		,format(ie.FechaIni,'dd/MM/yyyy') as FechaIni
		,format(ie.FechaFin,'dd/MM/yyyy') as FechaFin
		,Autorizado = case when isnull(ie.IDEstatusSolicitud,0) = 2 then 'SI'  else 'NO' end
		,Estatus = isnull(ss.Descripcion,0) 
		,'Solicitud-Intranet' as Origen
		,UPPER(
		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
		TRANSLATE(ie.ComentarioEmpleado,'ÁáÉéÍíÓóÚú','AaEeIiOoUu'),
		'&aacute;','á'),'&eacute;','é'),'&iacute;','í'),
		'&oacute;','ó'),'&uacute;','ú'),'&Aacute;','Á'),
		'&Eacute;','É'),'&Iacute;','Í'),'&Oacute;','Ó'),
		'&Uacute;','Ú'),'&ntilde;','ñ'),'&Ntilde;','Ñ'),
		'&iquest;','¿'),'&nbsp;',' ')
		) as Comentario
		,(Select top 1 emp.ClaveEmpleado + '-' + emp.NOMBRECOMPLETO from RH.tblJefesEmpleados je with(nolock)
				inner join RH.tblEmpleadosMaster emp with(nolock)
					on je.IDJefe = emp.IDEmpleado
				where je.IDEmpleado = e.IDEmpleado
				) as Supervisor
				   ,isnull(EmpA.ClaveEmpleado,'') [Clave_AutorizadoPor]
		,isnull(EmpA.NOMBRECOMPLETO,'') [Nombre_AutorizadoPor]
        ,isnull(empC.ClaveNombreCompleto,'') CreadoPor

from
		@dtEmpleados m 
		inner join RH.tblEmpleadosMaster e on e.ClaveEmpleado = m.claveempleado
		join intranet.tblsolicitudesempleado ie with (nolock) on e.IDEmpleado = ie.IDEmpleado
		inner join Intranet.tblCatEstatusSolicitudes ss on ie.IDEstatusSolicitud = ss.IDEstatusSolicitud
		join Asistencia.tblCatIncidencias ci with (nolock) on ie.IDIncidencia = ci.IDIncidencia
			join RH.tblJefesEmpleados je on e.IDEmpleado = je.IDEmpleado
			        left join Seguridad.tblUsuarios u on ie.IDUsuarioAutoriza = u.IDUsuario

					 left join Seguridad.tblUsuarios us on ie.IDEmpleado = us.IDEmpleado
        left join rh.tblEmpleadosMaster EmpA on EmpA.IDEmpleado = u.IDEmpleado
        left join rh.tblEmpleadosMaster EmpC on EmpC.IDEmpleado = us.IDEmpleado
			where format(ie.FechaCreacion,'yyyy-MM-dd') between @FechaIni and @FechaFin   and isnull(ci.EsAusentismo,0) = case when @SoloIncidencias = 1 then 0 else isnull(ci.EsAusentismo,0) end


			)
GO

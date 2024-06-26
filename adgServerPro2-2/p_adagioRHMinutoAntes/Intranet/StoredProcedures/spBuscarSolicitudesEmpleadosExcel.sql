USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarSolicitudesEmpleadosExcel](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN

    declare  
		@IDIdioma varchar(225),
		@Empleados  varchar(max) = null,
		@FechaIni varchar(max) = null,
		@FechaFin varchar(max)= null;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    
	set @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
    set @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))
    set @Empleados = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),',')),'0')

	SELECT 	 
		M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
		,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
		,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Estatus
		,SE.IDIncidencia 
		,JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,isnull(SE.FechaIni,'9999-12-31') as Fecha
		,ISNULL(SE.CantidadDias,0) as Días
        ,convert(varchar, SE.FechaCreacion, 23) as FechaSolicitud
    	,SE.ComentarioEmpleado
		,SE.ComentarioSupervisor        
		,SE.DiasDescanso
		,SE.FechaCreacion 
		,isnull(SE.IDUsuarioAutoriza,0) as IDUsuarioAutoriza		
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
	WHERE CAST( SE.FechaCreacion as date) BETWEEN CAST( @FechaIni as date)  and CAST(@FechaFin as date)  
             and (se.IDEmpleado = isnull(@Empleados,0) or isnull(@Empleados,0) = 0)
	ORDER BY SE.FechaCreacion DESC
END
GO

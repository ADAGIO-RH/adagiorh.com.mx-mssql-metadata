USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarSolicitudesIncidenciasEmpleados](
	@IDUsuario int
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY          
) AS
BEGIN
	declare  
		@IDIdioma varchar(225),		
		@IDIncidencia varchar(4)='',
		@IDEmpleado int = 0,		
		@IDTipoSolicitud int = 0,
		@IDEstatusSolicitud int = 0,
		@IDEstatusSolicitudPrestamos int = 0,	 
		@orderByColumn	varchar(50) = 'Incidencia',
		@orderDirection varchar(4) = 'asc' 
	;
	
    IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL DROP TABLE #tempSetPagination
    	        
    Select  @orderByColumn=isnull(Value,'Incidencia') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'
    
    SET @IDTipoSolicitud	= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitud'),0)    	
    SET @IDEmpleado		= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)    	
  	SET @IDIncidencia	= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDIncidencia'),'') 
	SET @IDEstatusSolicitudPrestamos = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEstatus'),0)   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
	select @IDEstatusSolicitud = IDEstatusSolicitudReferencia from Intranet.tblCatEstatusSolicitudesPrestamos where IDEstatusSolicitudPrestamo =@IDEstatusSolicitudPrestamos
	--select @IDEstatusSolicitud
    --select @orderByColumn
	SELECT 		
        ROW_NUMBER()Over(Order by  
            case when @orderByColumn = 'Incidencia' and @orderDirection = 'asc'		then JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) end,
            case when @orderByColumn = 'Incidencia' and @orderDirection = 'desc'	then JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  end desc,
			case when @orderByColumn = 'FechaIni'	and @orderDirection = 'asc'		then FechaIni	end,
            case when @orderByColumn = 'FechaIni'	and @orderDirection = 'desc'	then FechaIni	end desc,
			case when @orderByColumn = 'CantidadDias' and @orderDirection = 'asc'	then CantidadDias	end ,
            case when @orderByColumn = 'CantidadDias' and @orderDirection = 'desc'	then CantidadDias  end desc  
        )  as [row],
		SE.IDSolicitud as IDSolicitud
		,SE.IDTipoSolicitud as IDTipoSolicitud
		,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud	
		,JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia	
		,isnull(SE.FechaIni,'9999-12-31') as FechaIni
		,isnull(SE.FechaFin,'9999-12-31') as FechaFin
		,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud	
		,ISNULL(SE.CantidadDias,0) as CantidadDias	
		,ES.CssClas as CssClas	
		,M.IDEmpleado
		,I.AdministrarSaldos
	into #tempSetPagination
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
		left join Intranet.tblCatEstatusSolicitudesPrestamos CESP on CESP.IDEstatusSolicitudPrestamo = SE.IDEstatusSolicitud
	WHERE (SE.IDEmpleado = @IDEmpleado  OR @IDEmpleado = 0)
		AND (SE.IDEstatusSolicitud = @IDEstatusSolicitud or isnull(@IDEstatusSolicitud ,0)=0)
		AND (SE.IDIncidencia = @IDIncidencia OR @IDIncidencia = '')
		AND (SE.IDTipoSolicitud = @IDTipoSolicitud OR ISNULL(@IDTipoSolicitud, 0) = 0)
        
    if exists(select top 1 * from @dtPagination)
    BEGIN
        exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
    end else 
    begin 
        select  * From #tempSetPagination order by row desc
    end
END
GO

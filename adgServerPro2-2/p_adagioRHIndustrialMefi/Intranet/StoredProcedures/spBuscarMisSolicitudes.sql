USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Intranet].[spBuscarMisSolicitudes](
	@IDUsuario int
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY             
)
AS
BEGIN
	declare  
		@IDEmpleado int,
		@IDTipoSolicitud VARCHAR(MAX),
		@IDIdioma varchar(225)

	    ,@orderByColumn	varchar(50) = 'ClaveRuta'
	    ,@orderDirection varchar(4) = 'asc'
	;

	IF OBJECT_ID('TEMPDB.dbo.#tempSetPagination') IS NOT NULL DROP TABLE #tempSetPagination  

    Select  @orderByColumn=isnull(Value,'IDEmpleado') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'

    SET @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)    	
    SET @IDTipoSolicitud = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitud'),'')    	

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

	WITH TABLA AS(
		select 
			sp.IDSolicitudPrestamo as  IDSolicitud,
			4 as IDTipoSolicitud
			,'PRESTAMOS' as TipoSolicitud
			,isnull(cesp.Nombre, 'Sin estatus préstamo') as Estatus
			,isnull(sp.FechaCreacion,  '9999-12-31') as FechaIni
			,isnull (sp.FechaHoraCancelacion, '9999-12-31') AS FechaFin		
			,isnull(sp.MontoPrestamo,0.00) as Resumen
			,cesp.CssClass as Estilo		
			,sp.IDEmpleado as IDEmpleado
		from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)		
			join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
			join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		where (SP.IDEmpleado = @IDEmpleado or @IDEmpleado =0)
		Union All
		SELECT 
			SE.IDSolicitud as IDSolicitud,
			se.IDTipoSolicitud as IDTipoSolicitud
			,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
			,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Estatus
			,isnull(SE.FechaIni,'9999-12-31') as FechaIni
			,ISNULL(SE.FechaFin, '9999-12-31') AS FechaFin
			,ISNULL(SE.CantidadDias,0) as Resumen			
			,ES.CssClas as Estilo
			,SE.IDEmpleado as IDEmpleado
		FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)	
			INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud
			INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud	
		where  (SE.IDEmpleado = @IDEmpleado or @IDEmpleado = 0) 
	) SELECT * ,
		ROW_NUMBER()Over(Order by  
            case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'asc'		then TipoSolicitud end ,
            case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'desc'	then TipoSolicitud end desc 
        )  as [row] 	into #tempSetPagination FROM TABLA
	where  --(TABLA.IDTipoSolicitud in (Select item from App.Split(@IDTipoSolicitud,',')) or isnull(@IDTipoSolicitud, '') = '') AND 
	TABLA.IDTipoSolicitud!=1

    if exists(select top 1 * from @dtPagination)
    BEGIN
        exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
    end
    else 
    begin 
        select  * From #tempSetPagination order by row desc
    end
END




--exec [Intranet].[spBuscarMisSolicitudes] @IDUsuario=1
GO

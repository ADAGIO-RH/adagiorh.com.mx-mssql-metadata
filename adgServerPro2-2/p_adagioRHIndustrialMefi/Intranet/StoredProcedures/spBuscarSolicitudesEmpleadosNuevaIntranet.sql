USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Intranet].[spBuscarSolicitudesEmpleadosNuevaIntranet](	
	@IDUsuario int,
    @PageNumber	int = 1,
	@PageSize		int = 2147483647,
	@query			varchar(100) = '""',
	@orderByColumn	varchar(50) = 'TipoSolicitud',
	@orderDirection varchar(4) = 'asc',
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY             
    
)
AS
BEGIN
	declare 
		@IDSolicitud int,
        @IDEmpleado int ,
        @IDEstatusSolicitudPrestamo int ,
		@IDTipoSolicitud VARCHAR(MAX),
        @IDIdioma varchar(225),
        @FechaIni date,  
        @FechaFin date
	;
 

    set @IDSolicitud = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDSolicitud'),0)
    set @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)
    SET @IDTipoSolicitud = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitud'),'')
    set @IDEstatusSolicitudPrestamo= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEstatusSolicitudPrestamo'),0)    

    Select  @FechaIni=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaIni'
    Select  @FechaFin=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaFin'

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

    set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

	declare @tempResponse as table (
		 IDSolicitud   int   
        ,Folio varchar(20)      
        ,IDEmpleado int      
        ,ClaveEmpleado varchar(100)   
        ,NombreCompleto varchar(100)   
        ,Puesto varchar(100)   
        ,Departamento varchar(100)   
        ,Sucursal varchar(100)           
        ,IDTipoSolicitud int
		,TipoSolicitud varchar(100)    
		,IDEstatusSolicitud int
		,EstatusSolicitud varchar(20)
		,IDIncidencia varchar(20)
        ,Incidencia varchar(100)
        ,FechaIni date
        ,FechaFin date
        ,CantidadDias int
        ,DiasDescanso varchar(100)
        ,FechaCreacion date
        ,ComentarioEmpleado varchar(max)
        ,ComentarioSupervisor varchar(max)
        ,CantidadMonto decimal(10,2)
	 	,IDUsuarioAutoriza INT
        ,ROWNUMBER INT
        ,CssClass varchar(100)
        ,VueBindingStyle varchar(max)
	);

    insert into @tempResponse
	SELECT 
		SE.IDSolicitud
		,'S'+ cast(SE.IDSolicitud as Varchar(10)) as Folio
		,SE.IDEmpleado
		,M.ClaveEmpleado
		,M.NOMBRECOMPLETO as NombreCompleto
        ,M.Puesto
        ,M.Departamento
        ,m.Sucursal
		,SE.IDTipoSolicitud
		,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
		,SE.IDEstatusSolicitud 
		,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
		,SE.IDIncidencia 		
		,JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
		,isnull(SE.FechaIni,'9999-12-31') as FechaIni
		,SE.FechaFin
		,ISNULL(SE.CantidadDias,0) as CantidadDias
		,SE.DiasDescanso
		,SE.FechaCreacion
		,SE.ComentarioEmpleado
		,SE.ComentarioSupervisor
		,ISNULL(SE.CantidadMonto,0) as CantidadMonto
		,isnull(SE.IDUsuarioAutoriza,0) as IDUsuarioAutoriza
		,ROW_NUMBER()OVER(ORDER BY SE.IDSolicitud ASC) ROWNUMBER
        ,ES.CssClass
        ,ES.VueBindingStyle            
	FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado
		INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud
		INNER JOIN Intranet.tblCatEstatusSolicitudesPrestamos ES WITH(NOLOCK) on ES.IDEstatusSolicitudReferencia = SE.IDEstatusSolicitud
		LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
	WHERE (SE.IDSolicitud = @IDSolicitud OR @IDSolicitud = 0)		 
    and ( ts.IDTipoSolicitud in(select item from app.Split(@IDTipoSolicitud,',')) or @IDTipoSolicitud='') 
    
    and (ES.IDEstatusSolicitudPrestamo=@IDEstatusSolicitudPrestamo or @IDEstatusSolicitudPrestamo=0)
    and (SE.IDEmpleado= @IDEmpleado or @IDEmpleado=0)
	ORDER BY SE.FechaCreacion DESC

    select @TotalRegistros = cast(COUNT([IDSolicitud]) as int) from @tempResponse		
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2))) from @tempResponse
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows = @TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'asc'		then TipoSolicitud end,			
		case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'desc'	then TipoSolicitud end desc,
        case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc	,									
        case when @orderByColumn = 'Folio'			and @orderDirection = 'asc'		then Folio end,			
		case when @orderByColumn = 'Folio'			and @orderDirection = 'desc'	then Folio end desc										
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
     
END
GO

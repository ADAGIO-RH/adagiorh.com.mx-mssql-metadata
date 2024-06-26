USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Comunicacion].[spBuscarAvisos]
( 
	@IDUsuario int 
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH]  READONLY             
)
AS
BEGIN
    declare          
		@IDIdioma varchar(225),		 
	    @orderByColumn	varchar(50) = 'Titulo',
	    @orderDirection varchar(4) = 'asc',
        @IDAviso int =0,
        @IDEstatus int =0,
        @IDTipoAviso int =0,
        @search varchar(max) =''

    
            
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');      
    Select  @orderByColumn=isnull(Value,'IDEmpleado') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'

    Select  @IDAviso=isnull(Value,0) from @dtFiltros where Catalogo = 'IDAviso'
    Select  @IDEstatus=isnull(Value,0) from @dtFiltros where Catalogo = 'IDEstatus'
    Select  @IDTipoAviso=isnull(Value,0) from @dtFiltros where Catalogo = 'IDTipoAviso'
    Select  @search=isnull(Value,'') from @dtFiltros where Catalogo = 'search'

    
    
    IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL
    BEGIN
        DROP TABLE #tempSetPagination
    END

    
    
    select
        a.IDAviso,
        a.Titulo,
        a.Descripcion,
        a.DescripcionHTML,
        a.FechaInicio,
        a.FechaFin,
        a.IsGeneral,
        a.Ubicacion,
        a.HoraInicio,
        ea.IDEstatus [IDEstatus],        
        ea.Variant [Variant],
        ta.ClassStyle,
        a.TopPXToBanner,
        a.HeightPXToBanner,
        a.EnviarNotificacion,
        a.Enviado,
        a.FileJson,
        JSON_VALUE(ea.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) [Estatus],        
        ta.IDTipoAviso [IDTipoAviso],
        JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Titulo')) [TipoAviso],        
        --ta.Titulo as tt,
    
        ROW_NUMBER()Over(Order by  
                                case when @orderByColumn = 'Titulo'			and @orderDirection = 'asc'		then a.Titulo end ,
                                case when @orderByColumn = 'Titulo'			and @orderDirection = 'desc'		then a.Titulo end desc                                     
        )  as [row]
    into #tempSetPagination
    FROM  Comunicacion.tblAvisos a
        INNER JOIN Comunicacion.tblCatTiposAviso ta on ta.IDTipoAviso=a.IDTipoAviso 
        inner join Comunicacion.tblCatEstatusAviso ea on ea.IDEstatus=a.IDEstatus
    Where (a.IDAviso= @IDAviso or @IDAviso=0) and
         (a.IDEstatus=@IDEstatus or @IDEstatus=0) and 
         (a.IDTipoAviso=@IDTipoAviso or @IDTipoAviso=0) and 
         (@search = '' or (a.Titulo like '%'+@search+'%' or a.Descripcion like '%'+@search+'%'))
    
         

    if exists(select top 1 * from @dtPagination)
        BEGIN
            exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
        end
    else 
        begin 
            select  * From #tempSetPagination order by row desc
        end


END
GO

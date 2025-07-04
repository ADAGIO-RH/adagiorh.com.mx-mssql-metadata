USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento almacenado para buscar tipos de pólizas
** Autor			: ANEUDY ABREU
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2024-01-17
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROCEDURE [Nomina].[spBuscarCatTiposPolizas](
    @IDTipoPoliza int = 0
    ,@IDUsuario int
    ,@PageNumber int = 1
    ,@PageSize int = 2147483647
    ,@query varchar(100) = '""'
    ,@orderByColumn varchar(50) = 'Nombre'
    ,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
    SET FMTONLY OFF;

    declare
        @TotalPaginas int = 0
        ,@TotalRegistros int
        ,@IDIdioma varchar(max)
    ;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
    if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

    select
        @orderByColumn = case when @orderByColumn is null then 'Nombre' else @orderByColumn end
        ,@orderDirection = case when @orderDirection is null then 'asc' else @orderDirection end

    IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;

    set @query = case
                when @query is null then '""'
                when @query = '' then '""'
                when @query = '""' then '""'
            else '"'+@query + '*"' end

    SELECT
        ctp.IDTipoPoliza
        ,JSON_VALUE(ctp.Nombre, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre
        ,UPPER(JSON_VALUE(ctp.Descripcion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion
		,ctp.FechaCreacion
    Into #TempResponse
    FROM Nomina.tblCatTiposPolizas ctp
    WHERE (ctp.IDTipoPoliza = @IDTipoPoliza or isnull(@IDTipoPoliza, 0) = 0)
            and (@query = '""' or contains(ctp.*, @query))
    order by JSON_VALUE(ctp.Nombre, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) asc

    select @TotalPaginas = CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
    from #tempResponse

    select @TotalRegistros = COUNT(@IDTipoPoliza) from #tempResponse

    select *
        ,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,ISNULL(@TotalRegistros, 0) as TotalRegistros
    from #tempResponse
    order by
        case when @orderByColumn = 'Nombre' and @orderDirection = 'asc' then Nombre end,
        case when @orderByColumn = 'Nombre' and @orderDirection = 'desc' then Nombre end desc,
        Nombre asc
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

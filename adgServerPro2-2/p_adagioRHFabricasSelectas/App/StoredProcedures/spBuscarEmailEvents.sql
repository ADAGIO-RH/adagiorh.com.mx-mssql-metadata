USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spBuscarEmailEvents](
    @IDReferencia int = 0,
    @TipoReferencia varchar(50) = null,
    @PageNumber int = 1,
    @PageSize int = 2147483647,
    @query varchar(100) = '',
    @orderByColumn varchar(50) = 'CreatedAt',    
    @orderDirection varchar(4) = 'desc' ,

    @Event varchar(50) = '',
    @IDTipoNotificacion  varchar(50) = '',
    @IDsUsuarios varchar(200) = '',
    @FechaInicio date = null,
    @FechaFin date = null
)
AS
BEGIN
    declare
        @TotalPaginas int = 0,
        @TotalRegistros int
    ;

    if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
    if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
    -- set @query = case 
    --                 when @query is null then '""' 
    --                 when @query = '' then '""'
    --                 when @query = '""' then '""'
    --             else '"'+@query + '*"' end

    select
        @orderByColumn = case when @orderByColumn is null then 'CreatedAt' else @orderByColumn end,
        @orderDirection = case when @orderDirection is null then 'desc' else @orderDirection end

    SET FMTONLY OFF;

    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse

    SELECT
        EmailEventId,
        IDEnviarNotificacionA,
        m.IDNotifiacion,
        Subdomain,
        m.Email,
        Event,
        IP,
        SgContentType,
        SgEventId,
        SgMachineOpen,
        SgMessageId,
        SgTemplateId,
        SgTemplateName,
        Timestamp,
        TransactionId,
        UserAgent,
        CreatedAt,
        isnull(m.CurrentEvent,'') as CurrentEvent,
        ISNULL(TipoReferencia,'') as TipoReferencia,
        IDReferencia,
        ROW_NUMBER() OVER (ORDER BY CreatedAt DESC) as ROWNUMBER,
        isnull(n.IDTipoNotificacion,'') as IDTipoNotificacion,
        m.IDUsuario,
        Utilerias.fnGetUrlFotoUsuario(s.Cuenta) as photo,
        case 
            when mm.IDEmpleado is not null then mm.NOMBRECOMPLETO
            when s.IDUsuario is not null then (s.Nombre + ' ' +s.Apellido)
            else '-- N/A --' end as NombreCompleto,            
        case 
            when mm.IDEmpleado is not null then mm.ClaveEmpleado
            when s.IDUsuario is not null then s.Cuenta
            else '-- N/A --' end as ClaveUsuario

    INTO #TempResponse
    FROM app.tblEmailEvents m WITH (NOLOCK)
    left join app.tblNotificaciones n WITH (NOLOCK) on m.IDNotifiacion=n.IDNotifiacion
    left join Seguridad.tblUsuarios s WITH (NOLOCK) on s.IDUsuario=m.IDUsuario
    left join rh.tblEmpleadosMaster mm WITH (NOLOCK) on mm.IDEmpleado=s.IDEmpleado
    WHERE
        ((isnull(@IDReferencia,0) = 0) OR (IDReferencia = @IDReferencia))
        AND (( isnull(@TipoReferencia,'') ='') OR (TipoReferencia = @TipoReferencia))
        AND (( isnull(@IDTipoNotificacion,'') ='') OR (n.IDTipoNotificacion = @IDTipoNotificacion))
        AND (( isnull(@Event,'') ='') OR (Event = @Event))
        AND ( isnull(@query,'') = '' OR  m.Email like ''+@query+'%'  or SgMessageId=''+@query+'')
        and (m.IDUsuario in (Select item from App.Split(@IDsUsuarios,',')) OR @IDsUsuarios='')               
        AND (
                ( cast(m.CreatedAt as date) BETWEEN @FechaInicio and @FechaFin  )
                or (@FechaFin is null and @FechaInicio is null)              
        )        
    ORDER BY CreatedAt DESC

    select @TotalPaginas = CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
    from #tempResponse

    select @TotalRegistros = COUNT(EmailEventId) from #tempResponse

    select *
        ,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end,
        ISNULL(@TotalRegistros, 0) as TotalRegistros
    from #tempResponse
    order by 
        SgMessageId asc,
        case when @orderByColumn = 'CreatedAt' and @orderDirection = 'asc' then CreatedAt end,
        case when @orderByColumn = 'CreatedAt' and @orderDirection = 'desc' then CreatedAt end desc,
        case when @orderByColumn = 'Email' and @orderDirection = 'asc' then Email end,
        case when @orderByColumn = 'Email' and @orderDirection = 'desc' then Email end desc,
        case when @orderByColumn = 'Event' and @orderDirection = 'asc' then Event end,
        case when @orderByColumn = 'Event' and @orderDirection = 'desc' then Event end desc,
        CreatedAt desc
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

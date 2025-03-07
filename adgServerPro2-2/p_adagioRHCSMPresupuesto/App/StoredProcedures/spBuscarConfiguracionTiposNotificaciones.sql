USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Tipos de notificaciones
** Autor			: ?
** Email			: ?
** FechaCreacion	: ?
** Paremetros		:              
    @IsSpecial
        0           : no especiales
        1           : especiales
        null o -1   : trae todos 
        
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2023-08-22			Jose Vargas	        Se agrega paginación
2023-08-22			Jose Vargas	        Se agrega columna SourceEmailDefault  
***************************************************************************************************/
CREATE PROC [App].[spBuscarConfiguracionTiposNotificaciones] 
(
    @IDTipoNotificacion	varchar(50) = null,
    @MedioNotificacion varchar(50) = null,
    @IDUsuario int =null,
    @PageNumber	int = 1,
	@PageSize		int = 2147483647,
	@query			varchar(100) = null,
	@orderByColumn	varchar(50) = 'IDTipoNotificacion',
	@orderDirection varchar(4) = 'asc'
) as

    declare  
        @TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00		
        ,@IDIdioma varchar(20)
	;	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDTipoNotificacion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query = '' then null
				else @query end

    IF OBJECT_ID('tempdb..#TempTiposNotificaciones') IS NOT NULL DROP TABLE #TempTiposNotificaciones
    
    select 
        noti.IDTipoNotificacion,Descripcion,Asunto,noti.Nombre,coalesce(IsSpecial,0) [IsSpecial],
        isnull(catconfig.Nombre,'') NombreConfiguracion,
        isnull(catconfig.IDTipoConfiguracionNotificacion,0) as [IDTipoConfiguracionNotificacion]
     into #TempTiposNotificaciones  
    from [App].[tblTiposNotificaciones] noti
    left join  APP.tblConfiguracionTiposNotificaciones confi on confi.IDTipoNotificacion=noti.IDTipoNotificacion
    left join app.tblCatTiposConfiguracionesNotificaciones catconfig on  confi.IDTipoConfiguracionNotificacion=catconfig.IDTipoConfiguracionNotificacion
    where (noti.IDTipoNotificacion=@IDTipoNotificacion or @IDTipoNotificacion is null or @IDTipoNotificacion ='' ) 

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempTiposNotificaciones

	select @TotalRegistros = cast(COUNT([IDTipoNotificacion]) as decimal(18,2)) from #TempTiposNotificaciones		
	
	select
		*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        , cast(@TotalRegistros  as int ) as TotalRows
	from #TempTiposNotificaciones
	 order by  
            case when @orderByColumn = 'IDTipoNotificacion'			and @orderDirection = 'asc'		then IDTipoNotificacion end ,
            case when @orderByColumn = 'IDTipoNotificacion'			and @orderDirection = 'desc'		then IDTipoNotificacion end desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

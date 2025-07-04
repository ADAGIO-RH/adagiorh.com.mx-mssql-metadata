USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [RH].[spBuscarCatTipoContactoEmpleado](
    @IDTipoContacto int = 0
	,@IDUsuario		int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
) as

	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	   ,@IDIdioma varchar(20)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
	
    
    SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	declare @tempResponse as table (
		 IDTipoContacto	int   
		,Descripcion	varchar(100)    
		,Mask			varchar(100) Null   
		,CssClassIcon	varchar(100) Null    
		,IDMedioNotificacion   varchar(50)   Null
		,MedioNotificacion   varchar(250)   Null
		,Traduccion varchar(max)
	);

	insert into @tempResponse
    select 
		 c.IDTipoContacto
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,c.Mask
		,c.CssClassIcon
		,c.IDMedioNotificacion
		,JSON_VALUE(mn.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion
		,c.Traduccion
    from [RH].[tblCatTipoContactoEmpleado] c with (nolock)
		join App.tblMediosNotificaciones mn on mn.IDMedioNotificacion = c.IDMedioNotificacion
    where (IDTipoContacto = @IDTipoContacto or @IDTipoContacto = 0)
	and (@query = '""' or contains(c.*, @query)) 
    --order by Descripcion

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDTipoContacto]) as decimal(18,2)) from @tempResponse	

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		case when @orderByColumn = 'IDMedioNotificacion'	and @orderDirection = 'asc'		then IDMedioNotificacion end,		
		case when @orderByColumn = 'IDMedioNotificacion'	and @orderDirection = 'desc'	then IDMedioNotificacion end desc,		
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

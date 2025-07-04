USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [Seguridad].[spBuscarToken](
	 @IDToken int =null
    ,@IDTipoToken int = null
    ,@Token Varchar(1000) = null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 d.IDToken    
		,d.IDTipoToken
		,tt.Descripcion TipoToken
		,UPPER(d.Nombre ) as Nombre
		,d.Token     
        ,isnull(d.Activo,0) as Activo
		,d.IDUsuario as IDUsuario
		,u.Cuenta
		,u.Nombre +' '+ u.Apellido as NombreCompleto
		,u.Email
		,u.IDPerfil
		,p.Descripcion as Perfil
	into #tempResponse
	FROM [Seguridad].[tblTokens] d with(nolock)   
		inner join [Seguridad].[tblCatTipoToken] TT with(nolock)
			on tt.IDTipoToken = d.IDTipoToken
		inner join [Seguridad].[tblUsuarios] u with(nolock)
			on u.IDUsuario = d.IDUsuario
		inner join [Seguridad].[tblCatPerfiles] p with(nolock)
			on u.IDPerfil = p.IDPerfil
	WHERE
		(d.IDToken = @IDToken or isnull(@IDToken,0) =0) 
		and (d.Token = @Token or ISNULL(@Token,'') = '')
		and (d.IDTipoToken = @IDTipoToken or ISNULL(@IDTipoToken,0) = 0)
		and (@query = '""' or contains(d.*, @query) or contains(u.*, @query) or  contains(p.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDToken) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,		
		Nombre asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

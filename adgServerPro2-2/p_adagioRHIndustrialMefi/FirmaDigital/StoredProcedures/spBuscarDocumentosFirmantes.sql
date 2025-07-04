USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [FirmaDigital].[spBuscarDocumentosFirmantes]
(
	 @ID Varchar(255) = null
	,@IDFirmante Varchar(255) = null
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Name'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int = null
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	    @TotalPaginas int = 0
	   ,@TotalRegistros int       
       ;	
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Name' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	SELECT     
		 d.ID
		,d.IDFirmante
		,d.Email
		,d.[Name]
		,d.TaxId
        ,d.AllowedSignatureMethods
		,isnull(d.Signed,0) as [Signed]        
		,d.WidgetID        
		,isnull(d.[Current],0) as [Current]
	into #tempResponse
	FROM [FirmaDigital].[tblDocumentosFirmantes] d with(nolock)  
	WHERE
		( 
              (d.ID = @ID or isnull(@ID,'') ='')
            AND (d.IDFirmante = @IDFirmante or isnull(@IDFirmante,'') ='')
        )  
		--and (@query = '""' or contains(d.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(ID) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Name'			and @orderDirection = 'asc'		then [Name] end,			
		case when @orderByColumn = 'Name'			and @orderDirection = 'desc'	then [Name] end desc,		
		[Name] asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

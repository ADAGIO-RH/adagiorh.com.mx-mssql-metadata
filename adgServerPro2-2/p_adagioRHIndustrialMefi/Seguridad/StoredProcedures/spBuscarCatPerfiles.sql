USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarCatPerfiles](
	@IDPerfil int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN

	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
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
	
	if object_id('tempdb..#tempPerfiles') is not null drop table #tempPerfiles;

	Select 
		IDPerfil
		,Descripcion
		,Activo 
		,ISNULL(p.AsignarTodosLosColaboradores, 0) as AsignarTodosLosColaboradores
		,ROW_NUMBER()over(ORDER BY IDPerfil) as ROWNUMBER
	into #tempPerfiles
	From Seguridad.tblCatPerfiles p
	Where ((p.IDPerfil = @IDPerfil) or (isnull(@IDPerfil,0) = 0))
		and (@query = '""' or contains(p.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempPerfiles

	select @TotalRegistros = cast(COUNT([IDPerfil]) as decimal(18,2)) from #tempPerfiles		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempPerfiles
	order by 
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

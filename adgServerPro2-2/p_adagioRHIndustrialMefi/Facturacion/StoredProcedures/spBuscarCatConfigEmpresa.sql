USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Facturacion].[spBuscarCatConfigEmpresa]  
(  
 @IDConfigEmpresa int = null 
 ,@IDEmpresa int = null
 ,@IDUsuario		int = null    
 ,@PageNumber	int = 1
 ,@PageSize		int = 2147483647
 ,@query			varchar(100) = '""'
 ,@orderByColumn	varchar(50) = 'RFC'
 ,@orderDirection varchar(4) = 'asc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'RFC' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
	
	IF OBJECT_ID('tempdb..#TempEmpresa') IS NOT NULL DROP TABLE #TempEmpresa  
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempEmpresa  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'RazonesSociales'  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  


	Select   
		CE.IDConfigEmpresa  
		,isnull(CE.IDEmpresa,0) as IDEmpresa  
		,E.RFC  
		,E.NombreComercial as Empresa  
		,CE.Usuario  
		,CE.Password  
		,CE.PasswordKey
		,CE.Token
		--,CE.CerStringBase64
		--,CE.KeyStringBase64
      
		into #tempResponse
	From Facturacion.tblCatConfigEmpresa CE  
		LEFT join RH.tblEmpresa E  
			on CE.IDEmpresa = E.IDEmpresa  
	WHERE (CE.IDConfigEmpresa = @IDConfigEmpresa) OR (ISNULL(@IDConfigEmpresa,0) = 0)
		and (CE.IDEmpresa = @IDEmpresa) OR (isnull(@IDEmpresa,0)= 0)
		and ((cE.IdEmpresa in  ( select ID from #TempEmpresa)) OR Not Exists(select ID from #TempEmpresa))  
		and (@query = '""' or contains(E.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDConfigEmpresa) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'RFC'			and @orderDirection = 'asc'		then RFC end,			
		case when @orderByColumn = 'RFC'			and @orderDirection = 'desc'	then RFC end desc,		
		RFC asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

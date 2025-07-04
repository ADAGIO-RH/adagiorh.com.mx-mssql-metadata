USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatDivisiones]    
(    
    @IDDivision int = null  
    ,@IDUsuario int = null      
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Codigo'
    ,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit =1
)    
AS    
BEGIN  
	SET FMTONLY OFF;

    declare  
	     @TotalPaginas int = 0
	    ,@TotalRegistros int = 0.00
	    ,@IDIdioma varchar(max)	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
			    IDDivision  int   
                ,Codigo  varchar(20)
                ,Descripcion  varchar(50)
                ,CuentaContable  varchar(25)
                ,IDEmpleado  int
                ,JefeDivision  varchar(100)
                ,Traduccion varchar(max)
                ,ROWNUMBER  int

    );

    

	IF OBJECT_ID('tempdb..#TempDivisiones') IS NOT NULL DROP TABLE #TempDivisiones;
    
	select ID   
	Into #TempDivisiones  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'Divisiones'  
    
    INSERT @tempResponse    
	Select    
		IDDivision    
		,Codigo    
		,UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion    
		,CuentaContable    
		,isnull(IDEmpleado,0) as IDEmpleado    
		,JefeDivision    
        ,Traduccion
		,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER    

	From RH.tblCatDivisiones  with(nolock)    
	where IDDivision = @IDDivision or @IDDivision is null    
		and (IDDivision in  ( select ID from #TempDivisiones)  
		OR Not Exists(select ID from #TempDivisiones) or @ValidarFiltros=0)  
		and (@query = '""' or contains(tblCatDivisiones.*, @query) )
	order by RH.tblCatDivisiones.Descripcion asc    


    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDDivision) as int) from @tempResponse		

	select *
		,TotalPages = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows=@TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,					
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

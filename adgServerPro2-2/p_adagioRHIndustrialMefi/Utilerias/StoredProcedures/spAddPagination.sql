USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-06-16
-- Description:	SP PARA AÑADIR PAGINACION
-- =============================================
CREATE PROCEDURE [Utilerias].[spAddPagination]
    
    @dtPagination [Nomina].[dtFiltrosRH] READONLY              
AS
BEGIN
        
    declare          
        @sqlCommand NVARCHAR(MAX)
	   ,@TotalPaginas int = 0
	   ,@TotalRegistros int = 0
       , @PageNumber	int = 1
       , @PageSize		int = 2147483647
	    
	    ,@orderByColumn	varchar(50) = 'ClaveRuta'
	    ,@orderDirection varchar(4) = 'asc';

    
    Select  @PageNumber=isnull(Value,1) from @dtPagination where Catalogo = 'PageNumber'
    Select  @PageSize=isnull(Value,2147483647) from @dtPagination where Catalogo = 'PageSize'    

    
    Select  @orderByColumn=isnull(Value,'CodigoVehiculo') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'

    select  @TotalRegistros = cast(COUNT(*) as int) from #tempSetPagination

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2))) from #tempSetPagination

    
    select *
            ,TotalPaginas = case when @totalPaginas = 0 then 1 else @totalPaginas end  
            ,@totalRegistros as TotalRows  
    from 	#tempSetPagination
    order by 
      row
							
    OFFSET @PageSize * (@PageNumber - 1)   ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE)


    /*
    
    SET @sqlCommand = 'select @totalRegistros = cast(COUNT(*) as int) from '+@NameTable;

    EXECUTE sp_executesql @sqlCommand, N'@totalRegistros int OUTPUT', @totalRegistros=@TotalRegistros OUTPUT
        

    SET @sqlCommand = 'select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2))) from  '+@NameTable;
    EXECUTE sp_executesql @sqlCommand, N'@totalPaginas int OUTPUT,@pageSize int', @totalPaginas=@TotalPaginas OUTPUT,@pageSize=@PageSize
	     
    
    SET @sqlCommand = 'select *
		                    ,TotalPaginas = case when @totalPaginas = 0 then 1 else @totalPaginas end  
                            ,@totalRegistros as TotalRows  
	                          from 	'+@NameTable+' 
                              order by  '+@orderByColumn+'  '+@orderDirection+'
                            OFFSET @pageSize * (@pageNumber - 1)   ROWS
                             FETCH NEXT @pageSize ROWS ONLY OPTION (RECOMPILE)'
    
    
    EXECUTE sp_executesql @sqlCommand, N'@totalRegistros int,@totalPaginas int, @pageNumber int, @pageSize int', 
        @totalRegistros=@TotalRegistros,
        @totalPaginas=@TotalPaginas ,
        @pageNumber=@PageNumber,
        @pageSize=@PageSize

    */



END
GO

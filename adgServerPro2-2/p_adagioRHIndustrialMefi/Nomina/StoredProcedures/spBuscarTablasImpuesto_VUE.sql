USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Nomina].[spBuscarTablasImpuesto_VUE]  (
     @IDTablaImpuesto int = 0
	 ,@Ejercicio int = 0
     ,@IDUsuario int =null
     ,@PageNumber	int = 1
     ,@PageSize		int = 2147483647
     ,@query			varchar(100) = '""'
     ,@orderByColumn	varchar(50) = 'Descripcion'
     ,@orderDirection varchar(4) = 'asc'
     ,@ValidarFiltros bit =1
) as
begin
    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int

        if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	    if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
        --SET @Ejercicio = CASE WHEN @Ejercicio = 0 THEN YEAR(GETDATE()) ELSE @Ejercicio END;
	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse ;
	
	
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'TablasImpuestos'  

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

    select tp.IDTablaImpuesto
	   ,tp.Ejercicio
	   ,tp.IDPeriodicidadPago
	   ,pp.Descripcion as PeriodicidadPago
	   ,tp.IDCalculo
	   ,tc.Descripcion as TipoCalculo
	   ,tp.Descripcion
	   ,ISNULL(tp.IDPais,0) as IDPais
	   ,P.Descripcion as Pais
       ,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY tp.Descripcion ASC) 
       	Into #TempResponse
    from Nomina.tblTablasImpuestos tp With(Nolock)
	   join Sat.tblCatPeriodicidadesPago pp With(Nolock) 
			on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago
	   join Nomina.tblCatTipoCalculoISR tc With(Nolock)  
			on tp.IDCalculo = tc.IDCalculo
	   left Join SAT.tblCatPaises P With(Nolock) 	
			on tp.IDPais = p.IDPais
    where (tp.IDTablaImpuesto = @IDTablaImpuesto or @IDTablaImpuesto = 0 )
		and (tp.Ejercicio = @Ejercicio or @Ejercicio = 0 )
        and (IDTablaImpuesto in (select ID from #TempFiltros)  
			OR Not Exists(select ID from #TempFiltros) or @ValidarFiltros=0)  
			and (@query = '""' or contains(tp.*, @query)) 
    order by tp.Ejercicio desc

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(@IDTablaImpuesto) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end;
GO

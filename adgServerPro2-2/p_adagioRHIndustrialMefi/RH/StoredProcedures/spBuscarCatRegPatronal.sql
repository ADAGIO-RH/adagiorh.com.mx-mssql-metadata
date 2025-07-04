USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  [RH].[spBuscarCatRegPatronal]@IDUsuario = 1
CREATE PROCEDURE [RH].[spBuscarCatRegPatronal](    
	  @IDRegPatronal int = 0    
	, @IDUsuario int = null  
	, @PageNumber	int = 1
	, @PageSize		int = 2147483647
	, @query			varchar(100) = '""'
	, @orderByColumn	varchar(50) = 'RazonSocial'
	, @orderDirection varchar(4) = 'asc'
	, @ValidarFiltros bit =1 
)    
AS    
BEGIN   
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
                    when @query = '""' then '""'
				else '"'+@query + '*"' end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'RazonSocial' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

    SET FMTONLY OFF;

	IF OBJECT_ID('tempdb..#TempRegPatronales') IS NOT NULL DROP TABLE #TempRegPatronales  
  	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID   
	Into #TempRegPatronales  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'RegPatronales'  

	SELECT     
		RP.IDRegPatronal    
		,RP.[RegistroPatronal]    
		,RP.RazonSocial    
		,RP.ActividadEconomica    
		,isnull(RP.IDClaseRiesgo,0) as IDClaseRiesgo    
		,'['+CR.Codigo+'] '+CR.Descripcion AS ClaseRiesgo    
		,isnull(RP.IDCodigoPostal,0) as IDCodigoPostal    
		,CP.CodigoPostal    
		,isnull(RP.IDEstado,0) as IDEstado    
		,'['+E.Codigo+'] '+E.NombreEstado as Estado    
		,isnull(RP.IDMunicipio,0) as IDMunicipio    
		,'['+M.Codigo+'] '+M.Descripcion as Municipio    
		,isnull(RP.IDColonia,0) as IDColonia    
		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia    
		,isnull(RP.IDPais,0) as IDPais    
		,'['+P.Codigo+'] '+P.Descripcion as Pais    
		,RP.Calle    
		,RP.Exterior    
		,RP.Interior    
		,RP.Telefono    
		,isnull(RP.ConvenioSubsidios,cast(0 as bit)) as ConvenioSubsidios    
		,RP.DelegacionIMSS    
		,RP.SubDelegacionIMSS    
		,RP.FechaAfiliacion    
		,RP.RepresentanteLegal    
		,RP.OcupacionRepLegal    
		,ROWNUMBER = ROW_NUMBER()OVER(ORDER BY RazonSocial ASC) 
			into #TempResponse
	FROM [RH].[tblCatRegPatronal] RP with(nolock)   
		LEFT join Sat.tblCatCodigosPostales CP with(nolock) on RP.IDCodigoPostal = CP.IDCodigoPostal    
		LEFT join Sat.tblCatPaises P with(nolock) on RP.IDPais = p.IDPais    
		LEFT join Sat.tblCatEstados E with(nolock) on RP.IDEstado = E.IDEstado    
		LEFT join Sat.tblCatMunicipios M with(nolock) on RP.IDMunicipio = m.IDMunicipio    
		LEFT join Sat.tblCatColonias CL with(nolock) on RP.IDColonia = CL.IDColonia    
		LEFT join IMSS.tblCatClaseRiesgo CR with(nolock) on CR.IDClaseRiesgo = RP.IDClaseRiesgo    
	WHERE 
		--  ((RP.IDRegPatronal = @IDRegPatronal) OR (ISNULL(@IDRegPatronal,0) = 0)) 
		----((RP.IDRegPatronal = @IDRegPatronal) or (@IDRegPatronal is null) or (@IDRegPatronal = 0))    
		--	and (
	 --               (RP.IDRegPatronal in (select ID from #TempRegPatronales) and @ValidarFiltros=1)  
		--		    OR ( @ValidarFiltros=0)
	 --           )  
		--	and (@query = '""' or contains(rp.*, @query)) 
	-- WHERE ((@IDRegPatronal = 0 AND @ValidarFiltros = 0) OR RP.IDRegPatronal = @IDRegPatronal)
    --   AND (RP.IDRegPatronal IN (SELECT ID FROM #TempRegPatronales) OR NOT EXISTS (SELECT ID FROM #TempRegPatronales) OR @ValidarFiltros = 0)
    --   AND (@query = '""' OR CONTAINS(RP.*, @query))
	((RP.IDRegPatronal = @IDRegPatronal) OR (ISNULL(@IDRegPatronal,0) = 0))
    AND (
        (RP.IDRegPatronal IN (SELECT ID FROM #TempRegPatronales) AND @ValidarFiltros = 1)
        OR (@ValidarFiltros = 0)
         OR NOT EXISTS (SELECT ID FROM #TempRegPatronales)
    )
	AND (@query = '""' OR CONTAINS(RP.*, @query))
	ORDER BY RP.[RazonSocial] ASC 
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDRegPatronal) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'RazonSocial'			and @orderDirection = 'asc'		then RazonSocial end,			
		case when @orderByColumn = 'RazonSocial'			and @orderDirection = 'desc'	then RazonSocial end desc,
		RazonSocial asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
      
END
GO

USE [p_adagioRHSimensGamesa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spBuscarContratoEmpleadoPagination]--20314    
(    
 @IDEmpleado int = null    
 ,@IDContratoEmpleado int = null
 ,@IDUsuario int = null    
 ,@PageNumber	int = 1
 ,@PageSize		int = 2147483647
 ,@query			varchar(100) = '""'
 ,@orderByColumn	varchar(50) = 'Descripcion'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end



	  Select     
		   CE.IDContratoEmpleado,    
		   CE.IDEmpleado,    
		   isnull(CE.IDTipoContrato,0) as IDTipoContrato,    
		   TC.Codigo,    
		   TC.Descripcion as TipoContrato,
		   isnull(CE.IDTipoTrabajador,0) as IDTipoTrabajador,     
		   isnull(tt.Descripcion,'') as TipoTrabajador,     
		   isnull(CE.IDDocumento,0) as IDDocumento,    
		   D.Descripcion ,    
		   cast(CE.FechaIni as date) as FechaIni,    
		   cast(CE.FechaFin as date) as FechaFin,    
		   isnull(ce.Duracion,0) as Duracion,    
		   ISNULL(ce.IDTipoDocumento,0) as IDTipoDocumento ,    
		   td.Descripcion as TipoDocumento,  
		   cast(isnull(d.EsContrato,0) as bit) as EsContrato
		   , ISNULL(CE.IDReferencia, 0) AS IDReferencia
		into #tempResponse
	  from RH.tblContratoEmpleado CE    
		LEft join Sat.tblCatTiposContrato TC    
			on CE.IDTipoContrato = TC.IDTipoContrato    
		LEft join RH.tblCatDocumentos D    
			on CE.IDDocumento = D.IDDocumento    
		LEft join RH.tblCatTipoDocumento td    
			on td.IDTipoDocumento = ce.IDTipoDocumento    
		left join IMSS.tblCatTipoTrabajador tt
			on tt.IDTipoTrabajador = ce.IDTipoTrabajador
	  WHERE CE.IDEmpleado = @IDEmpleado    
	   and ((ce.IDContratoEmpleado = @IDContratoEmpleado) or (@IDContratoEmpleado = 0 or @IDContratoEmpleado IS NULL))    
	   and ((@query = '""' or contains(d.*, @query)) OR
            (@query = '""' or contains(td.*, @query)) OR
            (@query = '""' or contains(tt.*, @query)) OR
            (@query = '""' or contains(tc.*, @query)) 

       ) 
	  ORDER BY CE.FechaIni Desc    

	 select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDContratoEmpleado) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,	
        case when @orderByColumn = 'FechaIni'			and @orderDirection = 'asc'		then FechaIni end,			
		case when @orderByColumn = 'FechaIni'			and @orderDirection = 'desc'	then FechaIni end desc,
		Codigo asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


    
END
GO

USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarCatReportesBasicosWP] (
	@IDReporteBasico int = 0
	,@IDAplicacion nvarchar(100) = null
	,@Personalizado bit = null
	,@IDUsuario int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query		varchar(max) = ''
) as

Declare @TotalPaginas int = 0 
            ,@TotalRegistros decimal(18,2) = 0.00 ;

 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCatReportesBasicosWP') is not null drop table #tempCatReportesBasicosWP;

	select IDReporteBasico
		  ,IDAplicacion
		  ,upper(Nombre)		as Nombre
		  ,upper(Descripcion)	as Descripcion
		  ,NombreReporte
		  ,ConfiguracionFiltros
		  ,Grupos
		  ,NombreProcedure
		  ,isnull(Personalizado,0) as Personalizado
		  ,ROW_NUMBER()OVER(ORDER BY IDReporteBasico ASC) as ROWNUMBER
    into #tempCatReportesBasicosWP
	from Reportes.tblCatReportesBasicos with (nolock)
	where (IDReporteBasico = @IDReporteBasico or ISNULL(@IDReporteBasico,0) = 0) 
	  and (IDAplicacion = @IDAplicacion or @IDAplicacion is null)
	  and (isnull(Personalizado,0) = @Personalizado or @Personalizado is null)
      and (coalesce(@query,'') = '' or coalesce(Nombre, '') like '%'+@query+'%')


	
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatReportesBasicosWP

	select @TotalRegistros = cast(COUNT([IDReporteBasico]) as decimal(18,2)) from #tempCatReportesBasicosWP		
	
    
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end

	from #tempCatReportesBasicosWP
		order by [IDAplicacion],[Nombre]  asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************       
** Descripción  : Procedimiento para Buscar los finiquitos por periodo      
** Autor   : Jose Roman      
** Email   : jose.roman@adagio.com.mx      
** FechaCreacion : 14-08-2018      
** Paremetros  :                    
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd)		Autor			Comentario      
------------------- ------------------- ------------------------------------------------------------      
2019-05-10				Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de   
										Seguridad.tblDetalleFiltrosEmpleadosUsuarios    
2024-06-16				Aneudy Abreu	Agrega paginación
***************************************************************************************************/      
-- exec [Nomina].[spBuscarFiniquitos] @IDPEriodo= 534 ,@IDUsuario = 1
CREATE PROCEDURE [Nomina].[spBuscarFiniquitos](       
	@IDFiniquito int = 0
	,@IDPeriodo int = 0
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'desc'
)      
AS      
BEGIN      
	DECLARE
		@IDIdioma varchar(20)
	   ,@TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	--select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
  
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaFinPago' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#tempFiniquitos') IS NOT NULL DROP TABLE #tempFiniquitos

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	select       
		CF.IDFiniquito,      
		ISNULL(CF.IDPeriodo,0) as IDPeriodo,      
		P.ClavePeriodo,      
		P.Descripcion as Periodo,      
		ISNULL(CF.IDEmpleado,0) as IDEmpleado,      
		E.ClaveEmpleado,      
		e.NOMBRECOMPLETO,      
		ISNULL(CF.FechaBaja,getdate())FechaBaja,      
		ISNULL(CF.FechaAntiguedad,getdate())FechaAntiguedad,      
		CF.DiasVacaciones,      
		CF.DiasAguinaldo,      
		CF.DiasIndemnizacion90Dias,      
		CF.DiasIndemnizacion20Dias,      
		ISNULL(CF.IDEStatusFiniquito,0) as IDEstatusFiniquito,      
		EF.Descripcion as EstatusFiniquito,
		isnull(DiasDePago,0.0) as DiasDePago,				
		isnull(DiasPorPrimaAntiguedad,0.0) as DiasPorPrimaAntiguedad,	
		isnull(SueldoFiniquito,0) as SueldoFiniquito,
		cast(case when ISNULL(CF.IDEStatusFiniquito,0) in(0,1) then 0 else 1 end as bit) as Aplicado,
		isnull(c.Codigo,'000') +' - '+ isnull(c.Descripcion,'SIN CONCEPTO')  as ConceptoPago,
		isnull(dp.ImporteTotal1,0.00) as ImporteTotal1,
		Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(CF.IDEmpleado,0) as UsuarioEmpleadoFotoAvatar,
		CF.IDMovAfiliatorio
	INTO #tempFiniquitos
	from Nomina.tblControlFiniquitos CF with (nolock)     
		Inner join Nomina.tblCatPeriodos P with (nolock)     on P.IDPeriodo = CF.IDPeriodo      
		Inner Join RH.tblEmpleadosMaster E with (nolock)     on CF.IDEmpleado = E.IDEmpleado      
		Inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario  
		Inner join Nomina.tblCatEstatusFiniquito EF on EF.IDEStatusFiniquito = CF.IDEStatusFiniquito 
		left join Nomina.tblDetallePeriodoFiniquito dp on dp.IDConcepto in(select IDConcepto from Nomina.tblCatConceptos where IDTipoConcepto = 5) and dp.IDEmpleado = cf.IDEmpleado and dp.IDPeriodo = cf.IDPeriodo and dp.ImporteTotal1 is not null
		left join Nomina.tblcatConceptos c on dp.IDConcepto = c.IDConcepto
	WHERE (CF.IDFiniquito = @IDFiniquito or isnull(@IDFiniquito, 0) = 0) 
		and (CF.IDPeriodo = @IDPeriodo or isnull(@IDPeriodo, 0) = 0)      
		and ( (@query = '""' or contains(p.*, @query)) OR
			(@query = '""' or contains(E.*, @query)) OR
			(@query = '""' or contains(c.*, @query))
		)
		
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempFiniquitos

	select @TotalRegistros = COUNT(IDFiniquito) from #tempFiniquitos		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempFiniquitos
	order by 
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc,	
		case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'asc'		then NombreCompleto end,			
		case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'desc'	then NombreCompleto end desc,	
		case when @orderByColumn = 'FechaBaja'			and @orderDirection = 'asc'		then FechaBaja end,			
		case when @orderByColumn = 'FechaBaja'			and @orderDirection = 'desc'	then FechaBaja end desc,
		case when @orderByColumn = 'ConceptoPago'			and @orderDirection = 'asc'		then ConceptoPago end,			
		case when @orderByColumn = 'ConceptoPago'			and @orderDirection = 'desc'	then ConceptoPago end desc,	
		case when @orderByColumn = 'ImporteTotal1'			and @orderDirection = 'asc'		then ImporteTotal1 end,			
		case when @orderByColumn = 'ImporteTotal1'			and @orderDirection = 'desc'	then ImporteTotal1 end desc,	
		case when @orderByColumn = 'EstatusFiniquito'			and @orderDirection = 'asc'		then EstatusFiniquito end,			
		case when @orderByColumn = 'EstatusFiniquito'			and @orderDirection = 'desc'	then EstatusFiniquito end desc,	
		case when @orderByColumn = 'Aplicado'			and @orderDirection = 'asc'		then Aplicado end,			
		case when @orderByColumn = 'Aplicado'			and @orderDirection = 'desc'	then Aplicado end desc,	
		ClaveEmpleado desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

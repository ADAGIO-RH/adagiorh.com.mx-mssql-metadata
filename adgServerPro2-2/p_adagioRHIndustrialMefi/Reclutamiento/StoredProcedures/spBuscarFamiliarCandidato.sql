USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de ExpedientesDigitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarFamiliarCandidato]
(
	@IDFamiliarCandidato int = 0
	,@IDCandidato int
	,@IDUsuario		int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaNacimientoFamiliar'
	,@orderDirection varchar(4) = 'desc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaInicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 


	if object_id('tempdb..#tempCandidatoFamiliares') is not null drop table #tempCandidatoFamiliares;

	set @query = case
                    when @query is null then '""'
                    when @query = '' then '""'
                    when @query =  '""' then '""'
                else '"'+@query + '*"' end

	SELECT Candidato.[IDFamiliarCandidato]
      ,Candidato.[IDCandidato]
      ,Candidato.[NombreFamiliar]
      ,Candidato.[FechaNacimientoFamiliar]
      ,isnull(Candidato.[Vivo],0) as [Vivo]
      ,isnull(Candidato.[IDParentesco],0)as [IDParentesco]
	  ,JSON_VALUE(Parentescos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as [NombreParentesco]
	  ,ROW_NUMBER()over(ORDER BY [IDFamiliarCandidato])as ROWNUMBER
	  INTO #tempCandidatoFamiliares
  FROM [Reclutamiento].[tblFamiliaresCandidato] Candidato
  join [RH].[TblCatParentescos] Parentescos on  Candidato.IDParentesco = Parentescos.IDParentesco
  	  WHERE (Candidato.[IDFamiliarCandidato] = @IDFamiliarCandidato OR isnull(@IDFamiliarCandidato,0) = 0)
	  and (Candidato.IDCandidato = @IDCandidato or ISNULL(@IDCandidato,0) = 0)
	  and (@query = '""' OR contains([Candidato].*,@query))

	  select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCandidatoFamiliares

	select @TotalRegistros = cast(COUNT([IDFamiliarCandidato]) as decimal(18,2)) from #tempCandidatoFamiliares		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempCandidatoFamiliares
	order by 
		case when @orderByColumn = 'FechaNacimientoFamiliar'			and @orderDirection = 'asc'		then FechaNacimientoFamiliar end,			
		case when @orderByColumn = 'FechaNacimientoFamiliar'			and @orderDirection = 'desc'	then FechaNacimientoFamiliar end desc,		
		FechaNacimientoFamiliar desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

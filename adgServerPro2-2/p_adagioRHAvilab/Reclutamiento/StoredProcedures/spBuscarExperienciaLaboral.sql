USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spBuscarExperienciaLaboral] --@IDCandidato =76
(
    @IDCandidato int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(500) = ''
	,@IDUsuario		int = 0
)
AS 
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCandidatosTable') is not null drop table #tempCandidatosTable;

	set @query = case
                    when @query is null then '""'
                    when @query = '' then '""'
                    when @query =  '""' then '""'
                else '"'+@query + '*"' end

	SELECT 
		 [EXP].[IDExperienciaLaboral] 
		,[Candidato].[IDCandidato]  as [IDCandidato]
        ,[EXP].[NombreEmpresa]
        ,[EXP].[Cargo]
        ,[EXP].[FechaInicio]
        ,[EXP].[FechaFin]
        ,[EXP].[Descripcion]
        ,[EXP].[Logros]
        ,[EXP].[Proyectos]
        ,[EXP].[Habilidades]
		,isnull([EXP].[IDPais],0) as IDPais
        ,isnull([EXP].[IDEstado],0) as IDEstado
        ,isnull([EXP].[IDMunicipio],0) as IDMunicipio
        ,[EXP].[TrabajoActual]
        ,isnull([EXP].[IDTipoTrabajo],0) as IDTipoTrabajo
        ,isnull([EXP].[IDModalidadTrabajo],0) as IDModalidadTrabajo
	into #tempCandidatosTable
	FROM [Reclutamiento].[tblExperienciaLaboral] EXP
        INNER JOIN [Reclutamiento].[tblCandidatos] Candidato  on EXP.IDCandidato = Candidato.IDCandidato
		LEFT JOIN [SAT].[tblCatPaises] paises with(nolock) on EXP.IDPais = paises.IDPais
		LEFT JOIN [SAT].[tblCatEstados] estados with(nolock) on EXP.IDEstado = estados.IDEstado
		LEFT JOIN [SAT].[tblCatMunicipios] Municipios with(nolock) on EXP.IDMunicipio = Municipios.IDMunicipio
	WHERE (EXP.[IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)
		and (@query = '""' OR contains(EXP.*,@query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCandidatosTable

	select @TotalRegistros = cast(COUNT([IDCandidato]) as decimal(18,2)) from #tempCandidatosTable		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCandidatosTable
		order by NombreEmpresa asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

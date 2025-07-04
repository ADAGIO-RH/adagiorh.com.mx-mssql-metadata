USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spBuscarExperienciaLaboral] --@IDCandidato =76
(
    @IDCandidato int = 0
	,@IDExperienciaLaboral int = 0
	,@IDUsuario		int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaInicio'
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
		,paises.Descripcion as Pais
        ,isnull([EXP].[IDEstado],0) as IDEstado
		,estados.NombreEstado as Estado
        ,isnull([EXP].[IDMunicipio],0) as IDMunicipio
		,Municipios.Descripcion as Municipio
        ,[EXP].[TrabajoActual]
        ,isnull([EXP].[IDTipoTrabajo],0) as IDTipoTrabajo
		,ISNULL(tipotrabajo.Descripcion,'SIN ASIGNACIÓN') as TipoTrabajo
        ,isnull([EXP].[IDModalidadTrabajo],0) as IDModalidadTrabajo
		,ISNULL(modalidad.Descripcion,'SIN ASIGNACIÓN') as ModalidadTrabajo
	into #tempExperienciaLaboral
	FROM [Reclutamiento].[tblExperienciaLaboral] [EXP]
        INNER JOIN [Reclutamiento].[tblCandidatos] Candidato  on [EXP].IDCandidato = Candidato.IDCandidato
		LEFT JOIN [SAT].[tblCatPaises] paises with(nolock) on [EXP].IDPais = paises.IDPais
		LEFT JOIN [SAT].[tblCatEstados] estados with(nolock) on [EXP].IDEstado = estados.IDEstado
		LEFT JOIN [SAT].[tblCatMunicipios] Municipios with(nolock) on [EXP].IDMunicipio = Municipios.IDMunicipio
		LEFT JOIN [Reclutamiento].[tblCatTipoTrabajo] tipotrabajo with(nolock) on tipotrabajo.IDTipoTrabajo = [EXP].IDTipoTrabajo
		LEFT JOIN [Reclutamiento].[tblCatModalidadTrabajo] modalidad with(nolock) on modalidad.IDModalidadTrabajo = [EXP].IDModalidadTrabajo
	WHERE ([EXP].[IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)
		and ([EXP].[IDExperienciaLaboral] = @IDExperienciaLaboral OR ISNULL(@IDExperienciaLaboral,0) = 0)
		and (@query = '""' OR contains([EXP].*,@query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempExperienciaLaboral

	select @TotalRegistros = cast(COUNT([IDExperienciaLaboral]) as decimal(18,2)) from #tempExperienciaLaboral		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempExperienciaLaboral
	order by 
		case when @orderByColumn = 'FechaInicio'			and @orderDirection = 'asc'		then FechaInicio end,			
		case when @orderByColumn = 'FechaInicio'			and @orderDirection = 'desc'	then FechaInicio end desc,		
		FechaInicio desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

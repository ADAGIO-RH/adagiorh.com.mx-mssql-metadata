USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spBuscarCandidatosPagination]
(
 @IDUsuario		int
,@PageNumber	int = 1
,@PageSize		int = 2147483647
,@query		varchar(max) = ''
)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCandidatosTable') is not null drop table #tempCandidatosTable;


	SELECT 

		 [Candidato].[IDCandidato]  as [IDCandidato]
		,[Nombre]
		,[SegundoNombre]
		,[Paterno]
		,[Materno]
		,[Sexo]
		,[FechaNacimiento]		
		,ISNULL(CandidatosProceso.[VacanteDeseada],'') as [VacanteDeseada]
		,ISNULL(CandidatosProceso.[SueldoDeseado],'') as [SueldoDeseado]
		,ISNULL(CandidatosProceso.[SueldoPreasignado],'') as [SueldoPreasignado]
        ,ISNULL(Puestos.Descripcion,'N/A') as [PuestoPreasignado]
		,ISNULL(EstatusProceso.Descripcion,'SIN ESTATUS') as [EstatusProceso]
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER
	INTO #tempCandidatosTable
	FROM [Reclutamiento].[tblCandidatos] Candidato
	LEFT JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON CandidatO.IDCandidato = CandidatosProceso.IDCandidato
    LEFT JOIN [RH].[tblCatPuestos] Puestos on CandidatosProceso.IDPuestoPreasignado = Puestos.IDPuesto
	LEFT JOIN [Reclutamiento].[tblCatEstatusProceso] EstatusProceso on CandidatosProceso.IDEstatusProceso = EstatusProceso.IDEstatusProceso
	LEFT JOIN [Reclutamiento].[tblDireccionResidenciaCandidato] DireccionCandidato on Candidato.IDCandidato = DireccionCandidato.IDCandidato
    LEFT JOIN sat.tblCatCodigosPostales as cp on cp.IDCodigoPostal=DireccionCandidato.IDCodigoPostal

	  		and (coalesce(@query,'') = '' or coalesce([Candidato].Nombre, '')+' '+coalesce([Candidato].SegundoNombre, '')
              +' '+coalesce([Candidato].Paterno, '') 
              +' '+coalesce([Candidato].Materno, '')
              +' '+coalesce(CandidatosProceso.[VacanteDeseada], '')
              like '%'+@query+'%')


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCandidatosTable

	select @TotalRegistros = cast(COUNT([IDCandidato]) as decimal(18,2)) from #tempCandidatosTable		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCandidatosTable
		order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

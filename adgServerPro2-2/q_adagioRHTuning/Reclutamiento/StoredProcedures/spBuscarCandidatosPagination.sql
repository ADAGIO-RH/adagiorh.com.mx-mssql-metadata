USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spBuscarCandidatosPagination](
	 @IDUsuario		int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query		varchar(max) = ''
)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
		,@IDTipoCatalogo int = 7 -- Tipos de medios de reclutamiento
	;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCandidatosTable') is not null drop table #tempCandidatosTable;

	SELECT 
		 [Candidato].[IDCandidato]  as [IDCandidato]
		,Candidato.[Nombre]
		,Candidato.[SegundoNombre]
		,Candidato.[Paterno]
		,Candidato.[Materno]
		,Candidato.[Sexo]
		,Candidato.[FechaNacimiento]		
		,ISNULL(CandidatosProceso.[VacanteDeseada],'') as [VacanteDeseada]
		,ISNULL(CandidatosProceso.[SueldoDeseado],'') as [SueldoDeseado]
		,ISNULL(CandidatosProceso.[SueldoPreasignado],'') as [SueldoPreasignado]
        ,ISNULL(Puestos.Descripcion,'N/A') as [PuestoPreasignado]
		,ISNULL(EstatusProceso.Descripcion,'SIN ESTATUS') as [EstatusProceso]
		,ISNULL(candidato.IDMedioReclutamiento, 0)  as IDMedioReclutamiento
		,tiposMedios.Catalogo as TipoMedioReclutamiento
		,ISNULL(mr.Nombre, 'SIN MEDIO DE RECLUTAMIENTO')  as MedioReclutamiento
		,ROW_NUMBER()over(ORDER BY Candidato.[IDCandidato])as ROWNUMBER
	INTO #tempCandidatosTable
	FROM [Reclutamiento].[tblCandidatos] Candidato
		LEFT JOIN [Reclutamiento].[tblCandidatosProceso] CandidatosProceso ON CandidatO.IDCandidato = CandidatosProceso.IDCandidato
		LEFT JOIN [RH].[tblCatPuestos] Puestos on CandidatosProceso.IDPuestoPreasignado = Puestos.IDPuesto
		LEFT JOIN [Reclutamiento].[tblCatEstatusProceso] EstatusProceso on CandidatosProceso.IDEstatusProceso = EstatusProceso.IDEstatusProceso
		LEFT JOIN [Reclutamiento].[tblDireccionResidenciaCandidato] DireccionCandidato on Candidato.IDCandidato = DireccionCandidato.IDCandidato
		LEFT JOIN sat.tblCatCodigosPostales as cp on cp.IDCodigoPostal=DireccionCandidato.IDCodigoPostal
		LEFT JOIN [Reclutamiento].[tblMediosReclutamiento] mr on mr.IDMedioReclutamiento = candidato.IDMedioReclutamiento
		left join (
			select * 
			from App.tblCatalogosGenerales cg
			where IDTipoCatalogo = @IDTipoCatalogo
		) tiposMedios on tiposMedios.IDCatalogoGeneral = mr.IDTipoMedioReclutamiento

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

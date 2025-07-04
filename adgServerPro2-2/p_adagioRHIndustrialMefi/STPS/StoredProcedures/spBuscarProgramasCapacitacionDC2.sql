USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [STPS].[spBuscarProgramasCapacitacionDC2](
	@IDProgramaCapacitacion int = null  
	,@IDUsuario int = null     
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Empresa'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int, 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Empresa' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end
	IF OBJECT_ID('tempdb..#TempProgramas') IS NOT NULL DROP TABLE #TempProgramas

	SELECT     
		 P.IDProgramaCapacitacion
		,ISNULL(P.IDEmpresa ,0) IDEmpresa
		,E.NombreComercial as Empresa
		,E.RFC as RFCEmpresa
		,ISNULL(P.IDRegPatronal ,0) as IDRegPatronal
		,RegPatronal.RegistroPatronal 
		,RegPatronal.RazonSocial 
		,RegPatronal.ActividadEconomica 
		,RegPatronal.Telefono 
		,P.Email
		,P.Fax 
		,ISNULL(P.QtyTrabajadoresConsiderados ,0) as QtyTrabajadoresConsiderados
		,ISNULL(P.Mujeres,0) as Mujeres
		,ISNULL(P.Hombres,0) as Hombres
		,ISNULL(P.ObjetivoActualizar,0) as ObjetivoActualizar
		,ISNULL(P.ObjetivoPrevenir   ,0) as 	ObjetivoPrevenir   
		,ISNULL(P.ObjetivoIncrementar,0) as 	ObjetivoIncrementar
		,ISNULL(P.ObjetivoMejorar 	 ,0) as 	ObjetivoMejorar 	 
		,ISNULL(P.ObjetivoPreparar 	 ,0) as 	ObjetivoPreparar 	 
		,ISNULL(P.ModalidadEspecificos ,0) as ModalidadEspecificos
		,isnull(P.ModalidadComunes		 ,0) as ModalidadComunes
		,isnull(P.ModalidadGeneral		 ,0) as ModalidadGeneral
		,isnull(P.NumeroEstablecimientos ,0) as NumeroEstablecimientos
		,isnull(P.NumeroEtapas			 ,0) as NumeroEtapas
		,CAST(P.FechaInicio as DATE) as FechaInicio
		,CAST(P.FechaFin as DATE) as FechaFin
		,P.RegPatronalesAdicionales
		,P.RepresentanteLegal
		,CAST(P.FechaElaboracion as DATE) as FechaElaboracion
		,P.LugarElaboracion 
	into #TempProgramas
	FROM [STPS].[tblProgramasCapacitacionDC2] p with (nolock)    
		left join RH.tblEmpresa E with (nolock) on P.IDEmpresa = e.IDEmpresa
		left join RH.tblCatRegPatronal RegPatronal with (nolock) on  RegPatronal.IDRegPatronal = p.IDRegPatronal
		left join SAT.tblCatCodigosPostales cp with(nolock) on cp.IDCodigoPostal = RegPatronal.IDCodigoPostal
		left join SAT.tblCatEstados Estado with(nolock) on Estado.IDEstado = RegPatronal.IDEstado
		left join SAT.tblCatMunicipios Municipio with(nolock) on Municipio.IDMunicipio = RegPatronal.IDMunicipio
	WHERE ( P.IDProgramaCapacitacion = @IDProgramaCapacitacion or isnull(@IDProgramaCapacitacion,0) = 0)    
		and (@query = '""' or contains(E.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempProgramas

	select @TotalRegistros = cast(COUNT([IDProgramaCapacitacion]) as decimal(18,2)) from #TempProgramas		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempProgramas
	order by 	
		case when @orderByColumn = 'Empresa'			and @orderDirection = 'asc'		then Empresa end,			
			case when @orderByColumn = 'Empresa'			and @orderDirection = 'desc'	then Empresa end desc,		
			Empresa asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

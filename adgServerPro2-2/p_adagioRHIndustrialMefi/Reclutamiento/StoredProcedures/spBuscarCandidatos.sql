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
-- exec  [Reclutamiento].[spBuscarCandidatos]@IDUsuario=1
CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatos]
(
	@IDCandidato int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(500) = ''
	,@IDUsuario		int
)
AS
BEGIN

	DECLARE @IDDocumentoTrabajoPasaporte INT;

	SELECT @IDDocumentoTrabajoPasaporte = IDDocumentoTrabajo
	FROM [Reclutamiento].[tblCatDocumentosTrabajo]
	WHERE [Descripcion] = 'PASAPORTE'

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
				else '"'+@query + '*"' end

	SELECT 
		 [Candidato].[IDCandidato]  as [IDCandidato]
		,[Candidato].[Nombre]
		,[Candidato].[SegundoNombre]
		,[Candidato].[Paterno]
		,[Candidato].[Materno]
		,[Candidato].[Sexo]
		,[Candidato].[FechaNacimiento]
		,isnull([Candidato].[IDPaisNacimiento],0 ) as [IDPaisNacimiento]
		,[paisesNacimiento].Descripcion as [PaisNacimiento]
		,isnull([Candidato].[IDEstadoNacimiento], 0) as [IDEstadoNacimiento]
		,[EstadosNacimiento].NombreEstado as [EstadoNacimiento]
		,isnull([Candidato].[IDMunicipioNacimiento], 0) as [IDMunicipioNacimiento]
		,[MunicipioNacimiento].Descripcion as [MunicipioNacimiento]
		,isnull([Candidato].[IDLocalidadNacimiento], 0) as [IDLocalidadNacimiento]
		,[Candidato].[RFC]
		,[Candidato].[CURP]
		,[Candidato].[NSS]
		,CAST(isnull([Candidato].[IDAfore],0)as int) as IDAfore
		,isnull([Afores].[Descripcion],'SIN SELECCIÓN') as Afore
		,isnull([Candidato].[IDEstadoCivil],0) as IDEstadoCivil
		,isnull([EstadosCiviles].[Descripcion],'SIN SELECCIÓN') as EstadoCivil
		,isnull([Candidato].[Estatura] ,0.00) as [Estatura]
		,isnull([Candidato].[Peso]	   ,0.00) as [Peso]
		,[Candidato].[TipoSangre]
		,isnull([Candidato].[Extranjero], 0) as [Extranjero]
		,ISNULL(Pasaporte.Validacion,'') as [NumeroPasaporte]
		,ISNULL(TelCelular.Value,'') as [TelefonoCelular]
		,ISNULL(TelFijo.Value,'') as [TelefonoFijo]
		,ISNULL(CorreoElectronico.Value,'') as [CorreoElectronico]
		,Pasaporte.Validacion as [NumPasaporte]
		,ISNULL(DireccionCandidato.IDPais,0)	as [IDPaisResidencia]
		,PaisesResidencia.Descripcion as [PaisResidencia]
		,ISNULL(DireccionCandidato.IDEstado,0)	as [IDEstadoResidencia]
		,EstadoResidencia.NombreEstado as [EstadoResidencia]
		,ISNULL(DireccionCandidato.IDMunicipio,0)	as [IDMunicipioResidencia]
		,MunicipioResidencia.Descripcion as [MunicipioResidencia]
		,ISNULL(DireccionCandidato.IDLocalidad,0)	as [IDLocalidadResidencia]
		,ISNULL(DireccionCandidato.IDCodigoPostal,0)as [IDCodigoPostalResidencia]
		,cp.CodigoPostal as CodigoPostalResidencia
		,ISNULL(DireccionCandidato.IDColonia,0)	as [IDColoniaResidencia]
		,ColoniaResidencia.NombreAsentamiento as ColoniaResidencia
		,ISNULL(DireccionCandidato.Calle,'') as [CalleResidencia]
		,ISNULL(DireccionCandidato.NumExt,'')	as [NumeroExtResidencia]
		,ISNULL(DireccionCandidato.NumInt,'') as [NumeroIntResidencia]
        ,isnull(Candidato.IDEmpleado,0) as [IDEmpleado]
	into #tempCandidatosTable
	FROM [Reclutamiento].[tblCandidatos] Candidato
		LEFT JOIN [SAT].[tblCatPaises] paisesNacimiento with(nolock) on Candidato.IDPaisNacimiento = paisesNacimiento.IDPais
		LEFT JOIN [SAT].[tblCatEstados] EstadosNacimiento with(nolock) on Candidato.IDEstadoNacimiento = EstadosNacimiento.IDEstado
		LEFT JOIN [SAT].[tblCatMunicipios] MunicipioNacimiento with(nolock) on Candidato.IDMunicipioNacimiento = MunicipioNacimiento.IDMunicipio
		LEFT JOIN [RH].[tblCatAfores] Afores with(nolock) on Candidato.IDAFORE = Afores.IDAfore
		LEFT JOIN [RH].[tblCatEstadosCiviles] EstadosCiviles with(nolock) on Candidato.IDEstadoCivil = EstadosCiviles.IDEstadoCivil
		LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelCelular with(nolock) ON Candidato.IDCandidato = TelCelular.IDCandidato and TelCelular.IDTipoContacto = 1
		LEFT JOIN [Reclutamiento].[tblContactoCandidato] TelFijo with(nolock) ON Candidato.IDCandidato = TelFijo.IDCandidato and TelFijo.IDTipoContacto = 2
		LEFT JOIN [Reclutamiento].[tblContactoCandidato] CorreoElectronico with(nolock) ON Candidato.IDCandidato = CorreoElectronico.IDCandidato and CorreoElectronico.IDTipoContacto = 3
		LEFT JOIN [Reclutamiento].[tblDocumentosTrabajoCandidato] Pasaporte with(nolock) on Candidato.IDCandidato = Pasaporte.IDCandidato and Pasaporte.IDDocumentoTrabajo =  @IDDocumentoTrabajoPasaporte
		LEFT JOIN [Reclutamiento].[tblDireccionResidenciaCandidato] DireccionCandidato with(nolock) on Candidato.IDCandidato = DireccionCandidato.IDCandidato
		LEFT JOIN [SAT].[tblCatCodigosPostales] as cp with(nolock) on cp.IDCodigoPostal=DireccionCandidato.IDCodigoPostal
		LEFT JOIN [SAT].[tblCatPaises] as PaisesResidencia with(nolock) on PaisesResidencia.IDPais=DireccionCandidato.IDPais
		LEFT JOIN [SAT].[tblCatEstados] as EstadoResidencia with(nolock) on EstadoResidencia.IDEstado=DireccionCandidato.IDEstado
		LEFT JOIN [SAT].[tblCatMunicipios] as MunicipioResidencia with(nolock) on MunicipioResidencia.IDMunicipio=DireccionCandidato.IDMunicipio
		LEFT JOIN [SAT].[tblCatColonias] as ColoniaResidencia with(nolock) on ColoniaResidencia.IDColonia=DireccionCandidato.IDColonia
	WHERE (Candidato.[IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)
		and (@query = '""' OR contains(Candidato.*,@query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCandidatosTable

	select @TotalRegistros = cast(COUNT([IDCandidato]) as decimal(18,2)) from #tempCandidatosTable		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCandidatosTable
		order by Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

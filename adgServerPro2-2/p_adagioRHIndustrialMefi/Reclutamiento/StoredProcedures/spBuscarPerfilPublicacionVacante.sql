USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las vacantes disponibles para que los candidatos puedan aplicar
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2023-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)		Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-01-23				ANEUDY ABREU		feat: Agrega el municipio al campo Estado
2014-03-12				ANEUDY ABREU		fix: Agrega condición para que solo retorne Perfiles que 
											tengan al menos 1 Vacante disponible
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarPerfilPublicacionVacante](
	 @IDPerfilPublicacionVacante	int = 0
	,@IDPlaza	int = null
	,@VacantePCD bit = null
	,@IDTipoTrabajo int = null
	,@IDModalidadTrabajo int = null
	,@IDTipoContrato int = null
	,@UUID Varchar(255) = null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@IDIdioma varchar(20)
	;
 	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 perfil.IDPerfilPublicacionVacante
		,perfil.IDPlaza
		,plazas.Codigo	
		,JSON_VALUE(puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,perfil.IDModalidadTrabajo
		,Modalidad.Descripcion as ModalidadTrabajo
		,perfil.IDTipoTrabajo 
		,TipoTrabajo.Descripcion as TipoTrabajo
		,perfil.IDTipoContrato
		,TipoContrato.Descripcion as TipoContrato
		,isnull(perfil.OcultarSalario,0) as OcultarSalario
		,Perfil.DescripcionVacante
		,perfil.LinkVideo
		,perfil.Beneficios
		,perfil.Tags
		,isnull(perfil.VacantePCD,0) as VacantePCD
		,perfil.EdadMinima
		,perfil.EdadMaxima
		,perfil.IDGenero as IDGenero
		,JSON_VALUE(Genero.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Genero 
		,isnull(perfil.AniosExperiencia,0) as AniosExperiencia
		,isnull(perfil.IDEstudio,0) IDEstudio
		,Estudios.Descripcion as Estudio
		,perfil.FormacionComplementarioa
		,perfil.Idiomas
		,perfil.Habilidades as Habilidades					
		,isnull(perfil.LicenciaConducir				,0)as LicenciaConducir				
		,isnull(perfil.DisponibilidadViajar			,0)as DisponibilidadViajar			
		,isnull(perfil.VehiculoPropio				,0)as VehiculoPropio				
		,isnull(perfil.DisponibilidadCambioVivienda	,0)as DisponibilidadCambioVivienda	
		,isnull(perfil.IncluirPreguntasFiltro  		,0)as IncluirPreguntasFiltro 
		,paises.Descripcion as Pais
		,coalesce(municipios.Descripcion, '')+' '+coalesce(estados.NombreEstado,'') as Estado
		,municipios.Descripcion as Municipio
		,isnull(salarial.Minimo,0)as SalarioMinimo
		,isnull(salarial.Maximo,0)as SalarioMaximo
		,isnull(Plazas.PosicionesDisponibles,0) as PosicionesDisponibles
		,isnull(Perfil.UUID,'') as UUID
	into #tempResponse
	FROM [Reclutamiento].[tblPerfilPublicacionVacante] perfil with(nolock)   
		inner join [RH].[tblCatPlazas] plazas with(nolock) on perfil.IDPlaza = plazas.IDPlaza
		inner join [RH].[TblcatPuestos] puestos with(nolock) on puestos.IDPuesto = Plazas.IDPuesto
		LEFT JOIN RH.[tblCatNivelesEmpresariales] catNivelesEmpresariales with(nolock) on catNivelesEmpresariales.IDNivelEmpresarial = plazas.IDNivelEmpresarial
		left join [Reclutamiento].[tblCatModalidadTrabajo] as Modalidad with(nolock) on perfil.IDModalidadTrabajo = modalidad.IDModalidadTrabajo
		left join [Reclutamiento].[tblCatTipoTrabajo] as TipoTrabajo with(nolock) on perfil.IDTipoTrabajo = TipoTrabajo.IDTipoTrabajo
		left join [SAT].[tblCatTiposContrato] as TipoContrato with(nolock) on perfil.IDTipoContrato = TipoContrato.IDTipoContrato
		left join [STPS].[tblCatEstudios] as Estudios with(nolock) on perfil.IDEstudio = Estudios.IDEstudio
		left join [RH].[tblCatGeneros] as genero with(nolock) on perfil.IDGenero = genero.IDGenero
		Cross Apply RH.fnGetConfiguracionPlaza(plazas.Configuraciones,'Sucursal') as configSucursal
		left join RH.tblcatSucursales sucursales with(nolock) on sucursales.IDSucursal = configSucursal.Valor
		left join Sat.tblCatPaises paises with(nolock) on sucursales.IDPais = paises.IDPais
		left join Sat.tblCatEstados estados with(nolock) on estados.IDEstado = sucursales.IDEstado
		left join Sat.tblCatMunicipios municipios with(nolock) on municipios.IDMunicipio = sucursales.IDMunicipio
		left join [RH].[tblTabuladorSalarial] salarial with(nolock) on salarial.IDNivelSalarial = plazas.IDNivelSalarial
	WHERE
		(perfil.IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante or isnull(@IDPerfilPublicacionVacante,0) =0)  
		and (perfil.IDPlaza = @IDPlaza or isnull(@IDPlaza,0) =0)  
		and (perfil.IDModalidadTrabajo = @IDModalidadTrabajo or isnull(@IDModalidadTrabajo,0) =0)  
		and (perfil.IDTipoTrabajo = @IDTipoTrabajo or isnull(@IDTipoTrabajo,0) =0)  
		and (perfil.IDTipoContrato = @IDTipoContrato or isnull(@IDTipoContrato,0) =0)  
		and (perfil.VacantePCD = @VacantePCD or (@VacantePCD is null))
		and (perfil.UUID = @UUID or (isnull(@UUID,'')=''))
		and (@query = '""' 
			or contains(perfil.*, @query)
			or contains(plazas.*, @query)
			or contains(puestos.*, @query)
			or contains(Modalidad.*, @query)
			or contains(TipoTrabajo.*, @query)
		) 
		and isnull(Plazas.PosicionesDisponibles,0) > 0
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDPerfilPublicacionVacante) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,		
		Codigo asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

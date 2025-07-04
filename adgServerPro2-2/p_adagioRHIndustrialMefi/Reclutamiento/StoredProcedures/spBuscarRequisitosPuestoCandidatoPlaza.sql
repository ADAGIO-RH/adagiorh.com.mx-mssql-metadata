USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JOSE ROMAN
-- Create date: 2022-06-29
-- Description:	Resultados Capturados por Candidato plaza
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarRequisitosPuestoCandidatoPlaza](
	@IDResultadosCandidatoPlaza int = 0
	,@IDCandidatoPlaza int = 0
	,@IDTipoCaracteristica int = 0
	,@IDPlaza int = 0
	,@IDPuesto int = 0
	,@IDRequisitoPuesto int = 0
	,@IDCandidato int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDRequisitoPuesto'
	,@orderDirection varchar(4) = 'asc'
) AS
BEGIN

	declare  @tblResultadosCandidatoPlaza table(
		IDResultadosCandidatoPlaza int
		,IDCandidatoPlaza int
		,IDCandidato int
		,Candidato Varchar(255)
		,IDPlaza int
		,IDPuesto int
		,Puesto Varchar(255)
		,IDRequisitoPuesto int
		,Requisito Varchar(500)
		,IDTipoCaracteristica int
		,TipoCaracteristica Varchar(500)
		,TipoValor Varchar(50)
		,ValorEsperado varchar(max)
		,Resultado varchar(max)
		,FechaAplicacion Date
		,[Data] varchar(max)
	) 
	declare  @TotalPaginas int = 0
		 ,@TotalRegistros decimal(18,2) = 0.00
		 ,@IDIdioma varchar(20)	;

select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
					
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query end

	insert  @tblResultadosCandidatoPlaza 
	SELECT 
		ISNULL(resultado.IDResultadosCandidatoPlaza,0) as IDResultadosCandidatoPlaza
		,ISNULL(CandidatoPlaza.IDCandidatoPlaza,0) as IDCandidatoPlaza
		,ISNULL(Candidatos.IDCandidato,0) as IDCandidato
		,SUBSTRING(UPPER(COALESCE(Candidatos.Paterno,'')+' '+COALESCE(Candidatos.Materno,'')+' '+COALESCE(Candidatos.Nombre,'')+' '+COALESCE(Candidatos.SegundoNombre,'')),1,49 )	Candidato
		,ISNULL(Plazas.IDPlaza,0) as IDPlaza
		,ISNULL(Puestos.IDPuesto,0) as IDPuesto
		,JSON_VALUE(Puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto
		,ISNULL(RequisitosPuestos.IDRequisitoPuesto,0) as IDRequisitoPuesto
		,RequisitosPuestos.Requisito as Requisito
		,ISNULL(RequisitosPuestos.IDTipoCaracteristica,0) as IDTipoCaracteristica
		,JSON_VALUE(TipoCaracteristica.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS TipoCaracteristica
		,RequisitosPuestos.TipoValor
		,RequisitosPuestos.ValorEsperado
		,resultado.resultado
		,resultado.FechaAplicacion
		,RequisitosPuestos.[Data]
	FROM Reclutamiento.tblCandidatos Candidatos with(nolock)
		inner join Reclutamiento.tblCandidatoPlaza CandidatoPlaza with(nolock) on Candidatos.IDCandidato = CandidatoPlaza.IDCandidato
		inner join RH.tblCatPlazas Plazas with(nolock) on Plazas.IDPlaza = CandidatoPlaza.IDPlaza
		inner join RH.tblCatPuestos Puestos with(nolock) on Puestos.IDPuesto = Plazas.IDPuesto
		inner join RH.tblRequisitosPuestos RequisitosPuestos with(nolock) on RequisitosPuestos.IDPuesto = Puestos.IDPuesto
			and RequisitosPuestos.Activo = 1
		inner join RH.tblCatTiposCaracteristicas TipoCaracteristica with(nolock) on TipoCaracteristica.IDTipoCaracteristica = RequisitosPuestos.IDTipoCaracteristica
			and TipoCaracteristica.Activo = 1
		left join Reclutamiento.tblResultadosCandidatoPlaza resultado on resultado.IDCandidatoPlaza = CandidatoPlaza.IDCandidatoPlaza
				and resultado.IDRequisitoPuesto = RequisitosPuestos.IDRequisitoPuesto
	WHERE (Candidatos.IDCandidato = @IDCandidato or ISNULL(@IDCandidato,0) = 0)
		and (CandidatoPlaza.IDCandidatoPlaza = @IDCandidatoPlaza or ISNULL(@IDCandidatoPlaza,0) = 0)
		and (Plazas.IDPlaza= @IDPlaza or ISNULL(@IDPlaza,0) = 0)
		and (Puestos.IDPuesto= @IDPuesto or ISNULL(@IDPuesto,0) = 0)
		and (RequisitosPuestos.IDRequisitoPuesto= @IDRequisitoPuesto or ISNULL(@IDRequisitoPuesto,0) = 0)
		and (resultado.IDResultadosCandidatoPlaza= @IDResultadosCandidatoPlaza or ISNULL(@IDResultadosCandidatoPlaza,0) = 0)
		and (RequisitosPuestos.IDTipoCaracteristica= @IDTipoCaracteristica or ISNULL(@IDTipoCaracteristica,0) = 0)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tblResultadosCandidatoPlaza

	select @TotalRegistros = cast(COUNT(IDRequisitoPuesto) as decimal(18,2)) from @tblResultadosCandidatoPlaza		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tblResultadosCandidatoPlaza
	order by 
		case when @orderByColumn = 'IDRequisitoPuesto'			and @orderDirection = 'asc'		then IDRequisitoPuesto end,			
		case when @orderByColumn = 'IDRequisitoPuesto'			and @orderDirection = 'desc'	then IDRequisitoPuesto end desc,					
		IDRequisitoPuesto asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

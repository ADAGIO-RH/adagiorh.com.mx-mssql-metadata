USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spBuscarProcesos](
	@IDCandidatoPlaza int = 0
	,@IDPlaza int = 0
	,@IDEstatusProceso int = 0
	,@IDCandidato int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Orden'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int = null
)
AS
BEGIN
	SET FMTONLY OFF;
	declare 
		 @TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDIdioma varchar(20)
	;

	 select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
					
	set @query = case
        when @query is null then '""'
        when @query = '' then '""'
        when @query =  '""' then '""'
    else '"'+@query + '*"' end

	declare @tempResponse as table (
		IDCandidatoPlaza INT, 
		IDCandidato int,
		IDPlaza int,
		Plaza Varchar(255),
		IDEstatusProceso int,
		EstatusProceso Varchar(255),
		FechaAplicacion datetime,
		SueldoDeseado decimal
	);

	insert @tempResponse
	SELECT        
		cp.IDCandidatoPlaza
		, cp.IDCandidato
		, cp.IDPlaza
		, JSON_VALUE(catPue.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Plaza 
		, cp.IDProceso
		, JSON_VALUE(ep.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) 
		, cp.FechaAplicacion	
		,ISNULL(cp.SueldoDeseado,0.00) SueldoDeseado
	FROM Reclutamiento.tblCandidatoPlaza cp 
		INNER JOIN Reclutamiento.tblCatEstatusProceso as EP ON EP.IDEstatusProceso = CP.IDProceso 
		INNER JOIN Reclutamiento.tblCandidatos AS c ON cp.IDCandidato = c.IDCandidato  
		inner JOIN RH.tblCatPlazas AS pla ON cp.IDPlaza = pla.IDPlaza 
		inner JOIN RH.tblCatPuestos AS catPue ON pla.IDPuesto = catPue.IDPuesto
	WHERE (cp.IDCandidatoPlaza = @IDCandidatoPlaza OR ISNULL(@IDCandidatoPlaza,0) = 0) 
		and (pla.IDPlaza = @IDPlaza OR ISNULL(@IDPlaza,0) = 0) 
		and (EP.IDEstatusProceso = @IDEstatusProceso OR ISNULL(@IDEstatusProceso,0) = 0)
		and (cp.IDCandidato = @IDCandidato OR ISNULL(@IDCandidato,0) = 0) 
		and (@query = '""' or contains(catPue.Traduccion ,@query)) 			
    order by cp.IDCandidatoPlaza

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDCandidatoPlaza) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then IDCandidatoPlaza end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then IDCandidatoPlaza end desc,					
		IDCandidatoPlaza asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

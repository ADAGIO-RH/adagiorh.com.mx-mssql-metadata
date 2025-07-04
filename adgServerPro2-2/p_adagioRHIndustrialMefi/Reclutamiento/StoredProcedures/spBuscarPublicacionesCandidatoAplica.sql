USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-31
-- Description:	sp para consultar todas las vacantes a las que aplica 
--				un candidato
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarPublicacionesCandidatoAplica]
	(
		@IDCandidato int = 0

		,@PageNumber	int = 1
		,@PageSize		int = 2147483647
		,@query			varchar(100) = '""'
		,@orderByColumn	varchar(50) = 'Orden'
		,@orderDirection varchar(4) = 'asc'
	)
AS
BEGIN

	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
       ,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end


	declare @tempResponse as table (
				IDCandidatoPlaza INT,
				IDPlaza int,
				FechaAplicacion datetime,
				IDCliente int,
				Codigo varchar(50),
				NombrePlaza varchar(50),
				TotalPosiciones int,
				PosicionesOcupadas int,
				PosicionesDisponibles int
    );

	insert @tempResponse
	SELECT
		cp.IDCandidatoPlaza,
        cp.IDPlaza, 
        cp.FechaAplicacion,  
        p.IDCliente, 
        p.Codigo, 
        JSON_VALUE(pue.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as NombrePlaza, 
		p.TotalPosiciones, 
        p.PosicionesOcupadas, 
        p.PosicionesDisponibles
	FROM
		Reclutamiento.tblCandidatoPlaza AS cp LEFT OUTER JOIN
                         RH.tblCatPlazas AS p ON p.IDPlaza = cp.IDPlaza
						 left join RH.tblCatPuestos pue on pue.IDPuesto = p.IDPuesto
	where 
		cp.IDCandidato = @IDCandidato 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT(IDCandidatoPlaza) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then FechaAplicacion end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then FechaAplicacion end desc,					
		IDCandidatoPlaza asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

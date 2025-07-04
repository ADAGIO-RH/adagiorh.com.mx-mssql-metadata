USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LAS ZONAS HORARIAS
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2024-07-03		Justin Davila		agregamos paginacion
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarZonasHorarias]
(
	@IDZonaHoraria int = 0
	, @PageNumber INT = 1
	, @PageSize INT = 2147483647
	, @query VARCHAR(4000) = '""'
	, @orderByColumn VARCHAR(50) = 'ZonaHoraria'
	, @orderDirection VARCHAR(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'ZonaHoraria' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempZonasHorarias') is not null drop table #tempZonasHorarias;

	SELECT 
		 ID as IDZonaHoraria
		,Name as ZonaHoraria 
		,ISNULL(Active,0) as Active
		,ROW_NUMBER()OVER(ORDER BY ID ASC) as ROWNUMBER
	into #tempZonasHorarias
	from Tzdb.Zones Z
	WHERE ((Z.ID = @IDZonaHoraria) OR (ISNULL(@IDZonaHoraria,0) = 0))
			and (@query = '""' or contains(Z.*, @query))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempZonasHorarias

	select @TotalRegistros = count(IDZonaHoraria) from #tempZonasHorarias

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempZonasHorarias
	order by
		case when @orderByColumn = 'ZonaHoraria'	and @orderDirection = 'asc'	then ZonaHoraria end,			
		case when @orderByColumn = 'ZonaHoraria'	and @orderDirection = 'desc'then ZonaHoraria end desc,
		ZonaHoraria asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

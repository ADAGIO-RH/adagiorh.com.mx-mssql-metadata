USE [p_adagioRHMinutoAntes]
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
--Exec [Reclutamiento].[spBuscarEstatusProceso]@IDUsuario = 1
CREATE PROCEDURE [Reclutamiento].[spBuscarEstatusProceso]
(
	 @IDEstatusProceso int = 0
	,@IDUsuario int 
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
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end


declare @tempResponse as table (
		 IDEstatusProceso   int   
		,Descripcion  varchar(50) 
		,MostrarEnProcesoSeleccion bit
		,Orden int
		,Color varchar(50)
		,ProcesoFinal bit
		,IDPlantilla int
		,DescripcionPlantilla varchar(255)
	);
	

	insert into @tempResponse
	SELECT        
		s.IDEstatusProceso, 
		s.Descripcion, 
		s.MostrarEnProcesoSeleccion, 
		s.Orden, 
		s.Color, 
		s.ProcesoFinal,
		isnull(s.IDPlantilla,0) IDPlantilla,
		isnull(p.Descripcion,'') DescripcionPlantilla
	FROM            
		Reclutamiento.tblCatEstatusProceso s
		left join Reclutamiento.tblPlantillas p on p.IDPlantilla = s.IDPlantilla
	WHERE (s.IDEstatusProceso = @IDEstatusProceso OR ISNULL(@IDEstatusProceso,0) = 0)
		and (@query = '""' or contains(s.*, @query)) 
	ORDER BY Orden


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDEstatusProceso]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then Orden end,			
		case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then Orden end desc,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		Orden asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);



END
GO

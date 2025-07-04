USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Onboarding].[spBuscarPlantillas] (
    @IDPlantilla int = 0,
    @IDUsuario int = NULL
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit =1
)
AS
BEGIN
   SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	 ,@IDIdioma varchar(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'NombrePlantilla' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse ;
	
	
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Plantilla'  

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

    SELECT 
        plantilla.IDPlantilla,
        Upper(plantilla.NombrePlantilla) as NombrePlantilla,
        plantilla.IDsPlaza,
        Cargos = ISNULL(
            STUFF(
                (
                    SELECT ', ' + CONVERT(NVARCHAR(100), ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Descripcion')), 'SIN ASIGNAR'))
                    FROM RH.tblCatPuestos WITH (NOLOCK)
                    WHERE IDPuesto IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(plantilla.IDsPlaza, ','))
                    ORDER BY Traduccion ASC
                    FOR XML PATH('')
                ), 1, 1, ''
            ),
            'CARGOS NO DEFINIDOS'
        ),     
        COUNT(T.IDReferencia) AS CantidadTareas,
        ROWNUMBER = ROW_NUMBER()OVER(ORDER BY NombrePlantilla ASC) 
      	Into #TempResponse
    FROM [Onboarding].[tblPlantillas] plantilla
    LEFT JOIN Tareas.tblTareas T ON T.IDReferencia = plantilla.IDPlantilla AND T.IDTipoTablero = 2
    WHERE (IDPlantilla = @IDPlantilla or isnull(@IDPlantilla, 0) = 0) 
        AND  (IDPlantilla in (select ID from #TempFiltros)  
			OR Not Exists(select ID from #TempFiltros) or @ValidarFiltros=0)  
			and (@query = '""' or contains(plantilla.*, @query)) 
    GROUP BY plantilla.IDPlantilla, plantilla.NombrePlantilla, plantilla.IDsPlaza

    	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(@IDPlantilla) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'NombrePlantilla'			and @orderDirection = 'asc'		then NombrePlantilla end,			
		case when @orderByColumn = 'NombrePlantilla'			and @orderDirection = 'desc'	then NombrePlantilla end desc,
		NombrePlantilla asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

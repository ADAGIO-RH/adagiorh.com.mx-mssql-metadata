USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar lista de plazas
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-03-26
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de este sp es necesario aplicar el cambio en el sp [RH].[spIPlazasImportacion]

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBuscarOrganigramasPosiciones] (
	@IDOrganigramaPosicion int = 0	
	,@IDUsuario int    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = null
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
) as
	SET FMTONLY OFF;  

	declare  
		@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00		
		,@IDIdioma varchar(20)
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query = '' then null
				else @query end

	 
	IF OBJECT_ID('tempdb..#TempOrgPosiciones') IS NOT NULL DROP TABLE #TempOrgPosiciones

	select 
    IDOrganigramaPosicion,
    Nombre,
    [Data]
	into #TempOrgPosiciones
	from rh.tblOrganigramasPosiciones
    where  IDOrganigramaPosicion = @IDOrganigramaPosicion or @IDOrganigramaPosicion=0


	 select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempOrgPosiciones

	select @TotalRegistros = cast(COUNT([IDOrganigramaPosicion]) as decimal(18,2)) from #TempOrgPosiciones		
	
	select
		*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        , cast(@TotalRegistros  as int ) as TotalRows
	from #TempOrgPosiciones
	 order by  
            case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end ,
            case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'		then Nombre end desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

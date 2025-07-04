USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Saludoc].[spBuscarProcesosEncuestasCliente](    
	@IDProcesoEncuesta int =0
	,@IDCliente	int = null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaInicio'
	,@orderDirection varchar(4) = 'Desc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaInicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		d.IDProcesoEncuesta
		,d.IDCliente
		,c.NombreComercial as Cliente
		,ISNULL(d.IDUsuario,0) IDUsuario
		,u.Cuenta +' - '+ u.Nombre +' - '+ u.Apellido as Usuario
		,d.FechaInicio
		,d.FechaFin
		,d.Factor
	into #tempResponse
	FROM [Saludoc].[tblProcesosEncuestasCliente] d with(nolock) 
		inner join RH.tblCatClientes c with(nolock)
			on d.IDCliente = c.IDCliente
		left join Seguridad.tblUsuarios u with(nolock)
			on u.IDUsuario = d.IDUsuario 
	WHERE
		( 
            (d.IDProcesoEncuesta = @IDProcesoEncuesta or isnull(@IDProcesoEncuesta,0) =0)
            and(d.IDCliente = @IDCliente or isnull(@IDCliente,0) =0)
        )  
		and (@query = '""' or contains(c.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDProcesoEncuesta) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaInicio'			and @orderDirection = 'asc'		then FechaInicio end,			
		case when @orderByColumn = 'FechaInicio'			and @orderDirection = 'desc'	then FechaInicio end desc,		
		FechaInicio Desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

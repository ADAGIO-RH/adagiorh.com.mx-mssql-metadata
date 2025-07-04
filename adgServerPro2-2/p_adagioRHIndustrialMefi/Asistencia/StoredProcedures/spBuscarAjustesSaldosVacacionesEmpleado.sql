USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca lista de Ajustes saldos de vacaciones
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2024-07-16
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROC [Asistencia].[spBuscarAjustesSaldosVacacionesEmpleado](    
	@IDAjusteSaldo	int = 0
	,@IDEmpleado	int = 0
	,@IDUsuario		int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaAjuste'
	,@orderDirection varchar(4) = 'desc'
)    
AS    
BEGIN    
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int	
        ,@IDIdioma varchar(max)
	;
    --select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaAjuste' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		asve.IDAjusteSaldo
		,asve.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as NombreCompleto
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,ISNULL(asve.SaldoFinal, 0) as SaldoFinal
		,asve.FechaAjuste
		,isnull(asve.IDMovAfiliatorio,0) as IDMovAfiliatorio
		,coalesce(TM.Codigo,'')+' '+coalesce(TM.Descripcion,'') as TipoMovimiento
		,Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(asve.IDEmpleado,0) as UsuarioEmpleadoFotoAvatar
	into #TempResponse
	FROM [Asistencia].[tblAjustesSaldoVacacionesEmpleado] asve with(nolock) 
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios de on de.IDEmpleado = asve.IDEmpleado and de.IDUsuario = @IDUsuario
		join RH.tblEmpleadosMaster e on e.IDEmpleado = asve.IDEmpleado
		left join IMSS.tblMovAfiliatorios m on m.IDMovAfiliatorio = asve.IDMovAfiliatorio
		left join IMSS.tblCatTipoMovimientos TM WITH(NOLOCK) ON TM.IDTipoMovimiento = M.IDTipoMovimiento
	WHERE (asve.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado,0) =0)
		and (@query = '""' or contains(e.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDEmpleado) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaAjuste'			and @orderDirection = 'asc'		then FechaAjuste end,			
		case when @orderByColumn = 'FechaAjuste'			and @orderDirection = 'desc'	then FechaAjuste end desc,		
		FechaAjuste asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarFondosAhorro](
	@IDFondoAhorro int  = 0
	,@IDTipoNomina int = 0
	,@Ejercicio int = 0
	,@IDUsuario int
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Ejercicio'
	,@orderDirection varchar(4) = 'desc'
) as

    DECLARE
		@IDIdioma varchar(20)
        ,@TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

    select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Ejercicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 


    IF OBJECT_ID('tempdb..#tempFondoAhorro') IS NOT NULL DROP TABLE #tempFondoAhorro
	
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	select 
		 cfa.IDFondoAhorro
		,c.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,cfa.IDTipoNomina
		,tn.Descripcion as TipoNomina
		,cfa.Ejercicio
		,cfa.IDPeriodoInicial
		,p.Descripcion as PeriodoInicial
		,isnull(cfa.IDPeriodoFinal,0) as IDPeriodoFinal
		,UPPER(isnull(pp.Descripcion,'SIN ASIGNAR')) as PeriodoFinal
		,isnull(cfa.IDPeriodoPago,0) IDPeriodoPago
		,UPPER(isnull(ppago.Descripcion,'SIN ASIGNAR')) as PeriodoDePago
		,isnull(ppago.Cerrado,cast(0 as bit)) as Pagado
		,isnull(cfa.FechaHora,getdate()) as FechaHora
		,cfa.IDUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
        INTO #tempFondoAhorro   
	from Nomina.tblCatFondosAhorro cfa with(nolock)
		join Nomina.tblCatTipoNomina tn with(nolock) on cfa.IDTipoNomina = tn.IDTipoNomina
		join RH.tblCatClientes c with(nolock) on tn.IDCliente = c.IDCliente
		join Nomina.tblCatPeriodos p with(nolock) on cfa.IDPeriodoInicial = p.IDPeriodo
		left join Nomina.tblCatPeriodos pp with(nolock) on cfa.IDPeriodoFinal = pp.IDPeriodo
		left join Nomina.tblCatPeriodos ppago with(nolock) on cfa.IDPeriodoPago = ppago.IDPeriodo
		join Seguridad.tblUsuarios u  with(nolock) on cfa.IDUsuario = u.IDUsuario
	where (cfa.IDFondoAhorro = @IDFondoAhorro or @IDFondoAhorro = 0)
		and (cfa.IDTipoNomina = @IDTipoNomina or @IDTipoNomina = 0)
		and (cfa.Ejercicio = @Ejercicio or @Ejercicio = 0)
        and ( 
			(@query = '""' or contains(p.*, @query)) OR
            (@query = '""' or contains(pp.*, @query)) OR
            (@query = '""' or contains(ppago.*, @query)) OR
			(@query = '""' or contains(tn.*, @query)) OR
			(@query = '""' or contains(c.*, @query)) OR
			(@query = '""' or contains(u.*, @query)) 			
		) 


    SELECT @TotalPaginas =CEILING( CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM #tempFondoAhorro

	SELECT @TotalRegistros = COUNT(IDFondoAhorro) FROM #tempFondoAhorro	

    select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempFondoAhorro
	order by 	
		case when @orderByColumn = 'Ejercicio' and @orderDirection = 'asc'	then Ejercicio end,			
		case when @orderByColumn = 'Ejercicio' and @orderDirection = 'desc'	then Ejercicio end desc,		
			Ejercicio asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

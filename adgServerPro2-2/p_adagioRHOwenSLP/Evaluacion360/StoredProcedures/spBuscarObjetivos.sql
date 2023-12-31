USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spBuscarObjetivos]( 
	@IDObjetivo int = 0
	,@IDCicloMedicionObjetivo int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int
) as
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int, 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempObjetivos') IS NOT NULL DROP TABLE #TempObjetivos  

	select 
		o.IDObjetivo
		,o.Nombre
		,o.Descripcion
		,o.IDCicloMedicionObjetivo
		--,UPPER(cmo.Nombre) as CicloMedicion	
		,(
			select top 1
				ccmo.IDCicloMedicionObjetivo
				,UPPER(ccmo.Nombre) as Nombre
				,ccmo.FechaInicio
				,ccmo.FechaFin
				,ccmo.IDEstatusCicloMedicion
				,JSON_VALUE(ecm.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusCicloMedicion
				,ccmo.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
			from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
				join Evaluacion360.tblCatEstatusCiclosMedicion ecm on ecm.IDEstatusCicloMedicion = ccmo.IDEstatusCicloMedicion
				join Seguridad.tblUsuarios u on u.IDUsuario = ccmo.IDUsuario
			WHERE (ccmo.IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo) 
			for json path, without_array_wrapper
		) as CicloMedicion
		,o.IDTipoMedicionObjetivo
		,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicionObjetivo
		,o.IDEstatusObjetivo
		,(
			select top 1
				eo.IDEstatusObjetivo
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
				,eo.Orden
			from Evaluacion360.tblCatEstatusObjetivos eo
			where (eo.IDEstatusObjetivo = o.IDEstatusObjetivo) 
			for json path, without_array_wrapper
		) as EstatusObjetivo
		--,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusObjetivo
		,o.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		,o.FechaHoraReg
		,o.Progreso
	INTO #TempObjetivos
	from Evaluacion360.tblCatObjetivos o with (nolock)
		join Evaluacion360.tblCatCiclosMedicionObjetivos cmo with (nolock) on cmo.IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo
		join Evaluacion360.tblCatTiposMedicionesObjetivos tmo with (nolock) on tmo.IDTipoMedicionObjetivo = o.IDTipoMedicionObjetivo
		join Evaluacion360.tblCatEstatusObjetivos eo with (nolock) on eo.IDEstatusObjetivo = o.IDEstatusObjetivo
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = o.IDUsuario
	where 
		(o.IDObjetivo = @IDObjetivo or isnull(@IDObjetivo, 0) = 0)
		and (o.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
		and (@query = '""' or contains(o.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempObjetivos

	select @TotalRegistros = cast(COUNT(IDObjetivo) as decimal(18,2)) from #TempObjetivos		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempObjetivos
	order by 	
		case when @orderByColumn = 'Nombre' and @orderDirection = 'asc'	 then Nombre end,			
		case when @orderByColumn = 'Nombre' and @orderDirection = 'desc' then Nombre end desc,		
			Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spBuscarObjetivosEmpleados](
	@IDObjetivoEmpleado int = 0
	,@IDEmpleado int = 0
	,@IDCicloMedicionObjetivo int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaHoraReg'
	,@orderDirection varchar(4) = 'desc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaHoraReg' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempObjetivosEmpleados') IS NOT NULL DROP TABLE #TempObjetivosEmpleados; 

	select 
		 oe.IDObjetivoEmpleado
		-- ,(
		-- 	select 
		-- 		o.IDObjetivo
		-- 		,o.Nombre
		-- 		,o.Descripcion
		-- 		,o.IDTipoMedicionObjetivo
		-- 	from Evaluacion360.tblCatObjetivos o with (nolock)
		-- 	where o.IDObjetivo = oe.IDObjetivo
		-- 	for json path, without_array_wrapper
		-- ) as CatObjetivo
		,oe.Nombre
        ,oe.Descripcion
        ,oe.IDTipoMedicionObjetivo
        ,oe.IDEmpleado
        ,oe.IDCicloMedicionObjetivo
		,(
			select 
				e.IDEmpleado,
				e.ClaveEmpleado,
				e.NOMBRECOMPLETO as NombreCompleto,
				SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1) as Iniciales,
				case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
			from RH.tblEmpleadosMaster e
				left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = e.IDEmpleado  
			where e.IDEmpleado = oe.IDEmpleado
			for json path, without_array_wrapper
		) as Colaborador
		,oe.Objetivo
		,oe.Actual
		,oe.Peso
		,oe.PorcentajeAlcanzado
		,oe.IDEstatusObjetivoEmpleado
		,(
			select top 1
				eo.IDEstatusObjetivoEmpleado
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
				,eo.Orden
			from Evaluacion360.tblCatEstatusObjetivosEmpleado eo
			where (eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado) 
			for json path, without_array_wrapper
		) as EstatusObjetivoEmpleado
		,oe.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		,oe.FechaHoraReg
        ,isnull((
            SELECT TRY_CAST(AVG(PAO.PorcentajeAlcanzado)AS decimal(18,2)) AS PorcentajeAlcanzado
            FROM App.tblPlanAccion PAO
            WHERE PAO.IDReferencia=OE.IDObjetivoEmpleado and PAO.IDEstatusPlanAccionObjetivo<>7

        ),0) as PorcentajeAlcanzadoPlanAccionObjetivo
        ,isnull((
            SELECT COUNT(*)
            FROM App.tblPlanAccion PAO
            WHERE PAO.IDReferencia=OE.IDObjetivoEmpleado AND PAO.IDEstatusPlanAccionObjetivo<>7
        ),0)as PlanAccionObjetivo
	INTO #TempObjetivosEmpleados
	from Evaluacion360.tblObjetivosEmpleados oe
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuario
        inner join Utilerias.fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados(@IDUsuario) dt on dt.IDEmpleado=oe.IDEmpleado
	where 
		(oe.IDObjetivoEmpleado = @IDObjetivoEmpleado or isnull(@IDObjetivoEmpleado, 0) = 0)
		and (oe.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado, 0) = 0)
		and (oe.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
        --and (oe.Nombre like '%'+@query+'%' or isnull(@query,'') = '')
        and (@query = '""' or contains(oe.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempObjetivosEmpleados

	select @TotalRegistros = cast(COUNT(IDObjetivoEmpleado) as decimal(18,2)) from #TempObjetivosEmpleados		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempObjetivosEmpleados
	order by 	
		case when @orderByColumn = 'FechaHoraReg' and @orderDirection = 'asc'	then FechaHoraReg end,			
		case when @orderByColumn = 'FechaHoraReg' and @orderDirection = 'desc'	then FechaHoraReg end desc,		
			FechaHoraReg asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

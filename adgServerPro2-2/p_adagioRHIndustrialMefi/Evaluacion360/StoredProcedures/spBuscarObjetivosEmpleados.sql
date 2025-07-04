USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spBuscarObjetivosEmpleados](
	@IDObjetivoEmpleado int = 0
	,@IDEmpleado int = 0
	,@IDCicloMedicionObjetivo int = 0
    ,@IDEstatusObjetivoEmpleado int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaHoraReg'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuarioConsulta int
) as

	SET FMTONLY OFF;  

	declare  
	    @TotalPaginas INT = 0
	   ,@TotalRegistros INT
	   ,@IDIdioma VARCHAR(20)    
       ,@IDEmpleadoUsuarioConsulta INT=0   
       ,@ID_ESTATUS_PLAN_ACCION_CANCELADO INT= 7
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuarioConsulta, 'esmx')
    
    SELECT 
    @IDEmpleadoUsuarioConsulta=ISNULL(IDEmpleado,0)
    FROM Seguridad.tblUsuarios where IDUsuario=@IDUsuarioConsulta

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
		,oe.Nombre
        ,oe.Descripcion
        ,oe.IDTipoMedicionObjetivo
        ,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicionObjetivo        
        ,oe.IDEmpleado
        ,oe.IDCicloMedicionObjetivo
        ,(
			select top 1 *				
			from Evaluacion360.tblCatCiclosMedicionObjetivos ccmo
			where ccmo.IDCicloMedicionObjetivo=OE.IDCicloMedicionObjetivo
			for json path, without_array_wrapper
		) as CicloMedicionObjetivo
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
        ,oe.IDEstatusAutorizacion
        ,JSON_VALUE(cea.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as EstatusAutorizacion        
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
		,oe.IDOperador
        ,cor.Operador
        ,oe.IDPeriodicidadActualizacion
        ,JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Periodicidad')) as PeriodicidadActualizacion        
        ,oe.IDUsuarioCreo
        ,coalesce(uc.Nombre, '')+' '+coalesce(uc.Apellido, '') as UsuarioCreo
        ,oe.IDUsuarioAutorizo
		,coalesce(ua.Nombre, '')+' '+coalesce(ua.Apellido, '') as UsuarioAutorizo
		,oe.FechaHoraReg
        ,isnull((
            SELECT TRY_CAST(AVG(PAO.PorcentajeAlcanzado)AS decimal(18,2)) AS PorcentajeAlcanzado
            FROM App.tblPlanAccion PAO
            WHERE PAO.IDReferencia=OE.IDObjetivoEmpleado and PAO.IDEstatusPlanAccionObjetivo<>@ID_ESTATUS_PLAN_ACCION_CANCELADO

        ),0) as PorcentajeAlcanzadoPlanAccionObjetivo
        ,isnull((
            SELECT COUNT(*)
            FROM App.tblPlanAccion PAO
            WHERE PAO.IDReferencia=OE.IDObjetivoEmpleado AND PAO.IDEstatusPlanAccionObjetivo<>@ID_ESTATUS_PLAN_ACCION_CANCELADO
        ),0)as PlanAccionObjetivo   
        ,isnull((
            SELECT COUNT(*)
            FROM Evaluacion360.tblAvanceObjetivoEmpleado AOE
            WHERE AOE.IDObjetivoEmpleado = OE.IDObjetivoEmpleado
        ),0)as AvancesObjetivoEmpleado  
        ,ISNULL(
            (SELECT TOP 1  cast (1 as bit)
            FROM RH.tblJefesEmpleados JE
            WHERE JE.IDJefe=@IDEmpleadoUsuarioConsulta AND JE.IDEmpleado=OE.IDEmpleado)
        ,cast(0 as bit)) AS EsJefeUsuarioConsulta
        ,CASE WHEN @IDEmpleadoUsuarioConsulta=OE.IDEmpleado THEN cast(1 as bit) ELSE cast(0 as bit) END AS ObjetivoPerteneceAConsultante
        ,CASE WHEN @IDUsuarioConsulta=OE.IDUsuarioCreo THEN cast(1 as bit) ELSE cast(0 as bit) END AS ObjetivoCapturadoPorConsultante
        ,CASE WHEN ISNULL((SELECT U.IDEMPLEADO FROM Seguridad.tblUsuarios U WHERE U.IDUsuario=OE.IDUsuarioCreo),0)=OE.IDEMPLEADO THEN cast(1 as bit) ELSE cast(0 as bit) END AS ObjetivoCapturadoPorEmpleado
	INTO #TempObjetivosEmpleados
	from Evaluacion360.tblObjetivosEmpleados oe
		inner join Seguridad.tblUsuarios uc with (nolock) on uc.IDUsuario = oe.IDUsuarioCreo                
        left join Seguridad.tblUsuarios ua with (nolock) on ua.IDUsuario = oe.IDUsuarioAutorizo                
        inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dt on dt.IDUsuario=@IDUsuarioConsulta and dt.IDEmpleado=oe.IDEmpleado
        inner join Evaluacion360.tblCatTiposMedicionesObjetivos tmo on tmo.IDTipoMedicionObjetivo=oe.IDTipoMedicionObjetivo
        inner join app.tblCatOperadoresRacionales cor on cor.IDOperador=oe.IDOperador
        inner join app.tblCatPeriodicidades cp on cp.IDPeriodicidad= oe.IDPeriodicidadActualizacion        
        inner join app.tblcatestatusautorizacion cea on cea.IDEstatusAutorizacion=oe.IDEstatusAutorizacion
	where 
		(oe.IDObjetivoEmpleado = @IDObjetivoEmpleado or isnull(@IDObjetivoEmpleado, 0) = 0)
		and (oe.IDEmpleado = @IDEmpleado or isnull(@IDEmpleado, 0) = 0)
		and (oe.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
        and (oe.IDEstatusObjetivoEmpleado = @IDEstatusObjetivoEmpleado or isnull(@IDEstatusObjetivoEmpleado, 0) = 0)        
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

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarProyectosFilter](
	@IDProyecto int = 0
	,@IDTipoProyecto int = 0
	,@IdsEstatus	varchar(max) = null
	,@IDUsuario		int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaInicio'
	,@orderDirection varchar(4) = 'desc'
) as
    SET FMTONLY OFF;

	declare 
		@VER_TODAS_LAS_PRUEBAS bit = 0,
		@IDEmpleadoJefe int,

		@IDIdioma Varchar(5),
		@IdiomaSQL varchar(100) = null,

		@TotalPaginas int = 0,
		@TotalRegistros decimal(18,2) = 0.00
	; 

	begin -- Set Idioma 
		SET DATEFIRST 7;

		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

		select @IdiomaSQL = [SQL]
		from app.tblIdiomas
		where IDIdioma = @IDIdioma

		if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
		begin
			set @IdiomaSQL = 'Spanish' ;
		end
  
		SET LANGUAGE @IdiomaSQL;
	end
	
	select @IDEmpleadoJefe = IDEmpleado
	from Seguridad.tblUsuarios
	where IDUsuario = @IDUsuario

	if exists(
		select top 1 1 
		from [Seguridad].[vwPermisosEspecialesUsuarios] pes with (nolock)	
			join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'VER_TODAS_LAS_PRUEBAS')
	begin
		set @VER_TODAS_LAS_PRUEBAS = 1
	end;

	if OBJECT_ID('tempdb..#tempProyectos') is not NULL drop table #tempProyectos;
	if OBJECT_ID('tempdb..#tempHistorialEstatusProyectos') is not NULL drop table #tempHistorialEstatusProyectos;
	if OBJECT_ID('tempdb..#TempPruebas') IS NOT NULL drop table #TempPruebas;  
	if OBJECT_ID('tempdb..#tempSubordinadosProyectos') IS NOT NULL drop table #tempSubordinadosProyectos;  
	
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaInicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	select distinct ep.IDProyecto
	into #tempSubordinadosProyectos
	from [Evaluacion360].[tblEmpleadosProyectos] ep
	where ep.IDEmpleado in (select IDEmpleado from RH.tblJefesEmpleados where IDJefe = @IDEmpleadoJefe)

	select p.*
	INTO #tempProyectos
	from Evaluacion360.tblCatProyectos p with (nolock) 
		left join [Evaluacion360].[tblAdministradoresProyecto] ap on ap.IDProyecto = p.IDProyecto and ap.IDUsuario = @IDUsuario
		left join #tempSubordinadosProyectos tp on tp.IDProyecto = p.IDProyecto
	where 
		(p.IDProyecto = @IDProyecto or isnull(@IDProyecto, 0) = 0)
		and (p.IDTipoProyecto = @IDTipoProyecto or isnull(@IDTipoProyecto, 0) = 0)
		and (p.IDUsuario = case 
								when @VER_TODAS_LAS_PRUEBAS = 1 then p.IDUsuario 
								when ap.IDAdministradorProyecto is not null then p.IDUsuario
								when tp.IDProyecto is not null then p.IDUsuario
							else @IDUsuario end
			)
		and (@query = '""' or contains(p.*, @query)) 

	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
		,tep.IDUsuario
		,tep.FechaCreacion 
		,ROW_NUMBER()over(partition by tep.IDProyecto 
							ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusProyectos
	from #tempProyectos tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus

	select 
		p.IDProyecto
		,p.Nombre --+' - '+isnull(convert(varchar(50),p.FechaInicio,106),'Fecha sin asignar') as Nombre
		,p.Descripcion
		,isnull(thep.IDEstatus,0) AS IDEstatus
		,isnull(thep.Estatus,'Sin estatus') AS Estatus
		,isnull(p.FechaCreacion,getdate()) as FechaCreacion
		,p.IDUsuario
		--,isnull(u.IDEmpleado,0) as IDEmpleado
		--,u.Cuenta
		,Usuario = case when emp.IDEmpleado is not null then coalesce(emp.Nombre,'')+' '+coalesce(emp.Paterno,'')+' '+coalesce(emp.Materno,'')
					   else coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') END
		,AutoEvaluacion = CASE WHEN EXISTS (SELECT TOP 1 1 
												FROM [Evaluacion360].[tblEvaluadoresRequeridos] 
												WHERE IDProyecto = p.IDProyecto AND IDTipoRelacion = 4) THEN cast(1 as bit) else cast(0 as bit) END
		,isnull(p.TotalPruebasARealizar,0)	 as TotalPruebasARealizar
		,isnull(p.TotalPruebasRealizadas,0)	 as TotalPruebasRealizadas
		,isnull(p.Progreso,0)				 AS Progreso
		,isnull(p.FechaInicio,'1990-01-01') AS FechaInicio
		,isnull(p.FechaFin,'1990-01-01') AS FechaFin
		,isnull(Calendarizado,cast(0 AS bit)) AS Calendarizado
		,isnull(IDTask,0) AS IDTask
		,isnull(IDSchedule,0) AS IDSchedule
		,isnull(wu.IDWizardUsuario,0) AS IDWizardUsuario
		,ctp.IDTipoProyecto
		,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoProyecto
	INTO #TempPruebas
	from #tempProyectos p
		join [Evaluacion360].[tblCatTiposProyectos] ctp on ctp.IDTipoProyecto = isnull(p.IDTipoProyecto, 1)
		join [Seguridad].[TblUsuarios] u with(nolock) on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu with(nolock)  on wu.IDProyecto = p.IDProyecto
		left join [RH].[tblEmpleados] emp with(nolock) on u.IDEmpleado = emp.IDEmpleado
		left join #tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
	where (thep.IDEstatus in (select CAST(item as int) from App.Split(@IdsEstatus, ','))
				or 
				isnull(@IdsEstatus, '') = ''
			)
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPruebas

	select @TotalRegistros = cast(COUNT([IDProyecto]) as decimal(18,2)) from #TempPruebas		
	
	select
		*
		,(select count(*) from Evaluacion360.tblEmpleadosProyectos ep where ep.IDProyecto = t.IDProyecto AND ep.TipoFiltro <> 'Excluir Empleado') as TotalEvaluados
		,(
			select top 5
				e.IDEmpleado, 
				e.ClaveEmpleado, 
				e.NOMBRECOMPLETO as Colaborador,
				SUBSTRING(coalesce(e.Nombre, ''), 1, 1)+SUBSTRING(coalesce(e.Paterno, coalesce(e.Materno, '')), 1, 1) as Iniciales,
				case when fe.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
			from Evaluacion360.tblEmpleadosProyectos ee 
				join RH.tblEmpleadosMaster e on e.IDEmpleado = ee.IDEmpleado and e.Vigente = 1	
				left join [RH].[tblFotosEmpleados] fe with (nolock) on fe.IDEmpleado = e.IDEmpleado  
			where ee.IDProyecto = t.IDProyecto AND ee.TipoFiltro <> 'Excluir Empleado'
			for json auto
		) TopEvaluados
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,cast(isnull(@TotalRegistros, 0) as int) as TotalRegistros
	from #TempPruebas t
	order by 
		case when @orderByColumn = 'FechaInicio'	and @orderDirection = 'asc'	then FechaInicio end,			
		case when @orderByColumn = 'FechaInicio'	and @orderDirection = 'desc'	then FechaInicio end desc,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'	then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,			
        FechaInicio desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

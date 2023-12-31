USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spBuscarProyectosFilter](
--declare
	@IdsEstatus	varchar(max) = null
	,@IDUsuario		int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = ''
	,@orderByColumn	varchar(50) = 'FechaInicio'
	,@orderDirection varchar(4) = 'desc'
) as

    SET FMTONLY OFF
	SET LANGUAGE 'Spanish';

	if OBJECT_ID('tempdb..#tempProyectos') is not NULL drop table #tempProyectos;
	if OBJECT_ID('tempdb..#tempHistorialEstatusProyectos') is not NULL drop table #tempHistorialEstatusProyectos;
	if OBJECT_ID('tempdb..#TempPruebas') IS NOT NULL drop table #TempPruebas;  
	
	declare 
		@VerPruebasDeSubordinados bit = 0 
		,@IDJefe int
		,@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		--,@IDIdioma varchar(20)
	;

	--select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaInicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 


	select @IDJefe = IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario;
	select @VerPruebasDeSubordinados = cast(isnull(valor, 0) as bit) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'VerPruebasDeSubordinados'
 
	BEGIN -- SUBORDINADOS    
		declare  @tblTempSubordinados table(  
			IDEmpleado int 
			,IDUsuario int
		);

		insert into @tblTempSubordinados(IDEmpleado,IDUsuario)   
		select u.IDEmpleado,u.IDUsuario
		from Seguridad.tblDetalleFiltrosEmpleadosUsuarios deu
			join Seguridad.tblUsuarios u on deu.IDEmpleado = u.IDEmpleado
		where deu.IDUsuario =  @IDUsuario

		select p.*
		INTO #tempProyectos
		from Evaluacion360.tblCatProyectos p with (nolock) 
			left join @tblTempSubordinados ts on p.IDUsuario = ts.IDUsuario
		where (p.IDUsuario = case 
								when @VerPruebasDeSubordinados = 1 then p.IDUsuario 
								else @IDUsuario 
							end)
	END -- SUBORDINADOS  

	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Estatus,'Sin estatus') AS Estatus
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
	INTO #TempPruebas
	from #tempProyectos p
		join [Seguridad].[TblUsuarios] u with(nolock) on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu with(nolock)  on wu.IDProyecto = p.IDProyecto
		left join [RH].[tblEmpleados] emp with(nolock) on u.IDEmpleado = emp.IDEmpleado
		left join #tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
	where (p.Nombre like '%'+@query+'%' or isnull(@query, '') = '')
		and
			(thep.IDEstatus in (select CAST(item as int) from App.Split(@IdsEstatus, ','))
				or 
				isnull(@IdsEstatus, '') = ''
			)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPruebas

	select @TotalRegistros = cast(COUNT([IDProyecto]) as decimal(18,2)) from #TempPruebas		
	
	select
		*
		,(select count(*) from Evaluacion360.tblEmpleadosProyectos ep where ep.IDProyecto = t.IDProyecto) as TotalEvaluados
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
			where ee.IDProyecto = t.IDProyecto
			for json auto
		) TopEvaluados
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
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

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca proyectos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 

 Si se modifica el result set de este sp será necesario modificar también los siguientes SP's:

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-12			Aneudy Abreu	Se agregó el campo IDWizardUsuario
2019-06-04			Aneudy Abreu	Se agregó la validación de la configuración 'VerPruebasDeSubordinados'
									la cual permite que el usuario pueda ver las pruebas de sus subordinados.
2019-06-06			Aneudy Abreu	Se agregó el parámetro y validación '@VerTodas'
									el cual permite que el usuario pueda ver todas las pruebas independientemente de quien
									la creó.
***************************************************************************************************/

CREATE proc [Evaluacion360].[spBuscarProyectos](
	@IDProyecto int = null
	,@VerTodas bit = 0
	,@IDUsuario int
) as

    SET FMTONLY OFF
	SET LANGUAGE 'Spanish';

	if object_id('tempdb..#tempProyectos') is not NULL drop table #tempProyectos;

	declare 
		@VerPruebasDeSubordinados bit = 0 
		,@IDJefe int
		;

	select @IDJefe = IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario;
	select @VerPruebasDeSubordinados = cast(isnull(valor, 0) as bit) from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'VerPruebasDeSubordinados'
 
	BEGIN -- SUBORDINADOS    
		declare  @tblTempSubordinados table(  
			IDEmpleado int 
			,IDUsuario int
		);

		--;With CteSubordinados  
		--As  
		--(  
		--	select fe.IDEmpleado
		--	from RH.tblJefesEmpleados fe  with (nolock) 
		--		join [Seguridad].[TblUsuarios] u  with (nolock)  on u.IDEmpleado = fe.IDEmpleado
		--	where fe.IDJefe = @IDJefe  
		--	Union All  
		--	select fe.IDEmpleado
		--	from RH.tblJefesEmpleados fe  with (nolock) 
		--		join CteSubordinados P On fe.IDJefe = p.IDEmpleado
		--		join [Seguridad].[TblUsuarios] u  with (nolock)  on u.IDEmpleado = p.IDEmpleado
		--)  

		--insert into @tblTempSubordinados(IDEmpleado,IDUsuario)          
		--select isnull(u.IDEmpleado,0),u.IDUsuario
		--from Seguridad.tblUsuarios u
		--where u.IDUsuario = @IDUsuario
		--UNION
		--select cte.IDEmpleado,u.IDUsuario
		--from CteSubordinados cte
		--	join Seguridad.tblUsuarios u with (nolock)  on cte.IDEmpleado = u.IDEmpleado
		--OPTION (MAXRECURSION 0); }

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
								when @VerTodas = 1 then p.IDUsuario 
								when @VerPruebasDeSubordinados = 1 then p.IDUsuario 
								else @IDUsuario 
							end)

	END -- SUBORDINADOS  

	if object_id('tempdb..#tempHistorialEstatusProyectos') is not NULL drop table #tempHistorialEstatusProyectos;
	
	if @IDProyecto = 0 set @IDProyecto = null;

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
	where tcp.IDProyecto = @IDProyecto or @IDProyecto is null

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
	from #tempProyectos p
		join [Seguridad].[TblUsuarios] u on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu on wu.IDProyecto = p.IDProyecto
		left join [RH].[tblEmpleados] emp on u.IDEmpleado = emp.IDEmpleado
		LEFT JOIN #tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
	where (p.IDProyecto = @IDProyecto or @IDProyecto is null) --and p.IDUsuario = @IDUsuario
	Order by p.Nombre asc
	--Order by thep.IDEstatus asc

	IF @IDProyecto IS NOT NULL 
	exec [Evaluacion360].[spBuscarConfiguracionAvanzadaProyecto] @IDProyecto = @IDProyecto
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca proyectos por estatus
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-07-13
** Paremetros		:  @IdsEstatus varchar(max) - IDs separados por coma (,)
						@IDUsuario int           

** DataTypes Relacionados: 

 Si se modifica el result set de este sp será necesario modificar también los siguientes SP's:
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
create proc [Evaluacion360].[spBuscarProyectosPorEstatus](
	@IdsEstatus varchar(max)
	,@IDUsuario int
) as

    SET FMTONLY OFF
	SET LANGUAGE 'Spanish';

	--declare 
	--	@IdsEstatus varchar(max) = '1,6'

	if object_id('tempdb..#tempProyectos') is not NULL drop table #tempProyectos;
	if object_id('tempdb..#tempHistorialEstatusProyectos') is not NULL drop table #tempHistorialEstatusProyectos;

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
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep with (nolock) on tep.IDProyecto = tcp.IDProyecto
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus

	select 
		p.IDProyecto
		,p.Nombre --+' - '+isnull(convert(varchar(50),p.FechaInicio,106),'Fecha sin asignar') as Nombre
		,p.Descripcion
		,isnull(thep.IDEstatus,0) AS IDEstatus
		,isnull(thep.Estatus,'Sin estatus') AS Estatus
		,isnull(p.FechaCreacion,getdate()) as FechaCreacion
		--,p.IDUsuario
		----,isnull(u.IDEmpleado,0) as IDEmpleado
		----,u.Cuenta
		--,Usuario = case when emp.IDEmpleado is not null then coalesce(emp.Nombre,'')+' '+coalesce(emp.Paterno,'')+' '+coalesce(emp.Materno,'')
		--			   else coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') END
		--,AutoEvaluacion = CASE WHEN EXISTS (SELECT TOP 1 1 
		--										FROM [Evaluacion360].[tblEvaluadoresRequeridos] 
		--										WHERE IDProyecto = p.IDProyecto AND IDTipoRelacion = 4) THEN cast(1 as bit) else cast(0 as bit) END
		--,isnull(p.TotalPruebasARealizar,0)	 as TotalPruebasARealizar
		--,isnull(p.TotalPruebasRealizadas,0)	 as TotalPruebasRealizadas
		--,isnull(p.Progreso,0)				 AS Progreso
		--,isnull(p.FechaInicio,'1990-01-01') AS FechaInicio
		--,isnull(p.FechaFin,'1990-01-01') AS FechaFin
		--,isnull(Calendarizado,cast(0 AS bit)) AS Calendarizado
		--,isnull(IDTask,0) AS IDTask
		--,isnull(IDSchedule,0) AS IDSchedule
		--,isnull(wu.IDWizardUsuario,0) AS IDWizardUsuario
	from [Evaluacion360].[tblCatProyectos] p with (nolock)
		join [Seguridad].[TblUsuarios] u with (nolock) on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu with (nolock) on wu.IDProyecto = p.IDProyecto
		join #tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
		left join [RH].[tblEmpleados] emp with (nolock) on u.IDEmpleado = emp.IDEmpleado
	where thep.IDEstatus in (select CAST(item as int) from App.Split(@IdsEstatus, ','))
	order by p.Nombre asc
	--Order by thep.IDEstatus asc
GO

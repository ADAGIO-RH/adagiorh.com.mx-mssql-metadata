USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [Evaluacion360].[spTerminarProyectosPorVencimiento] as
/*
	(1, 'Pendiente de asignaciones', '#87CEEB', 'clock-fill')
	,(2, 'Esperando Aprobación', '#FFFF00', 'check-circle')
	,(3, 'En Proceso', '#00FF00', 'gear-fill')
	,(4, 'Suspendido (Cancelado)', '#FF0000', 'x-circle-fill')
	,(5, 'Fuera de tiempo', '#FFA500', 'exclamation-triangle-fill')
	,(6, 'Completo', '#008000', 'check-circle-fill')

*/
	declare 
		@IDUsuarioAdmin int,

		@ID_ESTATUS_PROYECTO_PENDIENTE_DE_ASIGNACIONES int = 1,
		@ID_ESTATUS_PROYECTO_ESPERANDO_APROBACION int = 2,
		@ID_ESTATUS_PROYECTO_EN_PROCESO int = 3,
		@ID_ESTATUS_PROYECTO_FUERA_DE_TIEMPO int = 5
	;
	
	SELECT TOP 1 @IDUsuarioAdmin = Valor FROM App.tblConfiguracionesGenerales WITH(NOLOCK) WHERE IDConfiguracion = 'IDUsuarioAdmin'

	if object_id('tempdb..#tempProyectos') is not NULL drop table #tempProyectos;
	declare @tempHistorialEstatusProyectos as table(
		IDEstatusProyecto int,
		IDProyecto int,
		IDEstatus int,
		Estatus varchar(255),
		IDUsuario int, 
		FechaCreacion datetime,
		[ROW] int
	)
	
	insert @tempHistorialEstatusProyectos
	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto		
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Estatus,'Sin estatus') AS Estatus
		,tep.IDUsuario
		,tep.FechaCreacion 
		,ROW_NUMBER()over(partition by tep.IDProyecto 
							ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus

	WHILE 1 = 1
	BEGIN
		delete TOP(1000) @tempHistorialEstatusProyectos 
		where IDEstatus not in (
			@ID_ESTATUS_PROYECTO_PENDIENTE_DE_ASIGNACIONES, 
			@ID_ESTATUS_PROYECTO_ESPERANDO_APROBACION,
			@ID_ESTATUS_PROYECTO_EN_PROCESO
		)
		or [ROW] != 1

		if @@ROWCOUNT = 0 BREAK;
	END

	select 
		p.IDProyecto
		,p.Nombre --+' - '+isnull(convert(varchar(50),p.FechaInicio,106),'Fecha sin asignar') as Nombre
		,p.Descripcion
		,isnull(p.FechaInicio,'1990-01-01') AS FechaInicio
		,isnull(p.FechaFin,'9999-12-31') AS FechaFin
		,p.IDUsuario
		,isnull(thep.IDEstatus,0) AS IDEstatus
		,isnull(thep.Estatus,'Sin estatus') AS Estatus
		,isnull(thep.FechaCreacion,getdate()) as FechaCreacionEstatus
		,[ROW]
	into #tempProyectos
	from [Evaluacion360].[tblCatProyectos] p with (nolock)
		join @tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto
		join [Evaluacion360].[tblCatTiposProyectos] ctp on ctp.IDTipoProyecto = isnull(p.IDTipoProyecto, 1)
		join [Seguridad].[TblUsuarios] u with (nolock) on p.IDUsuario = u.IDUsuario
		join [Evaluacion360].[tblWizardsUsuarios] wu with (nolock) on wu.IDProyecto = p.IDProyecto
		left join [RH].[tblEmpleados] emp with (nolock) on u.IDEmpleado = emp.IDEmpleado
	where isnull(p.FechaFin,'9999-12-31') < cast(getdate() as date)
 
	insert [Evaluacion360].[tblEstatusProyectos](IDProyecto, IDEstatus, IDUsuario)
	select IDProyecto, @ID_ESTATUS_PROYECTO_FUERA_DE_TIEMPO, @IDUsuarioAdmin
	from #tempProyectos

	exec [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]
GO

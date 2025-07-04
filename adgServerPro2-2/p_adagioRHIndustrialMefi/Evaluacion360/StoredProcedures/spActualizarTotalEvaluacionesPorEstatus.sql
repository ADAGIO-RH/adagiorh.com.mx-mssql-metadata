USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus] as
	if object_id('tempdb..#tempTotalesProyectos') is not NULL drop table #tempTotalesProyectos;

	declare @tempHistorialEstatusProyectos as table(
		IDEstatusProyecto int,
		IDProyecto int,
		IDEstatus int,
		Estatus varchar(255),
		IDUsuario int, 
		FechaCreacion datetime,
		[ROW] int
	)
	Declare 
@IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	insert @tempHistorialEstatusProyectos
	select 
		tep.IDEstatusProyecto
		,tep.IDProyecto		
		,isnull(tep.IDEstatus,0) AS IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),'Sin estatus') AS Estatus
		,tep.IDUsuario
		,tep.FechaCreacion 
		,ROW_NUMBER()over(partition by tep.IDProyecto 
							ORDER by tep.IDProyecto, tep.FechaCreacion  desc) as [ROW]
	from [Evaluacion360].[tblCatProyectos] tcp with (nolock)
		left join [Evaluacion360].[tblEstatusProyectos] tep	 with (nolock) on tep.IDProyecto = tcp.IDProyecto
		left join (select * from Evaluacion360.tblCatEstatus with (nolock) where IDTipoEstatus = 1) estatus on tep.IDEstatus = estatus.IDEstatus
	
	select thep.IDEstatus, thep.Estatus, count(*) as Total
	INTO #tempTotalesProyectos
	from [Evaluacion360].[tblCatProyectos] p with (nolock)
		LEFT JOIN @tempHistorialEstatusProyectos thep ON p.IDProyecto = thep.IDProyecto and thep.[ROW] = 1
	group by thep.IDEstatus, thep.Estatus 

	update estatus
		set TotalEvaluaciones = isnull( totales.Total, 0)
	from Evaluacion360.tblCatEstatus estatus
		left join #tempTotalesProyectos totales on totales.IDEstatus = estatus.IDEstatus
	where estatus.IDTipoEstatus = 1
GO

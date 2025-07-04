USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spReporteTotalEvaluacionesPorEstatus](
	@IDProyecto int  
	,@IDUsuario int  
) as
DECLARE  @DinamicColumns nvarchar(max)
		,@DinamicColumnsNULL nvarchar(max)
		,@query  NVARCHAR(MAX)

 set @DinamicColumns= (SELECT SUBSTRING(
	(SELECT ',[' + CONVERT(varchar, replace(Estatus,' ','_')) +']'
	from [Evaluacion360].[tblCatEstatus] where IDTipoEstatus = 2
	FOR XML PATH('')),2,200000))+ ',[Sin_Estatus]'
 
 
	if object_id('tempdb..#tempEvaluaciones') is not null
		drop table #tempEvaluaciones;

	create table #tempEvaluaciones(
		IDEmpleadoProyecto int
		,IDProyecto int
		,IDEmpleado int
		,ClaveEmpleado varchar(20)
		,Colaborador varchar(max)
		,IDEvaluacionEmpleado int
		,IDTipoRelacion int
		,Relacion varchar(255)
		,IDEvaluador int
		,ClaveEvaluador varchar(20)
		,Evaluador varchar(max)
		,Minimo int
		,Maximo int
		,Requerido bit 
		,[Row] int
		,IDEstatusEvaluacionEmpleado int
		,IDEstatus int
		,Estatus varchar(255)
		,Progreso int
	);

	insert #tempEvaluaciones
	exec [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] @IDProyecto,@IDUsuario

 set @query = N'SELECT  ' + @DinamicColumns + ' from 
             (
				select IDEstatus,replace(Estatus,'' '',''_'') as Estatus
				from #tempEvaluaciones 
				-- group by IDEstatus,Estatus   
            ) x
            pivot 
            (
                Count(IDEstatus) 
                for Estatus in (' + @DinamicColumns + ')
            ) p  '


execute(@query)
GO

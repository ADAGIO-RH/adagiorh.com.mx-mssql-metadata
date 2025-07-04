USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spReporteTotalEvaluacionesPorEvaluadorEstatus](
	@IDProyecto int  
	,@IDUsuario int  
) as
 
 DECLARE  
 @IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	--@IDProyecto int  = 36
	--,@IDUsuario int  = 1
 
 

DECLARE  @DinamicColumns nvarchar(max)
		,@DinamicColumnsNULL nvarchar(max)
		,@DinamicColumnsSUM nvarchar(max)
		,@query  NVARCHAR(MAX)
 

	if object_id('tempdb..#tempTotales') is not null
	drop table #tempTotales;

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
		,Clave varchar(20)
		,Evaluador varchar(max)
		,Minimo int
		,Maximo int
		,Requerido bit 
		,CumpleTipoRelacion bit 
		,[Row] int
		,IDEstatusEvaluacionEmpleado int
		,IDEstatus int
		,Estatus varchar(255)
		,Progreso int
		,Iniciales VARCHAR(2)
		,Evaluar BIT
	);

	insert #tempEvaluaciones
	exec [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] @IDProyecto,@IDUsuario

	--SELECT * FROM #tempEvaluaciones

	update #tempEvaluaciones
	set Evaluador = replace(replace(Evaluador,']',''),'[','')
		,Estatus = CASE WHEN Estatus = 'SIN ESTATUS' THEN 'SIN_ESTATUS' ELSE Estatus end

	set @DinamicColumns= (SELECT SUBSTRING(
	(SELECT ',[' + CONVERT(varchar, replace(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),' ','_')) +']'
			from [Evaluacion360].[tblCatEstatus] where IDTipoEstatus = 2
			FOR XML PATH('')),2,200000))+ ',[SIN_ESTATUS]'

	set @DinamicColumnsNULL= (SELECT SUBSTRING(
	(SELECT ',ISNULL([' + CONVERT(varchar, replace(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) ,' ','_')) +'],0) as '
    + CONVERT(varchar, replace(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) ,' ','_'))
			from [Evaluacion360].[tblCatEstatus] where IDTipoEstatus = 2
			FOR XML PATH('')),2,200000))+ ',ISNULL([SIN_ESTATUS],0) as SIN_ESTATUS'

	set @DinamicColumnsSUM= (SELECT SUBSTRING(
	(SELECT ',ISNULL(SUM([' + CONVERT(varchar, replace(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) ,' ','_')) +']),0) as '
    + CONVERT(varchar, replace(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) ,' ','_'))
			from [Evaluacion360].[tblCatEstatus] where IDTipoEstatus = 2
			FOR XML PATH('')),2,200000))+ ',ISNULL(SUM([SIN_ESTATUS]),0) as SIN_ESTATUS'
 
	select  Clave,IDEvaluador,Evaluador,IDEstatus,Estatus,count(*) as Total
	INTO #tempTotales
	from #tempEvaluaciones
	where IDEvaluador <> 0
	group by Clave,IDEvaluador,Evaluador,IDEstatus,Estatus


	set @query = N'SELECT  Clave,Evaluador,' + @DinamicColumnsSUM + ' from 
             (
				select Clave,IDEvaluador,Evaluador,IDEstatus,Estatus,Total
				from #tempTotales
				--group by IDEstatus,Estatus   
            ) x
            pivot 
            (
                SUM(Total) 
                for Estatus in (' + @DinamicColumns + ')
            ) p GROUP BY
				Clave,Evaluador'
	
	print(@query)
	execute(@query)
 
--SELECT  Clave,Evaluador,ISNULL([PENDIENTE_DE_ASIGNACIONES],0) as PENDIENTE_DE_ASIGNACIONES,ISNULL([EVALUADOR_ASIGNADO],0) as EVALUADOR_ASIGNADO,ISNULL([EN_PROCESO],0) as EN_PROCESO,ISNULL([COMPLETA],0) as COMPLETA,ISNULL([CANCELADA],0) as CANCELADA,ISNULL([SIN_ESTATUS],0) as SIN_ESTATUS from 
--             (
--				select Clave,IDEvaluador,Evaluador,IDEstatus,Estatus,Total
--				from #tempTotales
--				--group by IDEstatus,Estatus   
--            ) x
--            pivot 
--            (
--                SUM(Total) 
--                for Estatus in ([PENDIENTE_DE_ASIGNACIONES],[EVALUADOR_ASIGNADO],[EN_PROCESO],[COMPLETA],[CANCELADA],[SIN_ESTATUS])
--            ) p GROUP BY
--				Clave,Evaluador
GO

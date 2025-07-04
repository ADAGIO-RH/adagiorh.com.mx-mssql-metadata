USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spReporteTotalEvaluacionesPorEvaluadosEstatus](
	@IDProyecto int  
	,@IDUsuario int  
) as
 
DECLARE  @DinamicColumns nvarchar(max)
		,@DinamicColumnsNULL nvarchar(max)
		,@query  NVARCHAR(MAX)
        ,@IDIdioma VARCHAR(max)
        
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 

	if object_id('tempdb..#tempTotales') is not null
	drop table #tempTotales;

	if object_id('tempdb..#tempEvaluaciones') is not null
		drop table #tempEvaluaciones;

	create table #tempEvaluaciones(
		IDEmpleadoProyecto int
		,IDProyecto int
		,IDEmpleado int
		,Clave varchar(20)
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

	update #tempEvaluaciones
	set Evaluador = replace(replace(Evaluador,']',''),'[','')

	set @DinamicColumns= (SELECT SUBSTRING(
	(SELECT ',[' + CONVERT(varchar, replace(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')),' ','_')) +']'
			from [Evaluacion360].[tblCatEstatus] where IDTipoEstatus = 2
			FOR XML PATH('')),2,200000))+ ',[Sin_estatus]'
 
	select  Clave,IDEmpleado,Colaborador,IDEstatus,Estatus,count(*) as Total
	INTO #tempTotales
	from #tempEvaluaciones
	where IDEvaluador <> 0
	group by Clave,IDEmpleado,Colaborador,IDEstatus,Estatus


	set @query = N'SELECT  Clave,Colaborador,' + @DinamicColumns + ' from 
             (
				select Clave,IDEmpleado,Colaborador,IDEstatus,Estatus
				from #tempTotales
				-- group by IDEstatus,Estatus   
            ) x
            pivot 
            (
                Count(IDEmpleado) 
                for Estatus in (' + @DinamicColumns + ')
            ) p  '
	
	--print(@query)
	execute(@query)
 

 --SELECT  Evaluador,[Nueva],[Sin_Evaluador_asignado],[En_proceso],[Completa],[Cancelada],[Sin estatus] from 
 --            (
	--			select IDEvaluador,replace(Evaluador,' ','_') as Evaluador,IDEstatus,Estatus
	--			from #tempTotales
	--			-- group by IDEstatus,Estatus   
 --           ) x
 --           pivot 
 --           (
 --               Count(IDEvaluador) 
 --               for Estatus in ([Nueva],[Sin_Evaluador_asignado],[En_proceso],[Completa],[Cancelada],[Sin estatus])
 --           ) p  
GO

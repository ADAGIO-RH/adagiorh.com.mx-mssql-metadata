USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spGraficaHistoriaEvaluacionEmpleado](
	@IDEmpleado int
)as

	declare @DinamicColumns nvarchar(max)
		,@DinamicColumnsNULL nvarchar(max)
		,@DinamicColumnsSUM nvarchar(max)
		,@query  NVARCHAR(MAX)
		,@dtProyectos [Evaluacion360].[dtProyectos]
		;

	set @DinamicColumns= (SELECT SUBSTRING(
	(SELECT ',[' + CONVERT(varchar, replace(replace(replace(Nombre,' ','_'),'(',''),')','') ) +']'
			from [Evaluacion360].[tblCatTipoGrupo] 
			FOR XML PATH('')),2,200000))

	set @DinamicColumnsNULL= (SELECT SUBSTRING(
	(SELECT ',ISNULL([' + CONVERT(varchar, replace(replace(replace(Nombre,' ','_'),'(',''),')','')   ) +'],0) as '
					+ CONVERT(varchar, replace(replace(replace(Nombre,' ','_'),'(',''),')','') )
			from [Evaluacion360].[tblCatTipoGrupo]  
			FOR XML PATH('')),2,200000))

	set @DinamicColumnsSUM= (SELECT SUBSTRING(
	(SELECT ',ISNULL(SUM([' + CONVERT(varchar, replace(replace(replace(Nombre,' ','_'),'(',''),')','')  ) +']),0) as '
					+ CONVERT(varchar, replace(replace(replace(Nombre,' ','_'),'(',''),')','') )
			from [Evaluacion360].[tblCatTipoGrupo]
			FOR XML PATH('')),2,200000))


	--select 
	--  @DinamicColumns	  = replace(@DinamicColumns,'(','')
	-- ,@DinamicColumnsNULL = replace(@DinamicColumnsNULL,'(','')
	-- ,@DinamicColumnsSUM  = REPLACE(@DinamicColumnsSUM,'(','')

	--select 
	--  @DinamicColumns	  = replace(@DinamicColumns,')','')
	-- ,@DinamicColumnsNULL = replace(@DinamicColumnsNULL,')','')
	-- ,@DinamicColumnsSUM  = REPLACE(@DinamicColumnsSUM,')','')


	--print @DinamicColumns
	--print @DinamicColumnsNULL
	--print @DinamicColumnsSUM

	if object_id('tempdb..#tempDatos') is not null drop table #tempDatos;
	if object_id('tempdb..#tempEstadisticosHistoria') is not null drop table #tempEstadisticosHistoria;
	
	CREATE TABLE #tempEstadisticosHistoria(
		Proyecto varchar(50)
		,Competencia decimal(10,2)
		,KPI decimal(10,2)
		,Valor decimal(10,2)
	);

	insert @dtProyectos
	exec [evaluacion360].[spBuscarProyectos]

	SELECT
		e.IDEmpleadoProyecto
		,tep.IDProyecto
		,substring(tcp.Nombre,1,50) AS Proyecto
		,tctg.IDTipoGrupo
		,tctg.Nombre AS TipoGrupo
		,cast(SUM(cg.Porcentaje) / count(cg.IDGrupo) AS decimal(10,2)) AS Porcentaje
		--,Escala = case when cg.IDTipoPreguntaGrupo = 3 then STUFF(
		--														(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), Nombre) 
		--															FROM [Evaluacion360].[tblEscalasValoracionesGrupos] 
		--															WHERE IDGrupo = cg.IDGrupo 
		--															FOR xml path('')
		--														)
		--														, 1
		--														, 1
		--														, '')
		--				when cg.IDTipoPreguntaGrupo = 2 then STUFF(
		--														(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), Nombre) 
		--															FROM [Evaluacion360].[tblEscalasValoracionesProyectos] tevp 
		--															WHERE tevp.IDProyecto = tep.IDProyecto 
		--															FOR xml path('')
		--														)
		--														, 1
		--														, 1
		--														, '')
		--														else null end
		--,GrupoEscala = case when exists (select top 1 1 
		--								from [Evaluacion360].[tblCatPreguntas] 
		--								where IDGrupo = cg.IDGrupo and (IDTipoPregunta = @TipoPreguntaEscala) /*Escala*/)
		--					then cast(1 as bit) else cast(0 as bit) end
 	INTO #tempDatos
	from Evaluacion360.tblEmpleadosProyectos tep 
		join  Evaluacion360.tblEvaluacionesEmpleados e on tep.IDEmpleadoProyecto = e.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatGrupos] cg on cg.IDReferencia = e.IDEvaluacionEmpleado and cg.TipoReferencia = 4
		JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
		JOIN @dtProyectos tcp ON tep.IDProyecto = tcp.IDProyecto and tcp.IDEstatus = 6 --(Solo proyecto completos)
	where cg.IDTipoPreguntaGrupo in (2,3) AND tep.IDEmpleado = @IDEmpleado
	GROUP BY e.IDEmpleadoProyecto
		,tep.IDProyecto
		,tcp.Nombre
		,tctg.IDTipoGrupo
		,tctg.Nombre

	set @query = N'SELECT  Proyecto,' + @DinamicColumnsSUM + ' from 
             (
				SELECT Proyecto, TipoGrupo, Porcentaje  
			FROM #tempDatos
            ) x
            pivot 
            (
                SUM(Porcentaje) 
                for TipoGrupo in (' + @DinamicColumns + ')
            ) p 	group by Proyecto '
	
	print(@query)
	insert #tempEstadisticosHistoria(Proyecto,Competencia,KPI,Valor)
	execute(@query)

	SELECT * FROM #tempEstadisticosHistoria
GO

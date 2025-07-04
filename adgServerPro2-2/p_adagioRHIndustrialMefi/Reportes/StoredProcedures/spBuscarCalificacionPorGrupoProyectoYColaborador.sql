USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar Calificaciones por grupo
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-07
** Paremetros		:    
	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder


     
	 Cuando el campo TipoReferencia vale 0 (Catálogo) entonces IDReferencia también vale 0     
	 NOTA: Si se modifican los campos del ResultSet de este SP se deben modificar los siguientes SP's:
		[Reportes].[spBuscarCalificacionPorGrupoProyectoFiltros]

	 exec [Reportes].[spBuscarCalificacionPorGrupoProyectoYColaborador] 36,20310,1,0 110080
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
----***************************************************************************************************/
CREATE proc [Reportes].[spBuscarCalificacionPorGrupoProyectoYColaborador](
	@IDProyecto int 
	,@IDEmpleado int
	,@IDUsuario int
	,@IDEvaluacionEmpleado int = 0
) as

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	 declare 
		--@IDProyecto int = 36
		--,@IDEmpleado int = 20310
		--,
		@IDEmpleadoProyecto int = 0
		,@MaxValorEscalaValoracion decimal(10,1) = 0.0
		,@TipoPreguntaEscala int = 8 /* 8: Escala proyecto | 9: Escala Grupo*/

		;

	SELECT @IDEmpleadoProyecto = tep.IDEmpleadoProyecto 
	FROM Evaluacion360.tblEmpleadosProyectos tep 
	WHERE tep.IDProyecto = @IDProyecto and IDEmpleado = @IDEmpleado

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL drop table #tempHistorialEstatusEvaluacion;
	if object_id('tempdb..#tempEvaluacionesCompletas') is not null drop table #tempEvaluacionesCompletas;
	if object_id('tempdb..#tempEstadisticos') is not null drop table #tempEstadisticos;
	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;

	SELECT
		e.IDEmpleadoProyecto
		,cg.*
		,tctg.Nombre AS TipoGrupo
		,Escala = case when cg.IDTipoPreguntaGrupo = 3 then STUFF(
																(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), ltrim(rtrim(Nombre))) 
																	FROM [Evaluacion360].[tblEscalasValoracionesGrupos] 
																	WHERE IDGrupo = cg.IDGrupo 
																	FOR xml path('')
																)
																, 1
																, 1
																, '')
						when cg.IDTipoPreguntaGrupo = 2 then STUFF(
																(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100),  ltrim(rtrim(Nombre))) 
																	FROM [Evaluacion360].[tblEscalasValoracionesProyectos] tevp 
																	WHERE tevp.IDProyecto = tep.IDProyecto 
																	FOR xml path('')
																)
																, 1
																, 1
																, '')
																else null end
		--,GrupoEscala = case when exists (select top 1 1 
		--								from [Evaluacion360].[tblCatPreguntas] 
		--								where IDGrupo = cg.IDGrupo and (IDTipoPregunta = @TipoPreguntaEscala) /*Escala*/)
		--					then cast(1 as bit) else cast(0 as bit) end
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join  Evaluacion360.tblEvaluacionesEmpleados e on cg.IDReferencia = e.IDEvaluacionEmpleado
		JOIN Evaluacion360.tblEmpleadosProyectos tep ON e.IDEmpleadoProyecto = tep.IDEmpleadoProyecto
		JOIN [Evaluacion360].[tblCatTipoGrupo] tctg	ON cg.IDTipoGrupo = tctg.IDTipoGrupo
	where (cg.TipoReferencia = 4) 
		AND cg.IDTipoPreguntaGrupo in (2,3) 
		AND tep.IDEmpleadoProyecto = @IDEmpleadoProyecto
		-- AND (e.IDEvaluacionEmpleado = @IDEvaluacionEmpleado OR @IDEvaluacionEmpleado = 0 )
	
	select  
		g.IDEmpleadoProyecto
		,g.IDTipoGrupo
		,g.TipoGrupo
		,SUM(isnull(g.TotalPreguntas,0.0)) AS TotalPreguntas
		,MAX(isnull(g.MaximaCalificacionPosible,0.0)) AS MaximaCalificacionPosible
		,cast(SUM(isnull(g.CalificacionObtenida,0.0)) / count(g.IDTipoGrupo) AS decimal(10,1)) AS CalificacionObtenida
		,MIN(isnull(g.CalificacionMinimaObtenida,0.0)) as CalificacionMinimaObtenida
		,MAX(isnull(g.CalificacionMaxinaObtenida,0.0)) as CalificacionMaxinaObtenida
		,cast(SUM(isnull(g.Porcentaje,0.0)) / count(g.IDTipoGrupo) AS decimal(10,1)) AS Porcentaje
		,cast(SUM(isnull(g.Promedio,0.0)) / count(g.IDTipoGrupo) AS decimal(10,1)) AS Promedio
		,g.Escala
	from #tempGrupos g
--	WHERE g.IDTipoPreguntaGrupo = 2
	GROUP BY g.IDEmpleadoProyecto
		,g.IDTipoGrupo
		,g.TipoGrupo
		,g.Escala
GO

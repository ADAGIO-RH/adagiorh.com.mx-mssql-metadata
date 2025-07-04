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

	@TipoInfo: 
		0 : Como Evaluado
		1 : Como Evaluador

	 exec [Reportes].[spBuscarCalificacionPorGrupoProyectoFiltros]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
--***************************************************************************************************/
CREATE proc [Reportes].[spBuscarCalificacionPorGrupoProyectoFiltros](
	@IDProyecto int 
	,@dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario int
	,@TipoInfo int = 0 
) as
	declare @dtProyectos [Evaluacion360].[dtProyectos]
	;
--DECLARE @IDProyecto int = 36,
--		@dtFiltros [Nomina].[dtFiltrosRH],
--		@IDUsuario int = 1,
--		@TipoInfo int = 0

--	INSERT @dtFiltros(Catalogo, [Value])
--	values('Empleados','20310')
--		 ,('Empleados','9')


	SET NOCOUNT ON;
    IF 1=0 BEGIN
		SET FMTONLY OFF
    END

	if object_id('tempdb..#tempEmpleadosProyectos') is not NULL
			drop table #tempEmpleadosProyectos;

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not NULL
			drop table #tempHistorialEstatusEvaluacion;
  
	if object_id('tempdb..#tempEstadisticosLocal') is not null
			drop table #tempEstadisticosLocal;

	CREATE TABLE #tempEstadisticosLocal(
			 IDEmpleadoProyecto	 int
			,IDTipoGrupo 		 int
			,TipoGrupo			 varchar(255)
			,TotalPreguntas  decimal(10,2)
			,MaximaCalificacionPosible    decimal(10,1)
 			,CalificacionObtenida		  decimal(10,1)
			,CalificacionMinimaObtenida	  decimal(10,1)
			,CalificacionMaxinaObtenida	  decimal(10,1)
			,Porcentaje  decimal(10,1)
			,Promedio  decimal(10,1)
			,Escala varchar(max)
	);

	 -- Proyectos Completos:
	-- IF object_id('tempdb..#p') IS NOT NULL DROP TABLE #p;

	--CREATE TABLE #p (
	--	 IDProyecto int
	--	,Nombre varchar(max)
	--	,Descripcion varchar(max)
	--	,IDEstatus int
	--	,Estatus varchar(max)
	--	,FechaCreacion datetime
	--	,IDUsuario int
	--	,Usuario  varchar(max)
	--	,AutoEvaluacion bit
	--	,TotalPruebasARealizar	int
	--	,TotalPruebasRealizadas	int
	--	,Progreso	int
	--	,FechaInicio	date
	--	,FechaFin	date
	--	,Calendarizado	bit
	--	,IDTask	int
	--	,IDSchedule	int
	--);

	--INSERT #p
	insert @dtProyectos
	EXEC [Evaluacion360].[spBuscarProyectos] @IDUsuario = @IDUsuario


	IF object_id('tempdb..#empleados') IS NOT NULL DROP TABLE #empleados;

	CREATE TABLE #empleados(
		IDEmpleado int
		,IDEvaluacionEmpleado int
	);

	IF (@TipoInfo = 0)
	BEGIN
		INSERT #empleados
		SELECT cast(Value AS int),0 
		FROM @dtFiltros 
		WHERE [@dtFiltros].Catalogo = 'Empleados'
	END ELSE IF (@TipoInfo = 1)
	BEGIN
		INSERT #empleados
		SELECT tep.IDEmpleado,tee.IDEvaluacionEmpleado
		FROM @dtProyectos pro 
			JOIN Evaluacion360.tblEmpleadosProyectos tep	ON tep.IDProyecto = pro.IDProyecto
			JOIN Evaluacion360.tblEvaluacionesEmpleados tee ON tep.IDEmpleadoProyecto = tee.IDEmpleadoProyecto
			JOIN @dtFiltros f ON tee.IDEvaluador = cast(f.Value AS int)  AND f.Catalogo = 'Empleados'
		WHERE tep.IDProyecto = @IDProyecto AND tee.IDTipoRelacion <> 4
	END;

	declare 
		@IDEmpleado int = 0,
		@IDEmpleadoProyecto int = 0,
		@IDEvaluacionEmpleado int = 0,
		@MaxValorEscalaValoracion decimal(10,1) = 0.0,
		@TipoPreguntaEscala int = 8; /* 8: Escala proyecto | 9: Escala Grupo*/

	SELECT @IDEmpleado = min(IDEmpleado) FROM #empleados  

	WHILE exists(SELECT TOP 1 1  FROM #empleados where IDEmpleado >= @IDEmpleado)
	BEGIN
		SELECT @IDEvaluacionEmpleado=IDEvaluacionEmpleado FROM #empleados e WHERE e.IDEmpleado = @IDEmpleado


		INSERT #tempEstadisticosLocal(IDEmpleadoProyecto	
			,IDTipoGrupo 	
			,TipoGrupo		
			,TotalPreguntas
			,MaximaCalificacionPosible   
 			,CalificacionObtenida		
			,CalificacionMinimaObtenida	
			,CalificacionMaxinaObtenida
			,Porcentaje
			,Promedio
			,Escala)
		EXEC [Reportes].[spBuscarCalificacionPorGrupoProyectoYColaborador]
				@IDProyecto = @IDProyecto 
				,@IDEmpleado = @IDEmpleado
				,@IDUsuario = @IDUsuario
				,@IDEvaluacionEmpleado=@IDEvaluacionEmpleado

		SELECT @IDEmpleado = min(IDEmpleado) FROM #empleados WHERE IDEmpleado > @IDEmpleado
	END  
	
	SELECT tem.IDEmpleado
		,tem.ClaveEmpleado
		,tem.Nombre+' '+coalesce(tem.SegundoNombre,'')+' '+coalesce(tem.Paterno,'')+' '+coalesce(tem.Materno,'')  AS Nombre
		,te.*
		,cast(SUMGrupos.PorcentajeGeneral AS decimal(10,1)) as PorcentajeGeneral
		,cast(SUMGrupos.PromedioGeneral AS decimal(10,1))	as PromedioGeneral
		,(SELECT count(*)
			FROM Evaluacion360.tblEmpleadosProyectos tep 
				JOIN @dtProyectos pro ON pro.IDProyecto = tep.IDProyecto AND pro.IDEstatus = 6
				JOIN Evaluacion360.tblEvaluacionesEmpleados tee ON tep.IDEmpleadoProyecto = tee.IDEmpleadoProyecto
			WHERE tep.IDEmpleado = tem.IDEmpleado) AS TotalPrueabasColaborador
	FROM #tempEstadisticosLocal te
		JOIN Evaluacion360.tblEmpleadosProyectos tep ON te.IDEmpleadoProyecto = tep.IDEmpleadoProyecto
		JOIN RH.tblEmpleadosMaster tem ON tep.IDEmpleado = tem.IDEmpleado
		LEFT JOIN (SELECT IDEmpleadoProyecto,Escala
					,sum(Porcentaje)/cast(count(IDEmpleadoProyecto) AS decimal(10,1)) AS PorcentajeGeneral
					,sum(Promedio)/cast(count(IDEmpleadoProyecto) AS decimal(10,1)) AS PromedioGeneral
				FROM #tempEstadisticosLocal
				GROUP BY IDEmpleadoProyecto
					,Escala) SUMGrupos ON te.IDEmpleadoProyecto = SUMGrupos.IDEmpleadoProyecto AND te.Escala = SUMGrupos.Escala


	--SELECT IDEmpleadoProyecto
	--	,sum(Porcentaje)/cast(count(IDEmpleadoProyecto) AS decimal(10,1)) AS PorcentajeGeneral
	--	,sum(Promedio)/cast(count(IDEmpleadoProyecto) AS decimal(10,1)) AS PromedioGeneral
	--FROM #tempEstadisticosLocal
	--GROUP BY IDEmpleadoProyecto,#tempEstadisticosLocal.Escala

--	SELECT * FROM Evaluacion360.tblEmpleadosProyectos tep WHERE tep.IDProyecto = 36
--	SELECT *
--	FROM Evaluacion360.tblEvaluacionesEmpleados tee
--	WHERE tee.IDEmpleadoProyecto IN (41250
--,41249)
GO

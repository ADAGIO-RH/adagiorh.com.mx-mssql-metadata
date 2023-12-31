USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar las Evaluaciones por proyecto, incluyendo las que aún no han sido asignadas a Evaluadores
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-11-07
** Paremetros		:              


Si se modifica el Result set de este SP se deben de actualizar los siguientes sp's: 
	[Evaluacion360].[spActualizarProgresoProyecto]
	[Evaluacion360].[spReporteTotalEvaluacionesPorEvaluadorEstatus]
****************************************************************************************************
[Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] 81,1
[Evaluacion360].[spBuscarRelacionesProyecto] 10018
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2019-05-10		Aneudy Abreu		Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarEvaluacionesEmpleadosPorProyecto] ( 
	@IDProyecto int
	,@IDUsuario int
) as

	---- Declaración de variables
	--declare 
	--	@i int = 0
	--	,@j int = 0
	--	,@Maximo int = 0
	--	,@Minimo int = 0
	--	,@IDTipoRelacion int = 0
	--	,@IDEvaluadorRequerido int = 0
	--	,@AutoevaluacionNoEsRequerida bit = 0
	--;

 ---- Autoevaluacion no es requerida
	--select @AutoevaluacionNoEsRequerida = cast(isnull(valor,0) as bit) 
	--from Evaluacion360.tblConfiguracionAvanzadaProyecto 
	--where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 9


	---- Se valida si las tablas temporales existen, en caso de que si existan se eliminan y se vuelven a crear.
	--if object_id('tempdb..#tempEmpPro') is not null drop table #tempEmpPro;
	--if object_id('tempdb..#tempEvaEmp') is not null drop table #tempEvaEmp;
	--if object_id('tempdb..#tempRequeridos') is not null drop table #tempRequeridos;
	--if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;

	--create table #tempRequeridos(
	--	IDTipoRelacion int
	--	,Codigo	varchar(20)
	--	,Relacion varchar(255)
	--	,Minimo int
	--	,Maximo int
	--);

	---- Se crean tantos registros como evaluadores máximos requeridos según las restricciones del proyecto.
	--select @IDEvaluadorRequerido=min(IDEvaluadorRequerido) from [Evaluacion360].[tblEvaluadoresRequeridos]  WHERE IDProyecto = @IDProyecto

	--while exists(select top 1 1 
	--			from [Evaluacion360].[tblEvaluadoresRequeridos]  
	--			WHERE IDProyecto = @IDProyecto AND IDEvaluadorRequerido >= @IDEvaluadorRequerido)
	--begin
	--	select 
	--		@IDTipoRelacion = IDTipoRelacion
	--		,@Maximo = Maximo
	--		,@Minimo = Minimo
	--	from [Evaluacion360].[tblEvaluadoresRequeridos] 
	--	where IDEvaluadorRequerido = @IDEvaluadorRequerido
		
	--	set @j = 1;
	--	while @j <= @Maximo
	--	begin
	--		insert into #tempRequeridos(IDTipoRelacion,Minimo,Maximo)
	--		select @IDTipoRelacion,@Minimo,@Maximo

	--		set @j = @j + 1;
	--	end;
		
	--	select @IDEvaluadorRequerido=min(IDEvaluadorRequerido) 
	--	from [Evaluacion360].[tblEvaluadoresRequeridos]  
	--	WHERE IDProyecto = @IDProyecto  AND IDEvaluadorRequerido > @IDEvaluadorRequerido
	--end;
	

	---- Se actualiza el nombre del tipo de relación y el Código
	--update er
	--set er.Relacion = cte.Relacion
	--	,er.Codigo = cte.Codigo 
	--from [Evaluacion360].[tblCatTiposRelaciones] cte
	--	join #tempRequeridos er on cte.IDTipoRelacion = er.IDTipoRelacion

	---- Se crea la tabla temporal #tempEmpPro haciendo un cross join con la tabla #tempRequeridos 
	---- para que se múltipliquen los registros según correspondan con las restricciones del proyecto
	--select  
	--	ep.IDEmpleadoProyecto
	--	,ep.IDProyecto
	--	,ep.IDEmpleado
	--	,e.ClaveEmpleado
	--	,e.NOMBRECOMPLETO as Colaborador
	--	,0 as IDEvaluacionEmpleado
	--	,isnull(req.IDTipoRelacion,0) as IDTipoRelacion
	--	,req.Relacion
	--	,0 as IDEvaluador
	--	,cast('' as varchar(20)) ClaveEvaluador
	--	,cast('' as varchar(255)) as Evaluador
	--	--,cast(0 as bit) as Completo
	--	,req.Minimo
	--	,req.Maximo
	--	,Requerido = 
	--	case 
	--		when req.IDTipoRelacion = 4 and @AutoevaluacionNoEsRequerida = 0 then cast(1 as bit) 
	--		when (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo) and 
	--			(ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= isnull(totalRelaciones.Total,0)) then cast(1 as bit) else cast(0 as bit) end
	--		--case when ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion 
	--		--		order by ep.IDEmpleado,req.IDTipoRelacion) <= Minimo then cast(1 as bit) else cast(0 as bit) end
	--	,CumpleTipoRelacion = case 
	--			when req.IDTipoRelacion = 4 then cast(1 as bit)
	--			when (ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) <= isnull(totalRelaciones.Total,0)) then cast(1 as bit) else cast(0 as bit) end
	--	,ROW_NUMBER()over(partition by ep.IDEmpleado,req.IDTipoRelacion order by ep.IDEmpleado,req.IDTipoRelacion) as [Row]
	--INTO #tempEmpPro
	--from [Evaluacion360].[tblEmpleadosProyectos] ep 
	----	left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	--	join [RH].[tblEmpleadosMaster] e on ep.IDEmpleado = e.IDEmpleado
	--	join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
	--	cross join  #tempRequeridos req  --on ee.IDTipoRelacion = req.IDTipoRelacion
	--	left join RH.tblTotalRelacionesEmpleados totalRelaciones on totalRelaciones.IDEmpleado = ep.IDEmpleado and req.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	--where ep.IDProyecto = @IDProyecto

	--delete from #tempEmpPro where CumpleTipoRelacion = 0

	--select ee.IDEvaluacionEmpleado
	--	,ep.IDEmpleadoProyecto
	--	,ee.IDTipoRelacion
	--	,ee.IDEvaluador
	--	,ep.IDProyecto
	--	,ep.IDEmpleado
	--	--,e.NOMBRECOMPLETO as Evaluador
	--	,ROW_NUMBER()over(partition by ep.IDEmpleado,ee.IDTipoRelacion order by ep.IDEmpleado,ee.IDTipoRelacion) as [Row]
	--INTO #tempEvaEmp
	--from  [Evaluacion360].[tblEvaluacionesEmpleados] ee
	--	left join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	--	--left join [Evaluacion360].[tblEvaluacionesEmpleados] ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
	--	--									and ee.IDTipoRelacion = emp.IDTipoRelacion
	--	--								--	and ee.[Row] = emp.[Row]
	--	--left join [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado	
	--	where ep.IDProyecto = @IDProyecto

	--update emp
	--set emp.IDEvaluador = isnull(ee.IDEvaluador,0)
	-- 	,emp.Evaluador = isnull(e.NOMBRECOMPLETO,'[Sin evaluador asignado]')
	--	,emp.ClaveEvaluador = isnull(e.ClaveEmpleado,'[00000]')
	--	,emp.IDEvaluacionEmpleado = isnull(ee.IDEvaluacionEmpleado,0) 
	--	--,emp.Completo = case when emp.[Row] >= Maximo and isnull(ee.IDEvaluacionEmpleado,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
	--from #tempEmpPro emp
	--	left join #tempEvaEmp ee  on ee.IDEmpleadoProyecto = emp.IDEmpleadoProyecto 
	--										and ee.IDTipoRelacion = emp.IDTipoRelacion and emp.[Row] = ee.[Row]
	--	left join [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado


	----declare @dtEvaluadoresRequeridos [Evaluacion360].[dtEvaluadoresRequeridos]

	----insert @dtEvaluadoresRequeridos
	----exec [Evaluacion360].[spBuscarRelacionesProyecto]
	----	@IDProyecto = @IDProyecto,
	----	@IDUsuario  = @IDUsuario

	DECLARE @i INT = 0,
			@j INT = 0,
			@IDTipoRelacion INT = 0,
			@Maximo INT = 0,
			@Minimo INT = 0,
			@AutoevaluacionNoEsRequerida BIT = 0,
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;


	-- AUTOEVALUACION NO ES REQUERIDA
	SELECT @AutoevaluacionNoEsRequerida = CAST(ISNULL(valor, 0) AS BIT) 
	FROM Evaluacion360.tblConfiguracionAvanzadaProyecto WITH(NOLOCK)
	WHERE IDProyecto = @IDProyecto AND IDConfiguracionAvanzada = 9

	IF OBJECT_ID('tempdb..#tempRequeridos') IS NOT NULL DROP TABLE #tempRequeridos;

	CREATE TABLE #tempRequeridos(
		IDTipoRelacion INT,
		Codigo VARCHAR(20),
		Relacion VARCHAR(255),
		Minimo INT,
		Maximo INT
	);
	
	SELECT @i = MIN(IDTipoRelacion) FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK) WHERE IDProyecto = @IDProyecto

	WHILE EXISTS(SELECT TOP 1 1 FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK) WHERE IDProyecto = @IDProyecto AND IDTipoRelacion >= @i)
	BEGIN
		SELECT @IDTipoRelacion = IDTipoRelacion,
				@Maximo = Maximo,
				@Minimo = Minimo
		FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK)
		WHERE IDProyecto = @IDProyecto AND
				IDTipoRelacion = @i 
		
		SET @j = 1;
		WHILE @j <= @Maximo
		BEGIN
			INSERT INTO #tempRequeridos(IDTipoRelacion, Minimo, Maximo)
			SELECT @IDTipoRelacion, @Minimo,@Maximo
			SET @j = @j + 1;
		END;

		SELECT @i = MIN(IDTipoRelacion)
		FROM [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK)
		WHERE IDProyecto = @IDProyecto AND IDTipoRelacion > @i
	END;

	UPDATE ER 
		SET 
			ER.Relacion = CTE.Relacion,
			ER.Codigo	= CTE.Codigo 
	FROM [Evaluacion360].[tblCatTiposRelaciones] CTE WITH (NOLOCK)
		JOIN #tempRequeridos ER ON CTE.IDTipoRelacion = ER.IDTipoRelacion

	IF OBJECT_ID('tempdb..#tempEmpPro') IS NOT NULL DROP TABLE #tempEmpPro;
		
	SELECT EP.IDEmpleadoProyecto,
		   EP.IDProyecto,
		   EP.IDEmpleado,
		   E.ClaveEmpleado,
		   E.NOMBRECOMPLETO as Colaborador,
		   0 AS IDEvaluacionEmpleado,
		   ISNULL(REQ.IDTipoRelacion,0) AS IDTipoRelacion,
		   REQ.Relacion,
		   REQ.Minimo,
		   REQ.Maximo,
		   0 AS IDEvaluador,
		   cast('' as varchar(20)) ClaveEvaluador,
		   CAST('' AS VARCHAR(255)) AS Evaluador,
		   CAST(0 as bit) as Requerido,
		   CAST(0 as bit) as CumpleTipoRelacion,
		   --Requerido = CASE 
					--	WHEN REQ.IDTipoRelacion = 4 AND @AutoevaluacionNoEsRequerida = 0 
					--		THEN CAST(1 AS BIT) 
					--	WHEN (ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, REQ.IDTipoRelacion ORDER BY EP.IDEmpleado, REQ.IDTipoRelacion) <= Minimo) AND
					--		 (ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado,REQ.IDTipoRelacion ORDER BY EP.IDEmpleado, REQ.IDTipoRelacion) <= ISNULL(totalRelaciones.Total, 0)) 
					--		THEN CAST(1 AS BIT)
					--		ELSE CAST(0 AS BIT) 
					--   END,
		   --CumpleTipoRelacion = CASE 
					--				WHEN REQ.IDTipoRelacion = 4 
					--					THEN 1
					--				WHEN (ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, REQ.IDTipoRelacion ORDER BY EP.IDEmpleado, REQ.IDTipoRelacion) <= ISNULL(totalRelaciones.Total, 0)) 
					--					THEN CAST(1 AS BIT) 
					--				ELSE CAST(0 AS BIT)
					--			END,
		   ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, REQ.IDTipoRelacion ORDER BY EP.IDEmpleado,REQ.IDTipoRelacion) AS [Row]
	INTO #tempEmpPro
	FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
		JOIN [RH].[tblEmpleadosMaster] E WITH (NOLOCK) ON EP.IDEmpleado = E.IDEmpleado
		INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE WITH (NOLOCK) ON DFE.IDEmpleado = E.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		CROSS JOIN #tempRequeridos REQ
		--LEFT JOIN RH.tblTotalRelacionesEmpleados totalRelaciones WITH (NOLOCK) ON totalRelaciones.IDEmpleado = EP.IDEmpleado AND REQ.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	WHERE (EP.IDProyecto = @IDProyecto OR isnull(@IDProyecto, 0) = 0)

	update temp 
		set 
			Requerido = CASE 
							-- 4 = AUTOEVALUACIÓN
							WHEN temp.IDTipoRelacion = 4 AND @AutoevaluacionNoEsRequerida = 0			THEN CAST(1 AS BIT) 
							-- 6 = CLIENTE INTERNO
							WHEN temp.IDTipoRelacion = 6 AND [Row] <= temp.Minimo						THEN CAST(1 AS BIT) 
							WHEN ([Row] <= temp.Minimo) AND ([Row] <= ISNULL(totalRelaciones.Total, 0)) THEN CAST(1 AS BIT)
						ELSE 
							CAST(0 AS BIT) 
						END,
		   CumpleTipoRelacion = CASE 
									-- 4 = AUTOEVALUACIÓN
									-- 6 = CLIENTE INTERNO
									WHEN temp.IDTipoRelacion in (4,6)						THEN 1
									WHEN ([Row] <= ISNULL(totalRelaciones.Total, 0))	THEN CAST(1 AS BIT) 
								ELSE 
									CAST(0 AS BIT)
								END
	from #tempEmpPro temp
		LEFT JOIN RH.tblTotalRelacionesEmpleados totalRelaciones WITH (NOLOCK) ON totalRelaciones.IDEmpleado = temp.IDEmpleado AND temp.IDTipoRelacion = totalRelaciones.IDTipoRelacion

	DELETE FROM #tempEmpPro WHERE CumpleTipoRelacion = 0

	IF OBJECT_ID('tempdb..#tempEvaEmp') IS NOT NULL DROP TABLE #tempEvaEmp;

	SELECT EE.IDEvaluacionEmpleado,
		   EP.IDEmpleadoProyecto,
		   EE.IDTipoRelacion,
		   EE.IDEvaluador,
		   EP.IDProyecto,
		   EP.IDEmpleado,
		   E.NOMBRECOMPLETO AS Evaluador,
		   ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, EE.IDTipoRelacion ORDER BY EP.IDEmpleado, EE.IDTipoRelacion) AS [Row]
	INTO #tempEvaEmp
	FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE WITH (NOLOCK)
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		LEFT JOIN [RH].[tblEmpleadosMaster] E WITH (NOLOCK) ON EE.IDEvaluador = E.IDEmpleado	
	WHERE EP.IDProyecto = @IDProyecto
	ORDER BY EE.IDEvaluacionEmpleado ASC

	UPDATE EMP 
		SET 
			EMP.IDEvaluador = ISNULL(EE.IDEvaluador, 0),
			EMP.Evaluador = ISNULL(EE.Evaluador, '[Sin evaluador asignado]'),
			EMP.ClaveEvaluador = isnull(e.ClaveEmpleado,'[00000]'),
			EMP.IDEvaluacionEmpleado = ISNULL(EE.IDEvaluacionEmpleado, 0)
	FROM #tempEmpPro EMP
		LEFT JOIN #tempEvaEmp EE ON EE.IDEmpleadoProyecto = EMP.IDEmpleadoProyecto AND EE.IDTipoRelacion = EMP.IDTipoRelacion AND EMP.[Row] = EE.[Row]
		LEFT JOIN [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado

	--UPDATE EMP 
	--	SET 
	--		EMP.IDEvaluador = ISNULL(EE.IDEvaluador, 0),
	--		EMP.Evaluador = ISNULL(EE.Evaluador, '[Sin evaluador asignado]'),
	--		EMP.IDEvaluacionEmpleado = ISNULL(EE.IDEvaluacionEmpleado, 0) 
	--FROM #tempEmpPro EMP
	--	LEFT JOIN #tempEvaEmp EE ON EE.IDEmpleadoProyecto = EMP.IDEmpleadoProyecto AND EE.IDTipoRelacion = EMP.IDTipoRelacion AND EMP.[Row] = EE.[Row]

	DECLARE @tempResponse AS TABLE (
			IDEmpleadoProyecto INT,
		    IDProyecto INT,
		    IDEmpleado INT,
			ClaveEmpleado VARCHAR(20),
		    Colaborador VARCHAR(254),
		    IDEvaluacionEmpleado INT,
		    IDTipoRelacion INT,
		    Relacion VARCHAR(100),
		    IDEvaluador INT,
			ClaveEvaluador VARCHAR(20),
		    Evaluador  VARCHAR(100),
		    Minimo INT,
		    Maximo INT,
		    Requerido BIT,
			Evaluar BIT
	);

	INSERT @tempResponse
	SELECT IDEmpleadoProyecto,
		   IDProyecto,
		   IDEmpleado,
		   ClaveEmpleado,
		   Colaborador,
		   IDEvaluacionEmpleado,
		   IDTipoRelacion,
		   Relacion,
		   IDEvaluador,
		   ClaveEvaluador,
		   Evaluador,
		   Minimo, 
		   Maximo,
		   Requerido,
		   CASE 
				WHEN IDTipoRelacion = 4
					THEN 0
					ELSE 1
				END AS Evaluar
	FROM #tempEmpPro
		  	

	--#tempHistorialEstatusEvaluacion
	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
	where ep.IDProyecto = @IDProyecto 

	select ep.* 
		,isnull(thee.IDEstatusEvaluacionEmpleado,0) IDEstatusEvaluacionEmpleado
		,isnull(thee.IDEstatus,0) IDEstatus
		,isnull(estatus.Estatus,'Sin estatus') Estatus
		,isnull(Progreso,0) as Progreso --= case when isnull(thee.IDEstatus,0) != 0 then floor(RAND()*(100-0)+0) else 0 end
	from @tempResponse ep 
		left join #tempHistorialEstatusEvaluacion thee on ep.IDEvaluacionEmpleado = thee.IDEvaluacionEmpleado and thee.[ROW]  = 1
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
		
	order by Colaborador,Evaluador desc

	--SELECT floor(RAND()*(100-0)+0);

	--select *
	--from [Evaluacion360].[tblEstatusEvaluacionEmpleado]
	--order by IDEvaluacionEmpleado
GO

USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las posibles evaluaciones del proyecto según las restrucciones que cumplan los colaboradores
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de este sp será necesario modificar los siguientes sp's:
		- [Evaluacion360].[spAsignacionAutomaticaEvaluadores]
		- [Evaluacion360].[spReporteBuscarRelacionesProyecto]
		- [Reportes].[spBuscarCalificacionesGruposPorProyecto]

	exec [Evaluacion360].[spBuscarRelacionesProyecto]
		@IDProyecto	= 35,
		@IDUsuario	= 1

	exec Evaluacion360.spBuscarEvaluacionesEmpleadosPorProyecto
		@IDProyecto	= 35,
		@IDUsuario	= 1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			    Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	    Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									    Seguridad.tblDetalleFiltrosEmpleadosUsuarios
2022-09-12			Alejandro Paredes   Se agregó la paginación
2022-10-19			Aneudy Abreu		Validaciones del nuevo tipo de relacion CLIENTE INTERNO (6 - 06)
***************************************************************************************************/
CREATE PROC [Evaluacion360].[spBuscarRelacionesProyecto] (
	@IDEmpleado		INT = 0,
	@IDEvaluador	INT = 0,
	@IDProyecto		INT,
	@IDUsuario	INT,
	@PageNumber	INT = 1,
	@PageSize	INT = 2147483647,
	@orderByColumn	VARCHAR(50) = '',
	@orderDirection VARCHAR(4) = ''
) AS
	
	SET FMTONLY OFF

	DECLARE @i INT = 0,
			@j INT = 0,
			@IDTipoRelacion INT = 0,
			@Maximo INT = 0,
			@Minimo INT = 0,
			@AutoevaluacionNoEsRequerida BIT = 0,
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;


	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SELECT 
		@orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'IDTipoRelacion' ELSE @orderByColumn END,
		@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

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
				@Minimo = Minimo,
				@Maximo = case 
							when isnull(@IDEmpleado, 0) != 0 and (select count(*) 
									from Evaluacion360.tblEmpleadosProyectos ep
										join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
									where ep.IDEmpleado = @IDEmpleado and ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion = er.IDTipoRelacion)
									> er.Maximo then (select count(*) 
									from Evaluacion360.tblEmpleadosProyectos ep
										join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
									where ep.IDEmpleado = @IDEmpleado and ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion = er.IDTipoRelacion)
							when (
									select max(total)
									from (
										select ee.IDEmpleadoProyecto, count(*) total
										from Evaluacion360.tblEmpleadosProyectos ep
											join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
										where ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion =  er.IDTipoRelacion
										group by ee.IDEmpleadoProyecto
									) info
								)
									> er.Maximo then 
								(
									select max(total)
									from (
										select ee.IDEmpleadoProyecto, count(*) total
										from Evaluacion360.tblEmpleadosProyectos ep
											join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
										where ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion =  er.IDTipoRelacion
										group by ee.IDEmpleadoProyecto
									) info
								)
							when isnull(@IDEmpleado, 0) = 0 then er.Maximo							
						else er.Maximo end
		FROM [Evaluacion360].[tblEvaluadoresRequeridos] er WITH (NOLOCK)
		WHERE er.IDProyecto = @IDProyecto AND
				er.IDTipoRelacion = @i 
		
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
	
		   ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, REQ.IDTipoRelacion ORDER BY EP.IDEmpleado,REQ.IDTipoRelacion) AS [Row]
	INTO #tempEmpPro
	FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
		JOIN [RH].[tblEmpleadosMaster] E WITH (NOLOCK) ON EP.IDEmpleado = E.IDEmpleado
		INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE WITH (NOLOCK) ON DFE.IDEmpleado = E.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		CROSS JOIN #tempRequeridos REQ
		--LEFT JOIN RH.tblTotalRelacionesEmpleados totalRelaciones WITH (NOLOCK) ON totalRelaciones.IDEmpleado = EP.IDEmpleado AND REQ.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	WHERE (EP.IDEmpleado = @IDEmpleado OR @IDEmpleado = 0) AND
		  (EP.IDProyecto = @IDProyecto OR @IDProyecto = 0)

	update temp 
		set 
			Requerido = CASE 
							-- 4 = AUTOEVALUACIÓN
							WHEN temp.IDTipoRelacion = 4 AND @AutoevaluacionNoEsRequerida = 0			THEN CAST(1 AS BIT) 
							-- 6 = CLIENTE INTERNO
							WHEN temp.IDTipoRelacion = 6 AND [Row] <= temp.Minimo						THEN CAST(1 AS BIT) 
							--WHEN ([Row] <= (
							--		select count(*) 
							--		from Evaluacion360.tblEvaluacionesEmpleados ee
							--		where ee.IDEmpleadoProyecto = temp.IDEmpleadoProyecto and ee.IDTipoRelacion = temp.IDTipoRelacion
							--)) THEN CAST(1 as BIT)
							WHEN ([Row] <= temp.Minimo) AND ([Row] <= ISNULL(totalRelaciones.Total, 0)) THEN CAST(1 AS BIT)
						ELSE 
							CAST(0 AS BIT) 
						END,
		   CumpleTipoRelacion = CASE 
									-- 4 = AUTOEVALUACIÓN
									-- 6 = CLIENTE INTERNO
									WHEN temp.IDTipoRelacion in (4,6)						THEN 1
									WHEN ([Row] <= (
											select count(*) 
											from Evaluacion360.tblEvaluacionesEmpleados ee
											where ee.IDEmpleadoProyecto = temp.IDEmpleadoProyecto and ee.IDTipoRelacion = temp.IDTipoRelacion
									)) THEN CAST(1 as BIT)
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
		   ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, EE.IDTipoRelacion ORDER BY EP.IDEmpleado, EE.IDTipoRelacion, isnull(ee.IDEvaluador, 9999)) AS [Row]
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
		LEFT JOIN #tempEvaEmp EE ON EE.IDEmpleadoProyecto = EMP.IDEmpleadoProyecto 
			AND EE.IDTipoRelacion = EMP.IDTipoRelacion AND EMP.[Row] = EE.[Row]
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
	WHERE (IDEmpleado = @IDEmpleado OR @IDEmpleado = 0) AND
		  (IDEvaluador = @IDEvaluador OR @IDEvaluador = 0)
		  		  
		  		   
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM @tempResponse

	SELECT @TotalRegistros = CAST(COUNT([IDEmpleadoProyecto]) AS DECIMAL(18,2)) FROM @tempResponse

	SELECT *,
			TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
			CAST(@TotalRegistros AS INT) AS TotalRows
	FROM @tempResponse
	ORDER BY
		CASE WHEN @orderByColumn = 'IDTipoRelacion'	and @orderDirection = 'asc'	THEN IDTipoRelacion END,
		CASE WHEN @orderByColumn = 'IDTipoRelacion'	and @orderDirection = 'desc' THEN IDTipoRelacion END DESC,
		CASE WHEN @orderByColumn = 'IDEvaluacionEmpleado'	and @orderDirection = 'asc'	THEN IDEvaluacionEmpleado END,
		CASE WHEN @orderByColumn = 'IDEvaluacionEmpleado'	and @orderDirection = 'desc' THEN IDEvaluacionEmpleado END DESC,
		CASE WHEN @orderByColumn = 'Requerido' and @orderDirection = 'asc'	THEN Requerido END,
		CASE WHEN @orderByColumn = 'Requerido' and @orderDirection = 'desc' THEN Requerido END DESC,
		IDTipoRelacion, IDEvaluacionEmpleado DESC, Requerido
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

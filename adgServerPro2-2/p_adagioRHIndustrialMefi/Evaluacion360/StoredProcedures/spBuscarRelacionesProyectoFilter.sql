USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las posibles evaluaciones del proyecto según las restrucciones que cumplan los colaboradores
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2023-06-08
** Paremetros		:              
	@Requeridas: 
		0 - TODAS
		1 - SOLO REQUERIDAS
		2 - NO REQUERIDAS
** DataTypes Relacionados: 

	Si se modifica el result set de este sp será necesario modificar los siguientes sp's:
	

	exec [Evaluacion360].[spBuscarRelacionesProyectoFilter] @IDProyecto=121,@IDUsuario=1,@PageSize=50,@query='0001'
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			    Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   PROC [Evaluacion360].[spBuscarRelacionesProyectoFilter] (
	@IDEmpleado		INT = 0,
	@IDEvaluador	INT = 0,
	@IDProyecto		INT,
	@IDEstatusEvaluacion INT = 0,
	@Requeridas int = 0,
	@IDTipoRelacion int = 0,
	@IDUsuario	INT,
	@PageNumber	INT = 1,
	@PageSize	INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = '',
	@orderDirection VARCHAR(4) = ''
) AS
	
	SET FMTONLY OFF

	SET LANGUAGE 'spanish'

	DECLARE 
		@i INT = 0,
		@j INT = 0,
		@IDTipoRelacion_while INT = 0,
		@Maximo INT = 0,
		@Minimo INT = 0,
		@AutoevaluacionNoEsRequerida BIT = 0,
		@TotalPaginas INT = 0,
		@TotalRegistros DECIMAL(18,2) = 0.00,
		@IDTipoProyecto int,
		@ID_TIPO_PROYECTO_DESEMPENIO int = 2,		
		@ID_TIPO_RELACION_JEFE_DIRECTO int = 1,
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

	IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
	IF(ISNULL(@PageSize, 0) = 0) SET @PageSize = 2147483647;

	SET @query = CASE
		WHEN @query IS NULL THEN '""'
		WHEN @query = '' THEN '""'
		WHEN @query = '""' THEN @query
	ELSE '"' + @query + '*"' END

	SELECT 
		@orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'IDTipoRelacion' ELSE @orderByColumn END,
		@orderDirection = CASE WHEN @orderDirection IS NULL THEN 'ASC' ELSE @orderDirection END

	-- AUTOEVALUACION NO ES REQUERIDA
	SELECT @AutoevaluacionNoEsRequerida = CAST(ISNULL(valor, 0) AS BIT) 
	FROM Evaluacion360.tblConfiguracionAvanzadaProyecto WITH(NOLOCK)
	WHERE IDProyecto = @IDProyecto AND IDConfiguracionAvanzada = 9

	select @IDTipoProyecto = IDTipoProyecto
	from Evaluacion360.tblCatProyectos
	where IDProyecto = @IDProyecto

	IF OBJECT_ID('tempdb..#tempRequeridos') IS NOT NULL DROP TABLE #tempRequeridos;
	IF OBJECT_ID('tempdb..#tempEmpPro') IS NOT NULL DROP TABLE #tempEmpPro;
	IF OBJECT_ID('tempdb..#tempHistorialEstatusEvaluacion') is not null drop table #tempHistorialEstatusEvaluacion;
	IF OBJECT_ID('tempdb..#tempLocalEvaluadoresRequeridos') is not null drop table #tempLocalEvaluadoresRequeridos;
	IF OBJECT_ID('tempdb..#tempEvaEmp') IS NOT NULL DROP TABLE #tempEvaEmp;
	IF OBJECT_ID('tempdb..#tempResponse') IS NOT NULL DROP TABLE #tempResponse;
	IF OBJECT_ID('tempdb..#tempResponseFinal') IS NOT NULL DROP TABLE #tempResponseFinal

	select *
	INTO #tempLocalEvaluadoresRequeridos
	from [Evaluacion360].[tblEvaluadoresRequeridos] WITH (NOLOCK) 
	WHERE IDProyecto = @IDProyecto and (IDTipoRelacion = @IDTipoRelacion or isnull(@IDTipoRelacion, 0) = 0)

	--if (@IDTipoProyecto = @ID_TIPO_PROYECTO_DESEMPENIO)
	--BEGIN
	--	insert #tempLocalEvaluadoresRequeridos(IDProyecto, IDTipoRelacion,Minimo, Maximo)
	--	select @IDProyecto, @ID_TIPO_RELACION_JEFE_DIRECTO, 1,1 
	--END

	CREATE TABLE #tempRequeridos(
		IDTipoRelacion INT,
		Codigo VARCHAR(20),
		Relacion VARCHAR(255),
		Minimo INT,
		Maximo INT
	);
	
	SELECT @i = MIN(IDTipoRelacion) FROM #tempLocalEvaluadoresRequeridos WITH (NOLOCK) WHERE IDProyecto = @IDProyecto

	WHILE EXISTS(SELECT TOP 1 1 FROM #tempLocalEvaluadoresRequeridos WITH (NOLOCK) WHERE IDProyecto = @IDProyecto AND IDTipoRelacion >= @i)
	BEGIN
		SELECT @IDTipoRelacion_while = IDTipoRelacion,
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
		FROM #tempLocalEvaluadoresRequeridos er WITH (NOLOCK)
		WHERE er.IDProyecto = @IDProyecto AND
				er.IDTipoRelacion = @i 
		
		SET @j = 1;
		WHILE @j <= @Maximo
		BEGIN
			INSERT INTO #tempRequeridos(IDTipoRelacion, Minimo, Maximo)
			SELECT @IDTipoRelacion_while, @Minimo,@Maximo
			SET @j = @j + 1;
		END;

		SELECT @i = MIN(IDTipoRelacion)
		FROM #tempLocalEvaluadoresRequeridos WITH (NOLOCK)
		WHERE IDProyecto = @IDProyecto AND IDTipoRelacion > @i
	END;

	UPDATE ER 
		SET 
			ER.Relacion =  JSON_VALUE(CTE.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')),
			ER.Codigo	= CTE.Codigo 
	FROM [Evaluacion360].[tblCatTiposRelaciones] CTE WITH (NOLOCK)
		JOIN #tempRequeridos ER ON CTE.IDTipoRelacion = ER.IDTipoRelacion


	SELECT EP.IDEmpleadoProyecto,
		   EP.IDProyecto,
		   EP.IDEmpleado,
		   E.ClaveEmpleado,
		   E.NOMBRECOMPLETO as Colaborador,
		   E.Departamento,
		   E.Sucursal,
		   E.Puesto,
		   SUBSTRING (E.Nombre, 1, 1) + SUBSTRING (E.Paterno, 1, 1) as InicialesColaborador,
		   0 AS IDEvaluacionEmpleado,
		   ISNULL(REQ.IDTipoRelacion,0) AS IDTipoRelacion,
		   REQ.Relacion,
		   REQ.Minimo,
		   REQ.Maximo,
		   0 AS IDEvaluador,
		   cast('' as varchar(20)) ClaveEvaluador,
		   CAST('' as VARCHAR(255)) AS Evaluador,
		   cast('' as varchar(5)) InicialesEvaluador,
		   CAST(0 as bit) as Requerido,
		   CAST(0 as bit) as CumpleTipoRelacion,
		   cast('' as varchar(150)) TipoEvaluacion,
		   ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, REQ.IDTipoRelacion ORDER BY EP.IDEmpleado,REQ.IDTipoRelacion) AS [Row]
	INTO #tempEmpPro
	FROM [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK)
		JOIN [RH].[tblEmpleadosMaster] E WITH (NOLOCK) ON EP.IDEmpleado = E.IDEmpleado
		INNER JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios DFE WITH (NOLOCK) ON DFE.IDEmpleado = E.IDEmpleado AND DFE.IDUsuario = @IDUsuario
		CROSS JOIN #tempRequeridos REQ
		--LEFT JOIN RH.tblTotalRelacionesEmpleados totalRelaciones WITH (NOLOCK) ON totalRelaciones.IDEmpleado = EP.IDEmpleado AND REQ.IDTipoRelacion = totalRelaciones.IDTipoRelacion
	WHERE (EP.IDEmpleado = @IDEmpleado OR @IDEmpleado = 0) AND
		  (EP.IDProyecto = @IDProyecto OR @IDProyecto = 0) AND
		  (@query = '""' OR CONTAINS(E.*, @query))

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


	SELECT EE.IDEvaluacionEmpleado,
		   EP.IDEmpleadoProyecto,
		   EE.IDTipoRelacion,
		   EE.IDEvaluador,
		   EP.IDProyecto,
		   EP.IDEmpleado,
		   E.NOMBRECOMPLETO AS Evaluador,		   
		   ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Nombre')), 'GENERAL') AS TipoEvaluacion,
		   ROW_NUMBER() OVER(PARTITION BY EP.IDEmpleado, EE.IDTipoRelacion ORDER BY EP.IDEmpleado, EE.IDTipoRelacion, isnull(ee.IDEvaluador, 9999)) AS [Row]
	INTO #tempEvaEmp
	FROM [Evaluacion360].[tblEvaluacionesEmpleados] EE WITH (NOLOCK)
		LEFT JOIN [Evaluacion360].[tblEmpleadosProyectos] EP WITH (NOLOCK) ON EE.IDEmpleadoProyecto = EP.IDEmpleadoProyecto
		LEFT JOIN [RH].[tblEmpleadosMaster] E WITH (NOLOCK) ON EE.IDEvaluador = E.IDEmpleado
		LEFT JOIN [Evaluacion360].[tblCatTiposEvaluaciones] TE WITH (NOLOCK) ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion 
	WHERE EP.IDProyecto = @IDProyecto
	ORDER BY EE.IDEvaluacionEmpleado ASC
	

	UPDATE EMP 
		SET 
			EMP.IDEvaluador = ISNULL(EE.IDEvaluador, 0),
			EMP.Evaluador = ISNULL(EE.Evaluador, '[Sin evaluador asignado]'),
			EMP.ClaveEvaluador = isnull(e.ClaveEmpleado,'[00000]'),
			EMP.InicialesEvaluador = SUBSTRING (E.Nombre, 1, 1) + SUBSTRING (E.Paterno, 1, 1),
			EMP.IDEvaluacionEmpleado = ISNULL(EE.IDEvaluacionEmpleado, 0),
			EMP.TipoEvaluacion = ISNULL(EE.TipoEvaluacion, '[Sin tipo evaluación]')
	FROM #tempEmpPro EMP
		LEFT JOIN #tempEvaEmp EE ON EE.IDEmpleadoProyecto = EMP.IDEmpleadoProyecto 
			AND EE.IDTipoRelacion = EMP.IDTipoRelacion AND EMP.[Row] = EE.[Row]
		LEFT JOIN [RH].[tblEmpleadosMaster] e on ee.IDEvaluador = e.IDEmpleado

		
	SELECT IDEmpleadoProyecto,
		   IDProyecto,
		   IDEmpleado,
		   ClaveEmpleado,
		   Colaborador,
		   InicialesColaborador,
		   Departamento,
		   Sucursal,
		   Puesto,
		   IDEvaluacionEmpleado,
		   IDTipoRelacion,
		   Relacion,
		   IDEvaluador,
		   ClaveEvaluador,
		   Evaluador,
		   InicialesEvaluador,
		   Minimo, 
		   Maximo,
		   Requerido,
		   CASE 
				WHEN IDTipoRelacion = 4
					THEN cast(0 as bit)
					ELSE cast(1 as bit)
				END AS Evaluar,
			TipoEvaluacion
	INTO #tempResponse
	FROM #tempEmpPro
	WHERE (IDEmpleado = @IDEmpleado OR @IDEmpleado = 0) AND
		  (IDEvaluador = @IDEvaluador OR @IDEvaluador = 0)		  		  



	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from #tempResponse ee
		join [Evaluacion360].[tblEmpleadosProyectos] ep on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10

	delete #tempHistorialEstatusEvaluacion where [ROW] > 1

	SELECT 
		r.*
		,isnull(thee.IDEstatusEvaluacionEmpleado, 0) as IDEstatusEvaluacionEmpleado
		,isnull(thee.IDEstatus					, -1) as IDEstatus
		,isnull(JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus'))				, 'SIN ESTATUS') as Estatus
	INTO #tempResponseFinal
	FROM #tempResponse r	
		left join #tempHistorialEstatusEvaluacion thee on thee.IDEvaluacionEmpleado = r.IDEvaluacionEmpleado
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on thee.IDEstatus = estatus.IDEstatus
	where (isnull(thee.IDEstatus, -1) = @IDEstatusEvaluacion or isnull(@IDEstatusEvaluacion, 0) = 0)
		AND (r.Requerido = 
					case 
						when isnull(@Requeridas, 0) = 0 then r.Requerido
						when isnull(@Requeridas, 0) = 1 then 1
						when isnull(@Requeridas, 0) = 2 then 0
					else r.Requerido end
		)
	

		  		   
	SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
	FROM #tempResponseFinal

	SELECT @TotalRegistros = CAST(COUNT([IDEmpleadoProyecto]) AS DECIMAL(18,2)) FROM #tempResponseFinal

	select *
		,TotalPages = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END
		,CAST(@TotalRegistros AS INT) AS TotalRows
	from #tempResponseFinal r
	WHERE IDEmpleado NOT IN (SELECT ID FROM [Evaluacion360].[tblFiltrosProyectos] WHERE IDProyecto = @IDProyecto AND TipoFiltro = 'Excluir Empleado' AND ID = R.IDEmpleado)
	ORDER BY
		--CASE WHEN @orderByColumn = 'IDTipoRelacion'	and @orderDirection = 'asc'				THEN r.IDTipoRelacion END,
		--CASE WHEN @orderByColumn = 'IDTipoRelacion'	and @orderDirection = 'desc'			THEN r.IDTipoRelacion END DESC,
		--CASE WHEN @orderByColumn = 'IDEvaluacionEmpleado'	and @orderDirection = 'asc'		THEN r.IDEvaluacionEmpleado END,
		--CASE WHEN @orderByColumn = 'IDEvaluacionEmpleado'	and @orderDirection = 'desc'	THEN r.IDEvaluacionEmpleado END DESC,
		--CASE WHEN @orderByColumn = 'Requerido' and @orderDirection = 'asc'					THEN r.Requerido END,
		--CASE WHEN @orderByColumn = 'Requerido' and @orderDirection = 'desc'					THEN r.Requerido END DESC,
		r.ClaveEmpleado, r.IDTipoRelacion, r.IDEvaluacionEmpleado DESC, r.Requerido
	OFFSET @PageSize * (@PageNumber - 1) ROWS
	FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

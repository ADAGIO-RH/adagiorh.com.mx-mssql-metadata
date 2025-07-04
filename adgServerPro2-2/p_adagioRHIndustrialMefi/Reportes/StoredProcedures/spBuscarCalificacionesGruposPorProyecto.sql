USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Reportes].[spBuscarCalificacionesGruposPorProyecto] (
	@IDProyecto int
	,@IDUsuario int
) as
	SET FMTONLY OFF;

	DECLARE @Resultado VARCHAR(250)
			, @Privacidad BIT = 0
			, @PrivacidadDescripcion VARCHAR(25)			
			, @ACTIVO BIT = 1
			;

	DECLARE @RelacionesProyecto TABLE(		
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
		Evaluar BIT,
		TotalPaginas INT,
		TotalRows INT
	);

	if object_id('tempdb..#tempCalificacionesColaboradores') is not null drop table #tempCalificacionesColaboradores;
	if object_id('tempdb..#tempCalificacionesMAX') is not null drop table #tempCalificacionesMAX;
	if object_id('tempdb..#tempCalificacionesMIN') is not null drop table #tempCalificacionesMIN;
	if object_id('tempdb..#tempCalificacionesFinal') is not null drop table #tempCalificacionesFinal;


	-- VALIDACION PRUEBAS ANONIMAS
	EXEC [Evaluacion360].[spValidarPruebasAnonimas] 
		@IDProyecto = @IDProyecto
		, @EsRptBasico = 1
		, @Resultado = @Resultado OUTPUT
		, @Descripcion = @PrivacidadDescripcion OUTPUT
		;

	IF(@Resultado <> '0' AND @Resultado <> '1')
		BEGIN					
			RAISERROR(@Resultado, 16, 1);  
			RETURN
		END
	ELSE
		BEGIN
			SET @Privacidad = @Resultado;
		END
	-- TERMINA VALIDACION





	insert @RelacionesProyecto
	exec [Evaluacion360].[spBuscarRelacionesProyecto]  
		 @IDProyecto =@IDProyecto 
		,@IDUsuario =@IDUsuario

	select 
		rp.IDEmpleado,
		rp.Colaborador,
		cg.Nombre as Grupo, 
		cast( sum(cg.Porcentaje) / count(*) as decimal(10,2)) as Porcentaje,
		cast('NINGUNO' as varchar(100)) as ColaboradorMaximaCalificacion,cast('NINGUNO' as varchar(100)) ColaboradorMinimaCalificacion
	INTO #tempCalificacionesColaboradores
	from @RelacionesProyecto rp
		join Evaluacion360.tblCatGrupos cg on cg.TipoReferencia = 4 and cg.IDReferencia = rp.IDEvaluacionEmpleado
	group by rp.IDEmpleado,rp.Colaborador,cg.Nombre	

	select *,ROW_NUMBER()OVER(partition by Grupo order by Grupo,Porcentaje desc) as Maximo
	INTO #tempCalificacionesMAX
	from #tempCalificacionesColaboradores t
	order by Grupo,Porcentaje desc

	select *,Minimo = ROW_NUMBER()OVER(partition by Grupo order by Grupo,Porcentaje asc) 
	INTO #tempCalificacionesMIN
	from #tempCalificacionesColaboradores t
	order by Grupo,Porcentaje desc

	delete from #tempCalificacionesMAX where Maximo <> 1
	delete from #tempCalificacionesMIN where Minimo <> 1

	delete Minimos 
	from #tempCalificacionesMAX Maximos
	 left join #tempCalificacionesMIN Minimos on Maximos.IDEmpleado = Minimos.IDEmpleado and Maximos.Grupo = Minimos.Grupo
	where Maximos.IDEmpleado is not null

	select 
		cg.Nombre as Grupo, 
		cast( sum(cg.Porcentaje) / count(*) as decimal(10,2)) as Porcentaje,
		--isnull( tcMax.Colaborador,'NINGUN@' ) as CalificacionMaxima,
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE isnull( tcMax.Colaborador,'NINGUN@' )
			END AS CalificacionMaxima,
		--isnull(tcMin.Colaborador,'NINGUN@') as CalificacionMinima
		CASE 
			WHEN @Privacidad = @ACTIVO
				THEN @PrivacidadDescripcion
				ELSE isnull(tcMin.Colaborador,'NINGUN@')
			END AS CalificacionMinima
	INTO #tempCalificacionesFinal
	from @RelacionesProyecto rp
		join Evaluacion360.tblCatGrupos cg on cg.TipoReferencia = 4 and cg.IDReferencia = rp.IDEvaluacionEmpleado
		left join #tempCalificacionesMAX tcMax on cg.Nombre = tcMax.Grupo
		left join #tempCalificacionesMIN tcMin on cg.Nombre = tcMin.Grupo
		-- left join #tempCalificacionesColaboradores tc on tc.Grupo = cg.Nombre
	group by cg.Nombre,tcMax.Colaborador,tcMin.Colaborador

	select cf.*,isnull(cl.Literal,'D') as Literal
	from #tempCalificacionesFinal cf
		left join Evaluacion360.tblCatCalificacionesLiterales cl on floor(isnull(cf.Porcentaje,0)) between cl.CalificacionInicial and cl.CalificacionFinal
	order by cf.Porcentaje desc
GO

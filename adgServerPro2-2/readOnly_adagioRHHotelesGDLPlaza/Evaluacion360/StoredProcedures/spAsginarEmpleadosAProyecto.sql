USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select *
--from [Evaluacion360].[tblEmpleadosProyectos]
--where IDProyecto = 7

--select *
--from [Evaluacion360].[tblFiltrosProyectos]
--where IDProyecto = 7

--exec [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = 7, @IDUsuario = 1
--GO
--USE [d_adagioRH]
--GO
--/****** Object:  StoredProcedure [Evaluacion360].[spAsginarEmpleadosAProyecto]    Script Date: 2/1/2020 10:34:28 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- [Evaluacion360].[spAsginarEmpleadosAProyecto] 82,1
CREATE procedure [Evaluacion360].[spAsginarEmpleadosAProyecto](
 	  @IDProyecto int  
	,@IDUsuario int  
) as

	--select * from Evaluacion360.tblCatProyectos
	declare 
		@dtFiltros [Nomina].[dtFiltrosRH] 
	--	,@dtFiltros2 [Nomina].[dtFiltrosRH]
		,@empleados [RH].[dtEmpleados]
		,@i int = 0
		,@fecha date = getdate()
		,@Catalogo varchar (255)
		,@EnviarResultadoPruebasAColaboradores nvarchar(100) = 'false'
	;
		
	if exists (select top 1 1
				from [Evaluacion360].[tblConfiguracionAvanzadaProyecto] with (nolock)
				where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 12) --Enviar resultado de las pruebas a los colaboradores
	begin
		select @EnviarResultadoPruebasAColaboradores=ISNULL(Valor,'false')
		from [Evaluacion360].[tblConfiguracionAvanzadaProyecto] with (nolock)
		where IDProyecto = @IDProyecto and IDConfiguracionAvanzada = 12
	end;
		
	--insert into @dtFiltros(Catalogo,Value)
	
	if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;
	if object_id('tempdb..#tempFiltrosAsignarEmpAProyecto') is not null drop table #tempFiltrosAsignarEmpAProyecto;

	create table #tempFinalEmpleados (IDEmpleado int, TipoFiltro varchar(255) collate database_default)

	select *
	INTO #tempFiltrosAsignarEmpAProyecto
	from [Evaluacion360].[tblFiltrosProyectos] with (nolock)
	where IDProyecto = @IDProyecto and TipoFiltro <> 'Excluir Empleado'

	select @i = min(IDFiltroProyecto) from #tempFiltrosAsignarEmpAProyecto

	while exists(select top 1 1 from #tempFiltrosAsignarEmpAProyecto where IDFiltroProyecto >= @i)
	begin
		delete from @dtFiltros;
		delete from @empleados;

		insert into @dtFiltros(Catalogo,Value)
		select TipoFiltro, ID
		from #tempFiltrosAsignarEmpAProyecto
		where IDFiltroProyecto = @i

		select @Catalogo= case when TipoFiltro = 'Empleados' then TipoFiltro
							else coalesce(TipoFiltro,'')+ ' | '+coalesce(Descripcion,'')
							end
		from #tempFiltrosAsignarEmpAProyecto
		where IDFiltroProyecto = @i
	
		--select *,@fecha from @dtFiltros2

		insert into @empleados
		exec [RH].[spBuscarEmpleados] 
			@FechaIni	= @fecha
			,@Fechafin	= @fecha 
			,@IDUsuario	= @IDUsuario
			,@dtFiltros = @dtFiltros

		insert #tempFinalEmpleados
		select IDEmpleado, @Catalogo from @empleados

		select @i = min(IDFiltroProyecto) from #tempFiltrosAsignarEmpAProyecto where IDFiltroProyecto > @i
	end;

	-- Se eliminan lo colaboradores excluidos del proyecto
	if exists(select top 1 1
		from [Evaluacion360].[tblFiltrosProyectos] with (nolock)
		where IDProyecto = @IDProyecto and TipoFiltro = 'Excluir Empleado')
	begin
		delete #tempFinalEmpleados
		where  IDEmpleado in (
				select ID
				from [Evaluacion360].[tblFiltrosProyectos]
				where IDProyecto = @IDProyecto and TipoFiltro = 'Excluir Empleado'
			);
	end;

	-- CTE que elimina los colaboradores duplicados	
	WITH TempEmp (IDEmpleado,duplicateRecCount)
	AS
	(
		SELECT IDEmpleado,ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY IDEmpleado) 
		AS duplicateRecCount
		FROM #tempFinalEmpleados
	)

	--Now Delete Duplicate Records
	DELETE FROM TempEmp
	WHERE duplicateRecCount > 1 ;

	--select * from #tempFinalEmpleados
	BEGIN TRY
		BEGIN TRAN TransFiltrosProyecto
			MERGE [Evaluacion360].[tblEmpleadosProyectos] AS TARGET
			USING #tempFinalEmpleados as SOURCE
				on TARGET.IDEmpleado = SOURCE.IDEmpleado and TARGET.IDProyecto = @IDProyecto
			WHEN MATCHED THEN
				update 
					set TARGET.TipoFiltro = SOURCE.TipoFiltro
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDProyecto, IDEmpleado,TipoFiltro)
				values(@IDProyecto, SOURCE.IDEmpleado,SOURCE.TipoFiltro)
			WHEN NOT MATCHED BY SOURCE and (TARGET.IDProyecto = @IDProyecto) THEN 
			DELETE ;
		COMMIT TRAN TransFiltrosProyecto
	END TRY
	BEGIN CATCH
		select ERROR_MESSAGE()
			,ERROR_LINE()
		ROLLBACK TRAN TransFiltrosProyecto
	END CATCH

	if exists(
		select top 1 1 
		from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
		where IDProyecto = @IDProyecto and IDTipoRelacion = 4
	) 
	begin
		DECLARE @archive TABLE (
			ActionType VARCHAR(50),
			IDEvaluacionEmpleado int
		);

		BEGIN TRY
			BEGIN TRAN TransEvaEmpProyecto
				MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
				USING (select *
						from [Evaluacion360].[tblEmpleadosProyectos]
						where IDProyecto = @IDProyecto 
						) as SOURCE
					on TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto 						
						and TARGET.IDTipoRelacion = 4 /* 4 = a AutoEvaluación*/			
				WHEN NOT MATCHED BY TARGET THEN 
					INSERT(IDEmpleadoProyecto,IDTipoRelacion,IDEvaluador)
					values(SOURCE.IDEmpleadoProyecto,4, SOURCE.IDEmpleado)
				WHEN NOT MATCHED BY SOURCE and TARGET.IDTipoRelacion = 4 and TARGET.IDEmpleadoProyecto in (select IDEmpleadoProyecto from Evaluacion360.[tblEmpleadosProyectos] where IDProyecto = @IDProyecto) THEN 
				DELETE
				OUTPUT
			   $action AS ActionType,
			   inserted.IDEvaluacionEmpleado
			   INTO @archive;

			COMMIT TRAN TransEvaEmpProyecto			
		END TRY
		BEGIN CATCH
		select ERROR_MESSAGE()
			,ERROR_LINE()
			,'KLK' as DameLU
			,@IDProyecto as IDProyecto
			ROLLBACK TRAN TransEvaEmpProyecto
		END CATCH

		insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
		select em.IDEvaluacionEmpleado,11,@IDUsuario
		from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock)
			join [Evaluacion360].[tblEvaluacionesEmpleados] em with (nolock) on ep.IDEmpleadoProyecto = em.IDEmpleadoProyecto
		where ep.IDProyecto = @IDProyecto and em.IDTipoRelacion = 4
			and em.IDEvaluacionEmpleado not in (select IDEvaluacionEmpleado from [Evaluacion360].[tblEstatusEvaluacionEmpleado])
	end else
	begin 
		DELETE ee
		FROM [Evaluacion360].[tblEvaluacionesEmpleados] ee
			INNER JOIN [Evaluacion360].[tblEmpleadosProyectos] ep
			  ON ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		WHERE ep.IDProyecto = @IDProyecto and ee.IDTipoRelacion = 4
	end;

	-- Se crea el registro del colaborador para según la configuración del proyecto para enviar o no los resultados a los colaboradores.
	MERGE [Evaluacion360].[tblEnviarResultadosAColaboradores] AS TARGET
	USING [Evaluacion360].[tblEmpleadosProyectos] as SOURCE
	on TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto
	--WHEN MATCHED THEN
	--	update 
	--		set TARGET.Valor = case when LOWER(@EnviarResultadoPruebasAColaboradores) = 'true' then 0 else 1 end
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDEmpleadoProyecto,Valor)
		values(SOURCE.IDEmpleadoProyecto,case when LOWER(@EnviarResultadoPruebasAColaboradores) = 'true' then 0 else 1 end)
	;

	EXEC [Evaluacion360].[spActualizarProgresoProyecto]
		@IDProyecto = @IDProyecto  
 		,@IDUsuario = @IDUsuario
GO

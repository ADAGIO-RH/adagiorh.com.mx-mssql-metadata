USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spCalcularTotalesEvaluacionesEmpleadosPorProyecto] (
	@IDProyecto int
) as
declare 
		--@IDProyecto int = 79 
		--,
		@IDEmpleadoProyecto int = 0
		,@TotalGeneral		decimal(10,1) = 0.0
		,@TotalCompetencias	decimal(10,1) = 0.0
		,@TotalKPIs			decimal(10,1) = 0.0
		,@TotalValores		decimal(10,1) = 0.0
	;

	if object_id('tempdb..#tmpEvasEmp') is not null drop table #tmpEvasEmp;
	
	create table #tmpEvasEmp(
		Texto nvarchar(max)
		,Porcentaje				decimal(10,1)
		,PorcentajeCompetencias decimal(10,1)
		,PorcertajeKPIs			decimal(10,1)
		,PorcentajeValores		decimal(10,1)
		,PorcentajeFuncionClave	decimal(10,1)
		,PorcentajeSeccion		decimal(10,1)
		,NombreCompetencia		varchar(500)
		,ColorCompetencia		varchar(500)
		,NombreObjetivoKpi		varchar(500)
		,ColorObjetivoKpi		varchar(500)
		,NombreValor			varchar(500)
		,ColorValor				varchar(500)
		,NombreFuncionClave		varchar(500)
		,ColorFuncionClave		varchar(500)
		,NombreSeccion			varchar(500)
		,ColorSeccion			varchar(500)
	);


	select @IDEmpleadoProyecto = min(IDEmpleadoProyecto) 
	from [Evaluacion360].[tblEmpleadosProyectos]
	where IDProyecto = @IDProyecto

	while exists(select top 1 1 
					from [Evaluacion360].[tblEmpleadosProyectos]
					where IDProyecto = @IDProyecto
					and IDEmpleadoProyecto >= @IDEmpleadoProyecto)	

	begin
		delete #tmpEvasEmp;
		begin try
			insert #tmpEvasEmp
			exec [Evaluacion360].[spCalificacionFinalEmpleadoProyecto] @IDEmpleadoProyecto

			select top 1 
				 @TotalGeneral			= Porcentaje				
				,@TotalCompetencias		= PorcentajeCompetencias 
				,@TotalKPIs				= PorcertajeKPIs			
				,@TotalValores			= PorcentajeValores		
			from #tmpEvasEmp

			update [Evaluacion360].[tblEmpleadosProyectos]
				set 
					 TotalGeneral		= @TotalGeneral
					,TotalCompetencias	= @TotalCompetencias
					,TotalKPIs			= @TotalKPIs
					,TotalValores		= @TotalValores

			where  IDEmpleadoProyecto = @IDEmpleadoProyecto
		end try
		begin catch
			insert App.tblLogErrores(IDUsuario,Fecha,ProcedureName,ErrorNumber,ErrorSeverity,ErrorState,ErrorLine,ErrorMessage)
			select 0,getdate(),ERROR_PROCEDURE(),ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_LINE(),ERROR_MESSAGE()
		end catch

		select @IDEmpleadoProyecto = min(IDEmpleadoProyecto) 
		from [Evaluacion360].[tblEmpleadosProyectos]
		where IDProyecto = @IDProyecto and IDEmpleadoProyecto > @IDEmpleadoProyecto
	end;

--exec [Evaluacion360].[spCalificacionFinalEmpleadoProyecto] 42302

--select *
--from [Evaluacion360].[tblEmpleadosProyectos]


--update [Evaluacion360].[tblEmpleadosProyectos]
--set TotalGeneral  = 0.0
--,TotalCompetencias= 0.0
--,TotalKPIs = 0.0
--,TotalValores = 0.0
GO

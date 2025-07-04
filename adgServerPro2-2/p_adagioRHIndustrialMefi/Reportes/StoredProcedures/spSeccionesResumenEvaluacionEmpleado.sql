USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spSeccionesResumenEvaluacionEmpleado] (
	@IDEmpleadoProyecto int
) 
as

	declare 
		@subReportCompetenciasYPreguntas bit = 0
		,@subReportKPIsYPreguntas bit = 0
		,@subReportValoresYPreguntas bit = 0
		,@subReportFuncionClaveYPreguntas bit = 0
		,@subReportFuncionSeccion bit = 0
		,@subReportPregunasSinCalificacion bit = 0
	;

	if object_id('tempdb..#tmpCafilifaciones') is not null drop table #tmpCafilifaciones;

	create table #tmpCafilifaciones(
		Nombre						varchar(1000)
		,NombreFull					varchar(1000)
		,Relacion					varchar(1000)
		,TotalPreguntas				int
		,MaximaCalificacionPosible  decimal(10,2)
		,CalificacionObtenida		decimal(10,2)
		,Promedio					decimal(10,2)
		,Calificacion				decimal(10,2)
		,TituloPerfil				nvarchar(max) 
		,TituloResumen				nvarchar(max) 
		,TituloEvaluadas			nvarchar(max) 
		,MostrarNombres				nvarchar(max) 
	); 

	insert #tmpCafilifaciones
	exec [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacion] @IDEmpleadoProyecto  ,1	

	if exists(select top 1 1 from #tmpCafilifaciones)
	begin
		set @subReportCompetenciasYPreguntas = 1
	end;

	delete from #tmpCafilifaciones;



	insert #tmpCafilifaciones
	exec [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacion] @IDEmpleadoProyecto  ,2

	if exists(select top 1 1 from #tmpCafilifaciones)
	begin
		set @subReportKPIsYPreguntas = 1
	end;

	delete from #tmpCafilifaciones;



	insert #tmpCafilifaciones
	exec [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacion] @IDEmpleadoProyecto  ,3

	if exists(select top 1 1 from #tmpCafilifaciones)
	begin
		set @subReportValoresYPreguntas = 1
	end;

	delete from #tmpCafilifaciones;


	insert #tmpCafilifaciones
	exec [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacion] @IDEmpleadoProyecto  ,4

	if exists(select top 1 1 from #tmpCafilifaciones)
	begin
		set @subReportFuncionClaveYPreguntas = 1
	end;

	delete from #tmpCafilifaciones;


	insert #tmpCafilifaciones
	exec [Reportes].[spBuscarCalificacionesPorCompetenciaYRelacion] @IDEmpleadoProyecto  ,5

	if exists(select top 1 1 from #tmpCafilifaciones)
	begin
		set @subReportFuncionSeccion = 1
	end;

	delete from #tmpCafilifaciones;




	if exists (select top 1 1 
				from Evaluacion360.tblEvaluacionesEmpleados e
					join Evaluacion360.tblCatGrupos g on g.IDReferencia = e.IDEvaluacionEmpleado and g.TipoReferencia = 4
					join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
				where e.IDEmpleadoProyecto = @IDEmpleadoProyecto and isnull(p.Calificar,0) = 0)
	begin
		set @subReportPregunasSinCalificacion = 1
	end;

	select   @subReportCompetenciasYPreguntas	as subReportCompetenciasYPreguntas	
			,@subReportKPIsYPreguntas			as subReportKPIsYPreguntas			
			,@subReportValoresYPreguntas		as subReportValoresYPreguntas
			,@subReportFuncionClaveYPreguntas   as subReportFuncionClaveYPreguntas
			,@subReportFuncionSeccion			as subReportFuncionSeccion
			,@subReportPregunasSinCalificacion  as subReportPregunasSinCalificacion
GO

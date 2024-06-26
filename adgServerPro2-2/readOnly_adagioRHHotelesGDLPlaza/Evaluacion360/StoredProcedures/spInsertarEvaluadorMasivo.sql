USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Inserta el Evaluador al Colaborador a todos los colaboradores recibidos 
						en el parametro @IDsEmpleados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@gmail.com
** FechaCreacion	: 2018-10-30
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
/*
[Evaluacion360].[spInsertarEvaluadorMasivo] @IDProyecto = 29
	,@IDTipoRelacion = 2
	,@IDEvaluador = 20310
	,@IDUsuario  = 1
	,@IDsEmpleados= '9'

	*/
CREATE proc [Evaluacion360].[spInsertarEvaluadorMasivo] (
  @IDProyecto int 
	,@IDTipoRelacion int 
	,@IDEvaluador int 
	,@IDUsuario int 
	,@IDsEmpleados nvarchar(max) 
) as

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch	

	if OBJECT_ID('tempdb..#tempEmpleadoProyecto') is not null
		drop table #tempEmpleadoProyecto;

	--insert into [Evaluacion360].[tblEvaluacionesEmpleados](IDEmpleadoProyecto,IDTipoRelacion,IDEvaluador)
	select 
		--emps.item as IDEmpleado
		ep.IDEmpleadoProyecto
		,IDTipoRelacion = case when @IDTipoRelacion = 1 then 2
									when @IDTipoRelacion = 2 then 1 else @IDTipoRelacion end 
		,@IDEvaluador as IDEvaluador
		,ep.IDProyecto
	into #tempEmpleadoProyecto
	from app.Split(@IDsEmpleados,',') as emps
		join [Evaluacion360].[tblEmpleadosProyectos] ep  on cast(emps.item as int) = ep.IDEmpleado
	where ep.IDProyecto = @IDProyecto


	--select * from #tempEmpleadoProyecto

	DECLARE @archive TABLE (
		ActionType VARCHAR(50),
		IDEvaluacionEmpleado int
	);

	BEGIN TRY
		BEGIN TRAN TransEvaEmpProyecto
			MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
			USING #tempEmpleadoProyecto as SOURCE
			on TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto 
			 and TARGET.IDTipoRelacion = SOURCE.IDTipoRelacion
			 and TARGET.IDEvaluador = SOURCE.IDEvaluador
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleadoProyecto,IDTipoRelacion,IDEvaluador)
				values(SOURCE.IDEmpleadoProyecto,SOURCE.IDTipoRelacion, SOURCE.IDEvaluador)
			--WHEN NOT MATCHED BY SOURCE and TARGET.IDTipoRelacion = 4 THEN 
			--DELETE
			OUTPUT
			$action AS ActionType,
			inserted.IDEvaluacionEmpleado
			INTO @archive;

		COMMIT TRAN TransEvaEmpProyecto			
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransEvaEmpProyecto
	END CATCH

	insert [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado,IDEstatus,IDUsuario)
	select IDEvaluacionEmpleado,11,@IDUsuario from @archive







--select * from [Evaluacion360].[tblEmpleadosProyectos] ep 
--select * from [Evaluacion360].[tblEvaluacionesEmpleados] ee

--alter table [Evaluacion360].[tblEvaluacionesEmpleados]
--	add constraint U_Evaluacion360TblEvaluacionesEmpleados_IDEmpleadoProyectoIDEvaluador unique(IDEmpleadoProyecto,IDEvaluador)
GO

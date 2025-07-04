USE [p_adagioRHIndustrialMefi]
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
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto			¿Qué cambió?
26-09-2022		Alejandro Paredes		Excluir empleados
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spInsertarEvaluadorMasivo] (
	@IDProyecto INT,
	@IDTipoRelacion INT,
	@IDEvaluador INT,
	@IDUsuario INT,
	@IDsEmpleados NVARCHAR(MAX)
) AS
	
	
	BEGIN TRY
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		RETURN 0;
	END CATCH
		
	
	IF OBJECT_ID('tempdb..#tempEmpleadoProyecto') IS NOT NULL
		DROP TABLE #tempEmpleadoProyecto;


	SELECT EP.IDEmpleadoProyecto,
		   IDTipoRelacion = CASE
								WHEN @IDTipoRelacion = 1 
									THEN 2
								WHEN @IDTipoRelacion = 2 
									THEN 1 
									ELSE @IDTipoRelacion 
								END,
		   @IDEvaluador AS IDEvaluador,
		   EP.IDProyecto
	INTO #tempEmpleadoProyecto
	FROM App.Split(@IDsEmpleados, ',') AS EMPS
		JOIN [Evaluacion360].[tblEmpleadosProyectos] EP ON CAST(EMPS.item AS INT) = EP.IDEmpleado
	WHERE EP.IDProyecto = @IDProyecto

	
	DECLARE @archive TABLE (
		ActionType VARCHAR(50),
		IDEvaluacionEmpleado INT
	);

	BEGIN TRY
		BEGIN TRAN TransEvaEmpProyecto

			MERGE [Evaluacion360].[tblEvaluacionesEmpleados] AS TARGET
			USING #tempEmpleadoProyecto as SOURCE
			ON TARGET.IDEmpleadoProyecto = SOURCE.IDEmpleadoProyecto AND
			   TARGET.IDTipoRelacion = SOURCE.IDTipoRelacion AND 
			   ISNULL(TARGET.IDEvaluador,0) = 0
			   --TARGET.IDEvaluador = SOURCE.IDEvaluador
			WHEN MATCHED THEN
				UPDATE 
				SET TARGET.IDEvaluador = SOURCE.IDEvaluador
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleadoProyecto, IDTipoRelacion, IDEvaluador)
				VALUES(SOURCE.IDEmpleadoProyecto, SOURCE.IDTipoRelacion, SOURCE.IDEvaluador)
			--WHEN NOT MATCHED BY SOURCE and TARGET.IDTipoRelacion = 4 THEN 
			--DELETE
			OUTPUT
			$ACTION AS ActionType, inserted.IDEvaluacionEmpleado
			INTO @archive;

		COMMIT TRAN TransEvaEmpProyecto
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN TransEvaEmpProyecto
	END CATCH

	INSERT [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado, IDEstatus, IDUsuario)
	SELECT IDEvaluacionEmpleado, 11, @IDUsuario FROM @archive
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spIUJefeMasivo] (  
	@IDJefe int  
	,@IDsEmpleados nvarchar(max)   
	,@IDUsuario int   
) as   
	if object_id('tempdb..#emps') is not null drop table #emps;  
  
	select item as IDEmpleado, @IDJefe as IDJefe  
	into #emps  
	from app.Split(@IDsEmpleados,',')    
	where cast(item as int) <> @IDJefe

	BEGIN TRY  
		BEGIN TRAN TransJefesEmpleados 
		 
			MERGE [RH].[tblJefesEmpleados] AS TARGET  
			USING #emps as SOURCE  
			on TARGET.IDEmpleado = SOURCE.IDEmpleado   
			and TARGET.IDJefe = SOURCE.IDJefe  
			WHEN NOT MATCHED BY TARGET THEN   
			INSERT(IDEmpleado,IDJefe)  
			values(SOURCE.IDEmpleado,SOURCE.IDJefe)  
			--WHEN NOT MATCHED BY SOURCE and TARGET.IDTipoRelacion = 4 THEN   
			--DELETE  
			OUTPUT  
			$action AS ActionType;  
  
		COMMIT TRAN TransJefesEmpleados     
	END TRY  
		BEGIN CATCH  
		ROLLBACK TRAN TransJefesEmpleados  
	END CATCH  
  
  
	exec [RH].[spActualizarTotalesRelacionesEmpleados]
GO

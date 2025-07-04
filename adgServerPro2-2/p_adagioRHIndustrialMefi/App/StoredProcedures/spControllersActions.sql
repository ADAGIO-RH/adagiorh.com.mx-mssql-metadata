USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spControllersActions]
(
	@dtControllersActions [App].[dtControllersActions] READONLY
)
AS
    delete from [App].[tblControllersActions];
    
    insert into [App].[tblControllersActions]
    select * from @dtControllersActions

	--BEGIN TRY
	--	BEGIN TRAN TransControllers
	--		MERGE [App].[tblControllersActions] AS TARGET
	--		USING @dtControllersActions as SOURCE
	--		on 
	--			TARGET.Controller = SOURCE.Controller and
	--			TARGET.Action	  = SOURCE.Action and
	--			TARGET.Area		  = SOURCE.Area

	--		WHEN MATCHED THEN
	--			update 
	--			 set TARGET.ReturnType = SOURCE.ReturnType,
	--				TARGET.Attributes = SOURCE.Attributes
	--		WHEN NOT MATCHED BY TARGET THEN 
	--			INSERT(Controller,Action,ReturnType,Attributes,Area)
	--			values(SOURCE.Controller,SOURCE.Action,SOURCE.ReturnType,SOURCE.Attributes,SOURCE.Area)
	--		WHEN NOT MATCHED BY SOURCE THEN 
	--		DELETE
	--		OUTPUT $action, 
	--		DELETED.*,
	--		INSERTED.*;
	--		SELECT @@ROWCOUNT;
	--	COMMIT TRAN TransControllers
	--END TRY
	--BEGIN CATCH
	--	ROLLBACK TRAN TransControllers
	--	select ERROR_MESSAGE() as Error
	--END CATCH
GO

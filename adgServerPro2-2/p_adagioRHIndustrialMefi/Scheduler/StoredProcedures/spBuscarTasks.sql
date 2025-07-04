USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  PROCEDURE [Scheduler].[spBuscarTasks]
(
	@IDTask int = 0
)
AS
BEGIN
	Select 
		 T.IDTask
		,T.Nombre
		,T.StoreProcedure
		,T.interval
		,ISNULL(T.active,0) as Active
		,ISNULL(T.IDTipoAccion,0) AS IDTipoAccion
		,A.Descripcion AS TipoAccion
	FROM [Scheduler].[tblTask] t
		Inner join [Scheduler].tblCatTipoAcciones A
			on T.IDTipoAccion = A.IDTipoAccion
	WHERE ((T.IDTask = @IDTask) OR (@IDTask = 0))
END
GO

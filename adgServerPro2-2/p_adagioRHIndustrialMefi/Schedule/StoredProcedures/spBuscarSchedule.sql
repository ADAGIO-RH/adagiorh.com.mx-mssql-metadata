USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE Schedule.spBuscarSchedule
(
	@IDSchedule int = 0
)
AS
BEGIN
	Select 
		S.IDSchedule
		,S.Nombre
		,S.StoreProcedure
		,S.interval
		,ISNULL(S.active,0) as Active
		,ISNULL(S.IDTipoAccion,0) AS IDTipoAccion
		,A.Descripcion AS TipoAccion
	FROM [Schedule].[tblSchedule] S
		Inner join [Schedule].tblCatTipoAcciones A
			on S.IDTipoAccion = A.IDTipoAccion
	WHERE ((S.IDSchedule = @IDSchedule) OR (@IDSchedule = 0))
END
GO

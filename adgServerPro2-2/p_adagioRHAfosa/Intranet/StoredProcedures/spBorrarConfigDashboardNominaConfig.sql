USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBorrarConfigDashboardNominaConfig]
(
	@IDConfigDashboardNomina int
)
AS
BEGIN
	EXEC intranet.spBuscarConfigDashboardNominaConfig @IDConfigDashboardNomina ,1
	DELETE Intranet.tblConfigDashboardNomina
	WHERE IDConfigDashboardNomina = @IDConfigDashboardNomina
END
GO

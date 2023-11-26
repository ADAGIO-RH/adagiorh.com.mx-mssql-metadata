USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE intranet.spBuscarConfigDashboardNominaConfig
(
	@IDConfigDashboardNomina int = 0
)
AS
BEGIN
	Select 
	IDConfigDashboardNomina
	,BotonLabel
	,Filtro
	From intranet.tblConfigDashboardNomina
	where IDConfigDashboardNomina = @IDConfigDashboardNomina or @IDConfigDashboardNomina = 0
END
GO

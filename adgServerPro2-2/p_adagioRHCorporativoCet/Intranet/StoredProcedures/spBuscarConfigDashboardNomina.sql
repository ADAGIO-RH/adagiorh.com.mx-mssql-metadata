USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.spBuscarConfigDashboardNomina
(
	@IDEmpleado int,
	@Ejercicio int
)
AS
BEGIN
	select IDConfigDashboardNomina
		   ,BotonLabel
		   ,Filtro 
		   ,@IDEmpleado as IDEmpleado
		   ,@Ejercicio as Ejercicio
	from Intranet.tblConfigDashboardNomina
END
GO

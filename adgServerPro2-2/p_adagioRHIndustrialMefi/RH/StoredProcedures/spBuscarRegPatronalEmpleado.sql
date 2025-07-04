USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarRegPatronalEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
		     RPE.IDRegPatronalEmpleado,
			RPE.IDEmpleado,
			RPE.IDRegPatronal,
			RP.RegistroPatronal,
			RP.RazonSocial ,
			RPE.FechaIni,
			RPE.FechaFin
		From RH.tblRegPatronalEmpleado RPE
			Inner join RH.tblCatRegPatronal RP
				on RPE.IDRegPatronal = RP.IDRegPatronal
		Where RPE.IDEmpleado = @IDEmpleado
		ORDER BY RPE.FechaIni Desc

END
GO

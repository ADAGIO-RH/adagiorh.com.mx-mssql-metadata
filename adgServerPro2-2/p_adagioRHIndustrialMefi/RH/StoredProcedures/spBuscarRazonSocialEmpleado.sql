USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarRazonSocialEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			RSE.IDRazonSocialEmpleado,
			RSE.IDEmpleado,
			RS.IDRazonSocial,
			RS.RazonSocial as RazonSocial,
			RS.RFC,
			RSE.FechaIni,
			RSE.FechaFin 
		from RH.tblRazonSocialEmpleado RSE
			inner join RH.tblCatRazonesSociales RS
				on RS.IDRazonSocial = RSE.IDRazonSocial
		WHERE RSE.IDEmpleado = @IDEmpleado
		ORDER by RSE.FechaIni DESC
END
GO

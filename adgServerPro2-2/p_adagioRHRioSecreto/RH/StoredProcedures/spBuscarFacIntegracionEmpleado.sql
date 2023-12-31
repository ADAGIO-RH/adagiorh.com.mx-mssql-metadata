USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarFacIntegracionEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			FIE.IDFacIntegracionEmpleado,
			FIE.IDEmpleado,
			FIE.IDFacIntegracion,
			FI.Codigo,
			FI.Descripcion as FacIntegracion,
			FI.TipoFactor,
			FIE.FechaIni,
			FIE.FechaFin
		From RH.tblFacIntegracionEmpleado FIE
			inner join RH.tblCatFacIntegracion FI
				on FIE.IDFacIntegracion = FI.IDFacIntegracion
		Where FIE.IDEmpleado = @IDEmpleado
		ORDER BY FIE.FechaIni DESC
END
GO

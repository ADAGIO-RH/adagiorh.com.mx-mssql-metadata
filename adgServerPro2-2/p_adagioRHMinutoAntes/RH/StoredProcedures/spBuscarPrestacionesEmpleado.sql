USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarPrestacionesEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
		Select 
			FIE.IDPrestacionEmpleado,
			FIE.IDEmpleado,
			FIE.IDTipoPrestacion,
			FI.Codigo,
			FI.Descripcion,
			FIE.FechaIni,
			FIE.FechaFin
		From RH.tblPrestacionesEmpleado FIE
			inner join RH.tblCatTiposPrestaciones FI
				on FIE.IDTipoPrestacion = FI.IDTipoPrestacion
		Where FIE.IDEmpleado = @IDEmpleado
		ORDER BY FIE.FechaIni DESC
END
GO

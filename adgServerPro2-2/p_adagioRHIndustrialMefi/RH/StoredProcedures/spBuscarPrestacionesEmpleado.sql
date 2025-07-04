USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarPrestacionesEmpleado] --1279
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
			JSON_VALUE(FI.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion,
			FIE.FechaIni,
			FIE.FechaFin
		From RH.tblPrestacionesEmpleado FIE
			inner join RH.tblCatTiposPrestaciones FI
				on FIE.IDTipoPrestacion = FI.IDTipoPrestacion
		Where FIE.IDEmpleado = @IDEmpleado
		ORDER BY FIE.FechaIni DESC
END
GO

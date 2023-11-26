USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Reportes.spResetConfigReporteRayas
(
	@IDUsuario int
)
AS
BEGIN

	truncate table Reportes.tblConfigReporteRayas

	insert into Reportes.tblConfigReporteRayas(IDConcepto,Orden,Impresion)
	Select IDConcepto,OrdenCalculo,Estatus from Nomina.tblCatConceptos

END
GO

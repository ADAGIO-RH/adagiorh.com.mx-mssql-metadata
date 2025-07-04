USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Procom].[fnTotalFacturaPeriodo]
(
	@IDFactura int
)
RETURNS Decimal(18,2)
AS
BEGIN
	DECLARE @Total decimal(18,2) = 0
	SELECT
		@Total = SUM(isnull(dp.ImporteTotal1,0))
	FROM Procom.tblFacturas f with(nolock)
		inner join Procom.tblFacturasPeriodos FP with(nolock)
			on f.IDFactura = FP.IDFactura
		inner join Nomina.tblCatPeriodos p with(nolock)
			on p.IDPeriodo = FP.IDPeriodo
		inner join Nomina.tblDetallePeriodo dp with(nolock) 
			on p.IDPeriodo = dp.IDPeriodo
		inner join Nomina.tblCatConceptos c with(nolock)
			on c.IDConcepto = dp.IDConcepto
	WHERE p.Cerrado = 1
	and f.IDFactura = @IDFactura
	and c.Codigo = '601'


	RETURN  isnull(@Total,0)
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [IMSS].[fnGetCesantiaVejezPatronal]
(
	@IDEmpleado int,
	@IDSucursal int,
	@SalarioIntegrado Decimal(18,2),
	@Fecha Date
)
RETURNS Decimal(18,5) AS
BEGIN
	DECLARE 
		@fronterizo bit,
		@CuotaPatronal decimal(18,6),
		@UMA Decimal(18,2),
		@SalarioMinimo Decimal(18,2)  
	;

	Select @fronterizo = isnull(Fronterizo,0) 
	from RH.tblCatSucursales with(nolock) 
	where IDSucursal = @IDSucursal

	select top 1 
		@UMA = isnull(UMA,0) , 
		@SalarioMinimo = 
			case 
				when isnull(@fronterizo, 0) = 1  then isnull(SalarioMinimoFronterizo,0)
				else isnull(SalarioMinimo,0) end
	from Nomina.tblSalariosMinimos  
	where Year(Fecha) = Year(@Fecha)  
	order by Fecha Desc

	SELECT top 1 @CuotaPatronal = isnull(d.CuotaPatronal,0.000000) 
	FROM IMSS.tblCatCesantiaVejezPatronal P with(nolock)
		inner join IMSS.tblCatCesantiaVejezPatronalDetalle D  with(nolock)
			on P.IDCesantiaVejezPatronal = D.IDCesantiaVejezPatronal
	WHERE @Fecha Between p.FechaInicial and p.FechaFinal
		and ROUND(@SalarioIntegrado / @UMA , 2, 1) between Desde and Hasta

    RETURN @CuotaPatronal
END
GO

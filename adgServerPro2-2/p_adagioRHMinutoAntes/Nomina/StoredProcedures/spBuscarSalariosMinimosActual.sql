USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarSalariosMinimosActual]
(
    @Fecha date = null
) as
begin
    select top 1 
		IDSalarioMinimo
		,Fecha
		,isnull(SalarioMinimo		   , 0) as SalarioMinimo
		,isnull(SalarioMinimoFronterizo, 0) as SalarioMinimoFronterizo
		,isnull(UMA					   , 0) as UMA
		,isnull(FactorDescuento		   , 0) as FactorDescuento
		,isnull(IDPais				   , 0) as IDPais
		,isnull(AjustarUMI			   , 0) as AjustarUMI
    from [Nomina].[tblSalariosMinimos]
    where Fecha <= isnull(@Fecha,getdate()) 
    order by fecha desc
end
GO

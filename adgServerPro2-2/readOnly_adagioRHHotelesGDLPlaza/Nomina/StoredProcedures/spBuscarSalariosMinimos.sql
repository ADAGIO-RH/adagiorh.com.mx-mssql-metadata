USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarSalariosMinimos]
(
    @IDSalarioMinimo int = 0
) as
begin
    select 
	IDSalarioMinimo
	,Fecha
	,SalarioMinimo
	,UMA
	,isnull(FactorDescuento,0) as FactorDescuento
	,ROW_NUMBER()over(ORDER BY IDSalarioMinimo)as ROWNUMBER
    from [Nomina].[tblSalariosMinimos]
    where (IDSalarioMinimo = @IDSalarioMinimo or @IDSalarioMinimo = 0)
    order by fecha desc
end
GO

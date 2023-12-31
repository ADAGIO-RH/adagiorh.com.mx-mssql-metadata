USE [p_adagioRHBeHoteles]
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
	SM.IDSalarioMinimo
	,SM.Fecha
	,SM.SalarioMinimo
	,SM.UMA
	,isnull(SM.FactorDescuento,0) as FactorDescuento
	,ISNULL(p.IDPais,0) as IDPais
	,P.Descripcion as Pais
	,ROW_NUMBER()over(ORDER BY SM.IDSalarioMinimo)as ROWNUMBER
    from [Nomina].[tblSalariosMinimos] SM with(Nolock)
		left join SAT.tblCatPaises P
			on SM.IDPais = P.IDPais
    where (SM.IDSalarioMinimo = @IDSalarioMinimo or @IDSalarioMinimo = 0)
    order by SM.fecha desc
end
GO

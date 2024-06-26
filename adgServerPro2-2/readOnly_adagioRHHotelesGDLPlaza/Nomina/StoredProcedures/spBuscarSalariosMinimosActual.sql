USE [readOnly_adagioRHHotelesGDLPlaza]
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
    select top 1 *, ROW_NUMBER()OVER(ORDER BY IDSalarioMinimo asc)as ROWNUMBER
    from [Nomina].[tblSalariosMinimos]
    where Fecha <= isnull(@Fecha,getdate()) 
    order by fecha desc
end
GO

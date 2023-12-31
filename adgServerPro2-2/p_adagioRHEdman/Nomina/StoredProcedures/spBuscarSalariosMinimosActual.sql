USE [p_adagioRHEdman]
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
    select top 1 *
    from [Nomina].[tblSalariosMinimos]
    where Fecha <= isnull(@Fecha,getdate()) 
    order by fecha desc
end
GO

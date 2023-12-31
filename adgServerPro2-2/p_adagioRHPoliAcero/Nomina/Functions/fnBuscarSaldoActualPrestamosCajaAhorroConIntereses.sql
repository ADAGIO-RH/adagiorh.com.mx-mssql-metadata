USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Nomina].[fnBuscarSaldoActualPrestamosCajaAhorroConIntereses](
	@IDEmpleado int
) RETURNS TABLE 
AS
RETURN (
	select ISNULL ( SUM(Balance) , 0 ) as Total
	from (
		select 
		(P.MontoPrestamo + isnull(P.Intereses,0) ) - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		from Nomina.tblPrestamos p
			inner join Nomina.tblCatEstatusPrestamo EP
						on EP.IDEstatusPrestamo = p.IDEstatusPrestamo
		where IDTipoPrestamo = 7 and EP.Descripcion in ('ACTIVO') and p.IDEmpleado = @IDEmpleado
		) as Prestamos
)



--Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)


--select 12000.00-10905.0400
GO

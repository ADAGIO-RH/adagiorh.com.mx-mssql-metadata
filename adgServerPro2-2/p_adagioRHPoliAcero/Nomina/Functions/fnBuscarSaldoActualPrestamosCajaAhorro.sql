USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function Nomina.fnBuscarSaldoActualPrestamosCajaAhorro(
	@IDEmpleado int
) RETURNS TABLE 
AS
RETURN (
	select ISNULL ( SUM(Balance) , 0 ) as Total
	from (
		select isnull(p.MontoPrestamo,0)- (Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)) as Balance
		from Nomina.tblPrestamos p
			inner join Nomina.tblCatEstatusPrestamo EP
						on EP.IDEstatusPrestamo = p.IDEstatusPrestamo
		where IDTipoPrestamo = 7 and EP.Descripcion in ('ACTIVO') and p.IDEmpleado = @IDEmpleado
		) as Prestamos
)



--Select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)


--select 12000.00-10905.0400
GO

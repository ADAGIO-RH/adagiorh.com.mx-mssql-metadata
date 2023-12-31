USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function Nomina.fnBuscarSaldoActualPrestamosEmpresa(
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
		where IDTipoPrestamo = 5 and EP.Descripcion in ('ACTIVO') and p.IDEmpleado = @IDEmpleado
		) as Prestamos
)

GO

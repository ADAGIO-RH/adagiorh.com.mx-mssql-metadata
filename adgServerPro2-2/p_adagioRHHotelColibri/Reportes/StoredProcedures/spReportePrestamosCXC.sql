USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReportePrestamosCXC](
	  @IDPrestamo VARCHAR(MAX)
     ,@Fecha date
	 ,@IDUsuario int
) as
BEGIN
SET NOCOUNT ON;
IF 1=0 BEGIN
       SET FMTONLY OFF
       END


declare 
@IDIdioma VARCHAR(5)


select * from Nomina.tblPrestamos p
inner join rh.tblEmpleadosMaster em on p.IDEmpleado= em.IDEmpleado
inner join nomina.tblCatEstatusPrestamo ep on p.IDEstatusPrestamo = ep.IDEstatusPrestamo
inner join Nomina.tblCatTiposPrestamo tp on tp.IDTipoPrestamo = p.IDTipoPrestamo
where p.Codigo = @IDPrestamo 
and p.IDTipoPrestamo = (Select IDTipoPrestamo from nomina.tblCatTiposPrestamo where Descripcion = 'PRESTAMO CXC')
    

END
GO

USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Reportes].[spReportePrestamosFondoAhorroConAportacionesSubreporte_ANS]
	-- Add the parameters for the stored procedure here	
    @ClaveEmpleadoInicial varchar (max) = '0'
	,@IDEstatusPrestamo varchar(max)		= ''    
	,@IDUsuario int
AS
BEGIN
	declare @IDEmpleado int 

    
	select @IDEmpleado= IDEmpleado from RH.tblEmpleadosMaster where ClaveEmpleado=@ClaveEmpleadoInicial

   select           
                 
			c.IDPrestamo
			,c.IDEmpleado
            ,c.Codigo as [CodigoPrestamo]
            ,c.MontoPrestamo             
			,isnull(a.IDPrestamoDetalle ,-1) as IDPrestamoDetalle
            ,isnull((select sum(MontoCuota) from Nomina.tblPrestamosDetalles as o where o.IDPrestamo =c.IDPrestamo),0) AS Abonos
            ,c.Intereses
            ,c.Cuotas as [Descuento]
            ,c.FechaInicioPago as [FechaPrestamo]        
            ,a.FechaPago as [FechaAbono]
            ,a.MontoCuota as [Abono]
            ,es.Descripcion [EstatusPrestamo]
            ,COALESCE(pe.ClavePeriodo,'-') as [ClavePeriodo]
            ,COALESCE(pe.Descripcion,'-') as [DescripcionPeriodo]                    
			,(select sum(Intereses) from  Nomina.tblPrestamos as c  where c.IDTipoPrestamo = 6  and c.IDEmpleado = @IDEmpleado) as InteresesT
			,(select sum(c.Cuotas) from  Nomina.tblPrestamos as c  where c.IDTipoPrestamo = 6  and c.IDEmpleado = @IDEmpleado) as DescuentoT
			,(select sum(c.MontoPrestamo) from  Nomina.tblPrestamos as c  where c.IDTipoPrestamo = 6  and c.IDEmpleado = @IDEmpleado) as MontoT

    from Nomina.tblPrestamos as c 
    left join  Nomina.tblPrestamosDetalles as a on c.IDPrestamo = a.IDPrestamo 
    left join  Nomina.tblCatTiposPrestamo as b on b.IDTipoPrestamo= c.IDTipoPrestamo
    left join Nomina.tblCatEstatusPrestamo as es on es.IDEstatusPrestamo =c.IDEstatusPrestamo
    left join Nomina.tblCatPeriodos as pe on pe.IDPeriodo = a.IDPeriodo
    where c.IDTipoPrestamo = 6    
    
	and(c.IDEmpleado  in ( select item from app.Split( @IDEmpleado,',')) or isnull(@IDEmpleado,'') = '')
	
	

END
GO

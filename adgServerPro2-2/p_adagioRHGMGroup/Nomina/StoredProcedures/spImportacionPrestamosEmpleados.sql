USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spImportacionPrestamosEmpleados]    
(    
 @dtImportacion [Nomina].[dtPrestamosImportacion] READONLY    
 ,@IDUsuario int  
)    
AS    
BEGIN    
    
  select ROW_NUMBER()over(Order by e.ClaveEmpleado) as ROWNUMBER    
    ,isnull(em.IDEmpleado,0) as [IDEmpleado]    
    ,E.[ClaveEmpleado]    
    ,isnull(em.NOMBRECOMPLETO,'') as [NombreCompleto]    
    ,ISNULL(tp.IDTipoPrestamo,0) as IDTipoPrestamo  
    ,ISNULL(E.TipoPrestamo,'') as TipoPrestamo
	,ISNULL(EP.IDEstatusPrestamo,0) as IDEstatusPrestamo  
    ,ISNULL(EP.Descripcion,'') as EstatusPrestamo
    ,ISNULL(E.Descripcion,'') as Descripcion

	,ISNULL(E.MontoPrestamo,0) as MontoPrestamo
	,ISNULL(E.CuotasPrestamos,0) as CuotasPrestamo
    ,cast(isnull(E.[FechaInicioPago],'9999-12-31') as DATE) as [FechaInicioPago]    
    ,cast(getdate() as DATE) as [FechaCreacion]    
  from @dtImportacion E    
  left join RH.tblEmpleadosMaster em on e.ClaveEmpleado = em.ClaveEmpleado  
  left join Nomina.tblCatTiposPrestamo tp on tp.Descripcion = e.TipoPrestamo
  left join Nomina.tblCatEstatusPrestamo EP on EP.Descripcion = E.EstatusPrestamo
  WHERE isnull(E.ClaveEmpleado,'') <>''     
END
GO

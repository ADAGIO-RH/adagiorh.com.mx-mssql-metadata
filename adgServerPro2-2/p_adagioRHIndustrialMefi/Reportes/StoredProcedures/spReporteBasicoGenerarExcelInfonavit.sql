USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************           
** Descripción  : Procedimiento para buscar los creditos Infonavit por colaborador         
** Autor   : Javier Peña          
** Email   : jpena@gmail.com
** FechaCreacion : 2023-06-19          
** Paremetros  :                        
****************************************************************************************************          
HISTORIAL DE CAMBIOS          
Fecha(yyyy-mm-dd) Autor   Comentario          
------------------- ------------------- ------------------------------------------------------------          
0000-00-00  NombreCompleto  ¿Qué cambió?          
***************************************************************************************************/        
      
          
CREATE PROCEDURE [Reportes].[spReporteBasicoGenerarExcelInfonavit]          
(          
 @IDEmpleado int = 0, 
 @dtFiltros Nomina.dtFiltrosRH readonly,
 @IDUsuario int          
)          
AS          
BEGIN      
    
DECLARE     
   @SalarioMinimo Decimal(18,4),    
   @UMA  Decimal(18,4),       
   @FactorDescuento Decimal(18,4)    
    
    
    
   select top 1 @SalarioMinimo = SalarioMinimo    
  , @UMA = UMA    
  ,@FactorDescuento = FactorDescuento    
    from Nomina.tblSalariosMinimos     
 ORDER BY Fecha desc        
          
 SELECT                    
   IE.NumeroCredito as [Numero de Credito]         
  ,RegPatronal.RegistroPatronal AS [Reg Patronal]         
  ,RegPatronal.RazonSocial as [Razón Social]           
  ,TipoDescuento.Descripcion as [Tipo Descuento]  
  ,TipoMovimiento.Descripcion as [Tipo Movimiento]          
  ,IE.Fecha                 
 FROM RH.tblInfonavitEmpleado IE           
  INNER JOIN RH.tblEmpleadosMaster E          
   on IE.IDEmpleado = E.IDEmpleado          
  INNER JOIN RH.tblCatRegPatronal RegPatronal          
   on IE.IDRegPatronal = RegPatronal.IDRegPatronal          
  left JOIN RH.tblCatInfonavitTipoMovimiento TipoMovimiento          
   on TipoMovimiento.IDTipoMovimiento = IE.IDTipoMovimiento          
  left JOIN RH.tblCatInfonavitTipoDescuento TipoDescuento          
   on TipoDescuento.IDTipoDescuento = IE.IDTipoDescuento          
  where (IE.IDEmpleado = @IDEmpleado)       
END
GO

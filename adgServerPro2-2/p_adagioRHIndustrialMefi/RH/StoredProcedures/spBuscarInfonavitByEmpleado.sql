USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************           
** Descripción  : Procedimiento para buscar los creditos Infonavit por colaborador         
** Autor   : Jose Roman          
** Email   : jose.roman@adagio.com.mx          
** FechaCreacion : 2019-03-04          
** Paremetros  :                        
****************************************************************************************************          
HISTORIAL DE CAMBIOS          
Fecha(yyyy-mm-dd) Autor   Comentario          
------------------- ------------------- ------------------------------------------------------------          
0000-00-00  NombreCompleto  ¿Qué cambió?          
***************************************************************************************************/        
      
          
CREATE PROCEDURE [RH].[spBuscarInfonavitByEmpleado]          
(          
 @IDEmpleado int = 0,  
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
  IE.IDInfonavitEmpleado          
  ,IE.IDEmpleado          
  ,E.ClaveEmpleado          
  ,substring(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) as NombreCompleto          
  ,ISNULL(IE.IDRegPatronal,0) as IDRegPatronal          
  ,RegPatronal.RegistroPatronal          
  ,RegPatronal.RazonSocial          
  ,IE.NumeroCredito          
  ,ISNULL(IE.IDTipoMovimiento,0) as IDTipoMovimiento          
  ,TipoMovimiento.Descripcion as TipoMovimiento          
  ,IE.Fecha          
  ,ISNULL(IE.IDTipoDescuento,0) as IDTipoDescuento          
  ,TipoDescuento.Descripcion as TipoDescuento          
  ,IE.ValorDescuento          
  ,ISNULL(IE.AplicaDisminucion,0) as  AplicaDisminucion        
   ,CASE WHEN TipoDescuento.Descripcion = 'Porcentaje'   THEN  (((E.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
	  WHEN TipoDescuento.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
	  WHEN TipoDescuento.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
	 ELSE IE.ValorDescuento    
	 END as DescuentoMensual  
	, ROW_NUMBER()over(order by IE.IDInfonavitEmpleado) as ROWNUMBER    
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

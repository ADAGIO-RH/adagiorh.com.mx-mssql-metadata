USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/****************************************************************************************************   
** Descripción  : Procedimiento para buscar el historial de metodos de pago de un Colaborador  
** Autor   : Jose Rafael Roman Gil  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 01/01/2018  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor    Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto   ¿Qué cambió?  
2018-05-07  JOSE RAFAEL ROMAN GIL Se modifica el proceso de este procedimiento para cargar el  
          concepto y el banco en la tabla de layouts.  
***************************************************************************************************/  
  
CREATE PROCEDURE [RH].[spBuscarPagoEmpleado] --1086  
(  
 @IDEmpleado int  
)  
AS  
BEGIN  
  Select   
   PE.IDPagoEmpleado,  
   PE.IDEmpleado,  
   isnull(PE.IDLayoutPago,0) as IDLayoutPago ,  
   coalesce(lp.Descripcion,'SIN LAYOUT')as Descripcion,  
   PE.Cuenta,  
   PE.Sucursal,  
   PE.Interbancaria,  
   PE.Tarjeta,  
   PE.IDBancario,  
   isnull(b.IDBanco,0) as IDBanco ,  
   coalesce(b.Descripcion,'SIN BANCO')as Banco  
  From RH.tblPagoEmpleado PE  
   LEFT Join Nomina.tblLayoutPago lp  
    on PE.IDLayoutPago = lp.IDLayoutPago  
   Left Join Sat.tblCatBancos b  
    on PE.IDBanco = b.IDBanco  
  Where PE.IDEmpleado = @IDEmpleado  
END
GO

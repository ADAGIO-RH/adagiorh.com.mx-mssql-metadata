USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Procedimiento para Buscar los datos para llenar los Layouts  
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2018-12-24    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
***************************************************************************************************/    
    
CREATE PROCEDURE Nomina.spBuscarParametrosLayoutPago --7 ,4    
(    
 @IDLayoutPago int    
)    
AS    
BEGIN    
     
select lpp.IDLayoutPago  
 ,lpp.IDLayoutPagoParametros  
 ,tlp.Parametro  
 ,lpp.Valor   
from Nomina.tblLayoutPagoParametros lpp  
 inner join Nomina.tblLayoutPago lp  
  on lpp.IDLayoutPago = lp.IDLayoutPago  
 inner join Nomina.tblCatTiposLayout tl  
  on tl.IDTipoLayout = lp.IDTipoLayout  
 left join Nomina.tblCatTiposLayoutParametros tlp  
  on tlp.IDTipoLayout = tl.IDTipoLayout  
  and lpp.IDTipoLayoutParametro = tlp.IDTipoLayoutParametro  
where lpp.IDLayoutPago = @IDLayoutPago  
       
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Crear y actualizar conceptos Reporte Rayas 
** Autor   : jose roman 
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2019-02-26  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
 
***************************************************************************************************/  
CREATE PROCEDURE [Reportes].[spIUConfigReporteRayas]  
(  
  @IDConcepto int   
 ,@Impresion bit   

 ,@IDUsuario int  
)  
AS  
BEGIN  
 
    update Reportes.tblConfigReporteRayas  
    set  
		Impresion     = @Impresion  
		
	where IDConcepto = @IDConcepto  
     
    exec [Reportes].[spBuscarConfigReporteRayas] @IDConcepto= @IDConcepto;

END
GO

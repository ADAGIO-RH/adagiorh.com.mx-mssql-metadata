USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Busca Configuracion de Reporte de Rayas
** Autor   : Jose Roman
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2019-02-26  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
CREATE PROCEDURE [Reportes].[spBuscarConfigReporteRayas]  
(
	@IDConcepto int = null
)
AS  
BEGIN  
 SELECT    
     cr.IDConcepto  
    ,c.Codigo  
    ,c.Descripcion  
    ,isnull(cr.Impresion,0) as Impresion
    ,cr.Orden  
  
 FROM Reportes.tblConfigReporteRayas cr  
  join Nomina.tblCatConceptos c on c.IDConcepto = cr.IDConcepto  
where (cr.IDConcepto = @IDConcepto) OR (@IDConcepto is null) 
 order by cr.Orden asc  
END
GO

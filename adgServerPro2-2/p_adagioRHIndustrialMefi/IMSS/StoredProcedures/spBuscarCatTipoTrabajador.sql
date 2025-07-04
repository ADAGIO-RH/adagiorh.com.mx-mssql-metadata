USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatTipoTrabajador]    
(    
  @IDTipoTrabajador int = null  
  ,@IDUsuario int = null      
)    
AS    
BEGIN  
   SET FMTONLY OFF;
--IF OBJECT_ID('tempdb..#TempTipoTrabajador') IS NOT NULL  
--  DROP TABLE #TempTipoTrabajador  
  
    
-- select ID   
--  Into #TempTipoTrabajador  
-- from Seguridad.tblFiltrosUsuarios   
-- where IDUsuario = @IDUsuario and Filtro = 'TipoTrabajador'  
    
 Select    
 IDTipoTrabajador    
 ,Codigo    
 ,Descripcion    
 ,ROW_NUMBER()over(ORDER BY IDTipoTrabajador)as ROWNUMBER    
 From [IMSS].[tblCatTipoTrabajador]    
 where IDTipoTrabajador = @IDTipoTrabajador or @IDTipoTrabajador is null    
 --  and (IDDivision in  ( select ID from #TempDivisiones)  
 --OR Not Exists(select ID from #TempDivisiones))  
 --order by RH.tblCatDivisiones.Descripcion asc    
END
GO

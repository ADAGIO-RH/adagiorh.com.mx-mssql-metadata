USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatTipoSalario]    
(    
  @IDTipoSalario int = null  
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
	 IDTipoSalario    
	 ,Codigo    
	 ,Descripcion    
	 ,ROW_NUMBER()over(ORDER BY IDTipoSalario)as ROWNUMBER    
	 From [IMSS].[tblCatTipoSalario]    
	 where IDTipoSalario = @IDTipoSalario or ISNULL(@IDTipoSalario,0) = 0    
	 ORDER BY Codigo asc 
END
GO

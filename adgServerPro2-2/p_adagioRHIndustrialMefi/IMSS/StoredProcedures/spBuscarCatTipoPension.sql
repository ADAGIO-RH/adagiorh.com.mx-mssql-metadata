USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spBuscarCatTipoPension]    
(    
  @IDTipoPension int = null  
  ,@IDUsuario int = null      
)    
AS    
BEGIN  
   SET FMTONLY OFF;
    
	 Select    
	 IDTipoPension    
	 ,Codigo    
	 ,Descripcion    
	 ,ROW_NUMBER()over(ORDER BY IDTipoPension)as ROWNUMBER    
	 From [IMSS].[tblCatTipoPension]    
	 where IDTipoPension = @IDTipoPension or ISNULL(@IDTipoPension,0) = 0    
	 ORDER BY Codigo asc 
END
GO

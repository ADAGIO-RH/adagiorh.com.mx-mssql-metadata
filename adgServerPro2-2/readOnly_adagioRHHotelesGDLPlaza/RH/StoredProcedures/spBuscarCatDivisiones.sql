USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatDivisiones]    
(    
  @IDDivision int = null  
  ,@IDUsuario int = null      
)    
AS    
BEGIN  
   SET FMTONLY OFF;
IF OBJECT_ID('tempdb..#TempDivisiones') IS NOT NULL  
  DROP TABLE #TempDivisiones  
  
    
 select ID   
  Into #TempDivisiones  
 from Seguridad.tblFiltrosUsuarios with(nolock)  
 where IDUsuario = @IDUsuario and Filtro = 'Divisiones'  
    
 Select    
 IDDivision    
 ,Codigo    
 ,Descripcion    
 ,CuentaContable    
 ,isnull(IDEmpleado,0) as IDEmpleado    
 ,JefeDivision    
 ,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER    
 From RH.tblCatDivisiones  with(nolock)    
 where IDDivision = @IDDivision or @IDDivision is null    
   and (IDDivision in  ( select ID from #TempDivisiones)  
 OR Not Exists(select ID from #TempDivisiones))  
 order by RH.tblCatDivisiones.Descripcion asc    
END
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE PROCEDURE [RH].[spBuscarTipoPrestacionPorID] --5,1   
(    
 @IDTipoPrestacion int = 0 ,  
 @IDUsuario int     
)    
AS    
BEGIN    
  
IF OBJECT_ID('tempdb..#TempTiposPrestaciones') IS NOT NULL    
  DROP TABLE #TempTiposPrestaciones    
     
 select ID     
  Into #TempTiposPrestaciones    
 from Seguridad.tblFiltrosUsuarios     
 where IDUsuario = @IDUsuario and Filtro = 'Prestaciones'    
  
 SELECT     
 IDTipoPrestacion    
 ,Codigo    
 ,Descripcion as FacIntegracion    
 ,Sindical    
 ,isnull(PorcentajeFondoAhorro,0) as PorcentajeFondoAhorro    
 FROM [RH].[tblCatTiposPrestaciones]    
 WHERE (IDTipoPrestacion=@IDTipoPrestacion or @IDTipoPrestacion =0)   
 and (IDTipoPrestacion in  ( select ID from #TempTiposPrestaciones)    
 OR Not Exists(select ID from #TempTiposPrestaciones))   
END
GO

USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBuscarAplicaciones]    
as    
 select     
  IDAplicacion    
  ,Descripcion  
  ,Orden  
 ,Icon
 ,Url    
 from app.tblCatAplicaciones
GO

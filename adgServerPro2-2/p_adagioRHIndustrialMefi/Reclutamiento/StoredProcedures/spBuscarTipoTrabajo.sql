USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Reclutamiento].[spBuscarTipoTrabajo]  
  
	AS
BEGIN  
 

   select     
   IDTipoTrabajo,
	Descripcion         
   from [Reclutamiento].[tblCatTipoTrabajo]
 
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [App].[spGenerarIDArea] -- 1,1  

AS  
BEGIN  
  
  declare  @MAXIDArea int;
  
  select @MAXIDArea = (select isnull(MAX(IDArea),0) from [App].[tblCatAreas]);
  Set @MAXIDArea = @MAXIDArea + 1  

  select @MAXIDArea;

  

END
GO

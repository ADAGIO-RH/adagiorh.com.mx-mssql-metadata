USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [App].[spBorrarCatArea] 
(
	@IDArea int
)
AS
BEGIN
    
  SELECT * FROM [App].[tblCatAreas]
  where IDArea = @IDArea

  select * from [App].[tblAplicacionAreas]
  where IDArea = @IDArea

DELETE FROM [App].[tblAplicacionAreas]
      WHERE IDArea = @IDArea

DELETE FROM [App].[tblCatAreas]
      WHERE  IDArea = @IDArea

END
GO

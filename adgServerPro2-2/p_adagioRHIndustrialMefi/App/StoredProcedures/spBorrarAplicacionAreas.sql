USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [App].[spBorrarAplicacionAreas] 
(
	@IDAplicacion varchar(255),
	@IDArea int
)
AS
BEGIN
    

DELETE FROM [App].[tblAplicacionAreas]
      WHERE IDAplicacion = @IDAplicacion
	  and IDArea = @IDArea


END
GO

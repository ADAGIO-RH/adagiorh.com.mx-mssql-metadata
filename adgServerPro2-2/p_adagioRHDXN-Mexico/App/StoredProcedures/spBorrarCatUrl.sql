USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spBorrarCatUrl]
(
	@IDUrl int
)
AS
BEGIN


DELETE FROM [App].[tblCatUrls]
      WHERE IDUrl = @IDUrl


END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spBorrarCatModulo]
(
		@IDModulo int
)
as
	DELETE FROM [App].[tblCatModulos]
	WHERE IDModulo = @IDModulo
GO

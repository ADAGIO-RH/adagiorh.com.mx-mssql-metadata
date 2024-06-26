USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarUrls]
(
	@IDModulo int = 0
)
AS
BEGIN
	Select IDUrl
			,cu.IDModulo
			,cu.Descripcion
			,URL
			,Tipo
			,cm.Descripcion as Modulo
	from App.tblCatUrls cu
	left join App.tblCatModulos cm on cu.IDModulo = cm.IDModulo
	Where (cu.IDModulo = @IDModulo) OR (@IDModulo = 0)
END
GO

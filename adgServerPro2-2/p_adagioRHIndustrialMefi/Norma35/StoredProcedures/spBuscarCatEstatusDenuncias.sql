USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarCatEstatusDenuncias]
(
	@IDEstatusDenuncia INT = NULL
	,@IDUsuario INT
)
AS
BEGIN

	SELECT IDEstatusDenuncia , Descripcion ,EstatusBackground , EstatusColor 
	  FROM [Norma35].tblCatEstatusDenuncia   
	  WHERE (ISNULL(@IDEstatusDenuncia,0) = 0 OR IDEstatusDenuncia = @IDEstatusDenuncia)

	 
END
GO

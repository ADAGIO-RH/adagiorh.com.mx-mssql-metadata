USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarTiposDenunciasDisponibles]
(
	  @IDTipoDenuncia INT = NULL
	 ,@IDUsuario INT
)
AS
BEGIN

	SELECT [IDTipoDenuncia]
		  ,[Descripcion]
		  ,[Disponible]
	  FROM [Norma35].[tblCatTiposDenuncias]
	  WHERE (ISNULL(@IDTipoDenuncia,0) = 0 OR IDTipoDenuncia = @IDTipoDenuncia)
	  AND [Disponible]=1;

	 
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarCatTiposDenunciados]
(
	  @IDTipoDenunciado INT = NULL
	 ,@IDUsuario INT
)
AS
BEGIN

	SELECT [IDTipoDenunciado]
		  ,[Descripcion]
		  ,[Disponible]
	  FROM [Norma35].[tblCatTiposDenunciado]
  	  WHERE (ISNULL(@IDTipoDenunciado,0) = 0 OR IDTipoDenunciado = @IDTipoDenunciado)
	        AND [Disponible] = 1;

END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarIdiomas]
(
	@IDIdioma Varchar(10) = null
)
AS
BEGIN
	
	SELECT 
		IDIdioma
		,Idioma 
		,[SQL]
		,Traduccion
		,isnull(Orden, 0) as Orden
		,isnull(Activo, 0) as Activo
	FROM App.tblIdiomas
	WHERE (IDIdioma = @IDIdioma) OR (@IDIdioma is null)
	order by Orden

END
GO

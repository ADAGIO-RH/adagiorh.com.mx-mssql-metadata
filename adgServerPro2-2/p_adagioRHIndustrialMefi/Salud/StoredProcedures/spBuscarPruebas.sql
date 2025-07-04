USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salud].[spBuscarPruebas]
(
	@IDPrueba int = 0
)
AS
BEGIN
	SELECT 
		IDPrueba
		,Nombre
		,Descripcion
		,isnull(FechaCreacion,getdate()) FechaCreacion
		,isnull(RevisionTemperatura,0) as RevisionTemperatura
		,IDUsuario
		,isnull(Liberado,0) as Liberado 
		,Personalizada
		,ROW_NUMBER()OVER(ORDER BY IDPrueba ASC) as ROWNUMBER
	FROM [Salud].[tblPruebas] with (nolock)
	WHERE ((IDPrueba = @IDPrueba) OR (isnull(@IDPrueba,0) = 0))
END;
GO

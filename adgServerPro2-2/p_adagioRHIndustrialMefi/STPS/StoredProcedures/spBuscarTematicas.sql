USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarTematicas]
(
	@IDTematica int = null
)
AS
BEGIN

		select 
		IDTematica
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatTematicas]
		where IDTematica = @IDTematica or @IDTematica is null
	
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarTiposAgentes]
(
	@IDTipoAgente int = null
)
AS
BEGIN
		select 
		IDTipoAgente
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatTiposAgentes]
		where IDTipoAgente = @IDTipoAgente or @IDTipoAgente is null
END
GO

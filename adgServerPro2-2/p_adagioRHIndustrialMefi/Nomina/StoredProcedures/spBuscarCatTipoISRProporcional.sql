USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCatTipoISRProporcional]
(
	@IDISRProporcional int = null	
)
AS
BEGIN
    select IDISRProporcional
		  ,Nombre   
	      ,Descripcion
    from Nomina.tblCatTipoISRProporcional
    where (IDISRProporcional=@IDISRProporcional or @IDISRProporcional is null)
END;
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Facturacion.spBuscarConfigTimbrado
AS
BEGIN
	Select * from Facturacion.tblConfigTimbrado
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Facturacion.spUIConfigTimbrado 
(
	@IDConfigTimbrado int,
	@Value bit
)
AS
BEGIN
	Update Facturacion.tblConfigTimbrado
		set Value = @Value
	Where IDConfigTimbrado = @IDConfigTimbrado

	Select * from Facturacion.tblConfigTimbrado where IDConfigTimbrado = @IDConfigTimbrado
END
GO

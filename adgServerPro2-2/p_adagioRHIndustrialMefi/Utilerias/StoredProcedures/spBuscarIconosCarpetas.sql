USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Utilerias.spBuscarIconosCarpetas
AS
BEGIN
	Select Icono from Utilerias.tblIconosCarpetas
END
GO

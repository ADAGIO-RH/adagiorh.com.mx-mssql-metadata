USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Utilerias.spBuscarIconosArchivos
AS
BEGIN
	Select Icono from Utilerias.tblIconosArchivos
END
GO

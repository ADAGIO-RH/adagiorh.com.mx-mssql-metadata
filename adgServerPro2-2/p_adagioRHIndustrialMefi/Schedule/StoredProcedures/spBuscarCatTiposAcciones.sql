USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Schedule.spBuscarCatTiposAcciones
AS
BEGIN
	Select 
		IDTipoAccion
		,Descripcion
	from Schedule.tblCatTipoAcciones
END
GO

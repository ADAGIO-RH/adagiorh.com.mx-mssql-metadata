USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure RH.spBuscarCatTipoDocumento
AS
BEGIN
	Select 
		IDTipoDocumento
		,Descripcion
	from RH.tblCatTipoDocumento
END
GO

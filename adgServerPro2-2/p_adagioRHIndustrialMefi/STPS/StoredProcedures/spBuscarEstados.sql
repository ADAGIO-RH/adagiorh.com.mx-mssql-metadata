USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarEstados]
(
	@IDEstado int = null
)
AS
BEGIN
	Select 
	IDEstado
	,UPPER(Codigo) as Codigo
	,UPPER(Descripcion) as Descripcion
	from STPS.tblCatEstados
	where IDEstado = @IDEstado or @IDEstado is null
END
GO

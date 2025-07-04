USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposOtrosPagos]
(
	@TipoOtroPago Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoOtroPago = '' or @TipoOtroPago is null)
	BEGIN
		select 
			IDTipoOtroPago
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposOtrosPagos]
	END
	ELSE
	BEGIN
		select 
			IDTipoOtroPago
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatTiposOtrosPagos]
		where Descripcion like @TipoOtroPago +'%'
			OR Codigo like @TipoOtroPago+'%'
	END
END
GO

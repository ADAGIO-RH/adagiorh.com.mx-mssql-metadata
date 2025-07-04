USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposComprobante]
(
	@TipoComprobante Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoComprobante = '' or @TipoComprobante is null)
	BEGIN
		select 
		IDTipoComprobante
		,UPPER(Codigo) AS Codigo
		,UPPER(Descripcion) AS Descripcion
		,ValorMaximo
		From [Sat].[tblCatTiposComprobante]
	END
	ELSE
	BEGIN
		select 
			IDTipoComprobante
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,ValorMaximo 
		From [Sat].[tblCatTiposComprobante]
		where Descripcion like @TipoComprobante +'%'
			OR Codigo like @TipoComprobante+'%'
	END
END
GO

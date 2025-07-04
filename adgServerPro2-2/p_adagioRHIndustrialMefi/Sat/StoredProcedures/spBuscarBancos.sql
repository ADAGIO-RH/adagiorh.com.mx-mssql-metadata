USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarBancos]
(
	@Banco Varchar(50) = ''

)
AS
BEGIN
	IF(@Banco = '' or @Banco is null)
	BEGIN
		select  IDBanco
				,UPPER(Codigo) AS Codigo
				,UPPER(Descripcion) AS Descripcion
				,UPPER(RazonSocial)AS RazonSocial
		from [Sat].[tblCatBancos]
	END
	ELSE
	BEGIN
		select IDBanco
				,UPPER(Codigo) AS Codigo
				,UPPER(Descripcion) AS Descripcion
				,UPPER(RazonSocial)AS RazonSocial 
		from [Sat].[tblCatBancos]
		Where Descripcion Like @Banco+'%'
			OR Codigo like @Banco+'%'
	END
END
GO

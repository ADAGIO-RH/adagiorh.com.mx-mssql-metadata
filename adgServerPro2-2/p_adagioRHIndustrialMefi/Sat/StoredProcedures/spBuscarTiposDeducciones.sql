USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposDeducciones]
(
	@TipoDeduccion Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoDeduccion = '' or @TipoDeduccion is null)
	BEGIN
		select 
			IDTipoDeduccion
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposDeducciones]
	END
	ELSE
	BEGIN
		select 
			IDTipoDeduccion
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatTiposDeducciones]
		where Descripcion like @TipoDeduccion +'%'
			OR Codigo like @TipoDeduccion+'%'
	END
END
GO
